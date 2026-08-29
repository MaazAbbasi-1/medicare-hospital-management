import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserRole = 'user_role';
  static const String _keyLocalUsers = 'local_registered_users';

  // Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    if (_auth.currentUser != null) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId) != null;
  }

  // Sign up with Email & Password (Firebase + Local fallback)
  static Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();
    final cleanName = name.trim();
    final cleanPhone = phone.trim();

    String uid = '';
    bool firebaseSuccess = false;

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPass,
      );

      final User? user = userCredential.user;

      if (user != null) {
        uid = user.uid;
        firebaseSuccess = true;
        try {
          await user.updateDisplayName(cleanName);
        } catch (_) {}

        final newUser = UserModel(
          uid: user.uid,
          name: cleanName,
          email: cleanEmail,
          phone: cleanPhone,
          role: 'patient',
          createdAt: DateTime.now().toIso8601String(),
        );

        try {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toMap());
        } catch (_) {}
      }
    } catch (e) {
      if (e is FirebaseAuthException &&
          (e.code == 'email-already-in-use' ||
              e.code == 'weak-password' ||
              e.code == 'invalid-email')) {
        rethrow;
      }
    }

    if (!firebaseSuccess) {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyLocalUsers);
      Map<String, dynamic> localUsers = {};
      if (usersJson != null) {
        try {
          localUsers = Map<String, dynamic>.from(jsonDecode(usersJson));
        } catch (_) {}
      }

      if (localUsers.containsKey(cleanEmail)) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'An account already exists with this email.',
        );
      }

      uid = const Uuid().v4();
      localUsers[cleanEmail] = {
        'uid': uid,
        'name': cleanName,
        'email': cleanEmail,
        'password': cleanPass,
        'phone': cleanPhone,
        'role': 'patient',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_keyLocalUsers, jsonEncode(localUsers));
    }

    // Cache active session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, uid);
    await prefs.setString(_keyUserName, cleanName);
    await prefs.setString(_keyUserEmail, cleanEmail);
    await prefs.setString(_keyUserPhone, cleanPhone);
    await prefs.setString(_keyUserRole, 'patient');
  }

  // Sign in with Email & Password
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    String name = '';
    String phone = '';
    String uid = '';
    String role = 'patient';

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPass,
      );

      final User? user = userCredential.user;

      if (user != null) {
        uid = user.uid;
        name = user.displayName ?? '';

        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (!doc.exists || doc.data() == null) {
            await signOut();
            throw StateError(
              'Your Firebase account is missing a users profile. Create users/${user.uid} with role doctor or admin.',
            );
          }
          final data = doc.data()!;
          name = data['name']?.toString() ?? name;
          phone = data['phone']?.toString() ?? '';
          role = _normalizeRole(data['role']);
        } catch (error) {
          if (error is StateError) rethrow;
          await signOut();
          throw StateError(
            'Could not load your Firebase role profile. Check Firestore access and users/${user.uid}.',
          );
        }
      }
    } catch (e) {
      if (e is FirebaseAuthException &&
          (e.code == 'wrong-password' ||
              e.code == 'user-not-found' ||
              e.code == 'invalid-credential' ||
              e.code == 'invalid-email' ||
              e.code == 'operation-not-allowed' ||
              e.code == 'configuration-not-found')) {
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString(_keyLocalUsers);
        if (usersJson != null) {
          Map<String, dynamic> localUsers = {};
          try {
            localUsers = Map<String, dynamic>.from(jsonDecode(usersJson));
          } catch (_) {}

          if (localUsers.containsKey(cleanEmail)) {
            final localUser = Map<String, dynamic>.from(localUsers[cleanEmail]);
            if (localUser['password'] == cleanPass) {
              uid = localUser['uid']?.toString() ?? const Uuid().v4();
              name = localUser['name']?.toString() ?? '';
              phone = localUser['phone']?.toString() ?? '';
              role = _normalizeRole(localUser['role']);
            } else {
              throw FirebaseAuthException(
                code: 'wrong-password',
                message: 'Incorrect password. Please try again.',
              );
            }
          } else {
            if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
              rethrow;
            }
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No account found with this email.',
            );
          }
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, uid);
    await prefs.setString(
      _keyUserName,
      name.isNotEmpty ? name : cleanEmail.split('@')[0],
    );
    await prefs.setString(_keyUserEmail, cleanEmail);
    await prefs.setString(_keyUserPhone, phone);
    await prefs.setString(_keyUserRole, role);

    if (role == 'doctor' && uid.isNotEmpty) {
      await _linkDoctorProfile(
        name.isNotEmpty ? name : cleanEmail.split('@')[0],
        uid,
      );
    }
  }

  static Future<void> _linkDoctorProfile(String name, String uid) async {
    try {
      final matches = await _firestore
          .collection('doctors')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      if (matches.docs.isNotEmpty) {
        await matches.docs.first.reference.set({
          'userId': uid,
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserRole);
  }

  static String _normalizeRole(dynamic value) {
    final role = value?.toString().toLowerCase();
    return {'patient', 'doctor', 'admin'}.contains(role) ? role! : 'patient';
  }

  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_keyUserRole);
    if (cached != null) return _normalizeRole(cached);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final role = _normalizeRole(snapshot.data()?['role']);
        await prefs.setString(_keyUserRole, role);
        return role;
      } catch (_) {}
    }
    return 'patient';
  }

  // Send Password Reset Email
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          final prefs = await SharedPreferences.getInstance();
          final usersJson = prefs.getString(_keyLocalUsers);
          if (usersJson != null) {
            final localUsers = Map<String, dynamic>.from(jsonDecode(usersJson));
            if (localUsers.containsKey(email.trim().toLowerCase())) {
              return; // Mock reset success for offline accounts
            }
          }
        }
      }
      rethrow;
    }
  }

  // Get cached user name
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_keyUserName);
    if (cached != null && cached.isNotEmpty) return cached;
    return _auth.currentUser?.displayName ??
        _auth.currentUser?.email?.split('@')[0] ??
        'User';
  }

  // Get cached user email
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_keyUserEmail);
    if (cached != null && cached.isNotEmpty) return cached;
    return _auth.currentUser?.email ?? '';
  }

  // Get cached user phone
  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserPhone) ?? '';
  }

  // Friendly error messages
  static String getErrorMessage(dynamic error) {
    if (error is StateError) return error.message;
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Please use at least 6 characters.';
        case 'operation-not-allowed':
          return 'Email/Password sign-in is disabled in Firebase Console.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }
}
