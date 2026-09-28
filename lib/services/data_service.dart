import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

class DataService {
  static const String _appointmentsKey = 'appointments';

  // ─── Firebase Firestore Doctors Stream & Fetch ────────────────────────────
  static Stream<List<Doctor>> getDoctorsStream() {
    return FirebaseFirestore.instance
        .collection('doctors')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Doctor.fromMap(data);
          }).toList();
        });
  }

  static Future<List<Doctor>> getDoctors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Doctor.fromMap(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveDoctorToFirestore(Doctor doctor) async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctor.id)
          .set(doctor.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  // ─── Appointments CRUD & Real-Time Sync ────────────────────────────────────
  static Future<void> _cacheAppointmentsLocally(List<Appointment> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _appointmentsKey,
        jsonEncode(list.map((a) => a.toMap()).toList()),
      );
    } catch (_) {}
  }

  static Stream<List<Appointment>> getAppointmentsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(const <Appointment>[]);
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Appointment.fromMap(data);
          }).toList();
          _cacheAppointmentsLocally(list);
          return list;
        });
  }

  static Future<List<Appointment>> getAppointments() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return _getCachedAppointments();
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: userId)
          .get()
          .timeout(const Duration(seconds: 3));
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Appointment.fromMap(data);
        }).toList();
        await _cacheAppointmentsLocally(list);
        return list;
      }
    } catch (_) {}

    return _getCachedAppointments();
  }

  static Future<List<Appointment>> _getCachedAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_appointmentsKey);
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => Appointment.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAppointment(Appointment appointment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError(
        'Please sign in with your Firebase account before booking an appointment.',
      );
    }
    if (appointment.patientId != user.uid) {
      throw StateError(
        'Your Firebase session is not valid for this appointment.',
      );
    }

    final firestore = FirebaseFirestore.instance;
    final appointmentRef = firestore
        .collection('appointments')
        .doc(appointment.id);
    final existing = await appointmentRef.get();
    if (!existing.exists) {
      final conflicts = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: appointment.doctorId)
          .get();
      final occupied = conflicts.docs.any((doc) {
        final data = doc.data();
        final status = data['status']?.toString().toLowerCase();
        final sameSchedule =
            data['date'] == appointment.date &&
            data['slot'] == appointment.slot;
        return sameSchedule && status != 'cancelled' && status != 'rejected';
      });
      if (occupied) {
        throw StateError(
          'This time slot has just been booked. Please choose another slot.',
        );
      }
    }

    await appointmentRef.set(appointment.toMap(), SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    final appointments = await _getCachedAppointments();
    appointments.removeWhere((a) => a.id == appointment.id);
    appointments.insert(0, appointment);
    await prefs.setString(
      _appointmentsKey,
      jsonEncode(appointments.map((a) => a.toMap()).toList()),
    );
  }

  static Future<void> deleteAppointment(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = await getAppointments();
    appointments.removeWhere((a) => a.id == id);
    await prefs.setString(
      _appointmentsKey,
      jsonEncode(appointments.map((a) => a.toMap()).toList()),
    );

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .delete();
    } catch (_) {}
  }

  static Future<void> updateAppointmentStatus(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = await getAppointments();
    final idx = appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      appointments[idx] = appointments[idx].copyWith(status: status);
    }
    await prefs.setString(
      _appointmentsKey,
      jsonEncode(appointments.map((a) => a.toMap()).toList()),
    );

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .update({'status': status});
    } catch (_) {}
  }

  static Future<void> rescheduleAppointment(
    String id,
    String newDate,
    String newSlot,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = await getAppointments();
    final idx = appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final old = appointments[idx];
      appointments[idx] = Appointment(
        id: old.id,
        doctorId: old.doctorId,
        doctorName: old.doctorName,
        doctorSpecialization: old.doctorSpecialization,
        patientName: old.patientName,
        patientAge: old.patientAge,
        patientPhone: old.patientPhone,
        slot: newSlot,
        date: newDate,
        status: 'Confirmed',
        problem: old.problem,
        patientId: old.patientId,
        doctorNotes: old.doctorNotes,
        fee: old.fee,
        type: old.type,
      );
    }
    await prefs.setString(
      _appointmentsKey,
      jsonEncode(appointments.map((a) => a.toMap()).toList()),
    );

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .update({'date': newDate, 'slot': newSlot, 'status': 'Confirmed'});
    } catch (_) {}
  }
}
