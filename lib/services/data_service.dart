import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

class DataService {
  static const String _appointmentsKey = 'appointments';

  // ─── Default Doctors with rich descriptions and reviews ───────────────────
  static List<Doctor> get defaultDoctors => [
    Doctor(
      id: 'd1',
      name: 'Dr. Sarah Khan',
      qualification: 'MBBS, MD, FACC (Cardiology)',
      specialization: 'Cardiologist',
      experience: '12 Years',
      rating: 4.9,
      availability: 'Mon - Fri',
      imageEmoji: '❤️',
      availableSlots: [
        '09:00 AM',
        '10:00 AM',
        '11:30 AM',
        '02:00 PM',
        '03:30 PM',
        '05:00 PM',
      ],
      fee: 1500,
      hospitalLocation: 'Heart Care Center, Wing A, Room 201',
      aboutBio:
          'Dr. Sarah Khan is a senior consultant cardiologist specializing in cardiovascular health, non-invasive cardiac imaging, and preventive cardiology with over a decade of clinical excellence.',
      patientsCount: '2,400+',
      reviewsCount: 184,
      reviews: [
        DoctorReview(
          patientName: 'Ali Tariq',
          rating: 5.0,
          comment:
              'Exceptional doctor! Diagnosed my heart issue promptly and prescribed very effective treatment.',
          date: '2 days ago',
        ),
        DoctorReview(
          patientName: 'Saima Noor',
          rating: 4.8,
          comment:
              'Very polite, patient, and knowledgeable. Highly recommended for cardiac consultation.',
          date: '1 week ago',
        ),
      ],
    ),
    Doctor(
      id: 'd2',
      name: 'Dr. Ahmed Raza',
      qualification: 'MBBS, FCPS (Neurology), PhD',
      specialization: 'Neurologist',
      experience: '15 Years',
      rating: 4.8,
      availability: 'Mon - Sat',
      imageEmoji: '🧠',
      availableSlots: [
        '10:00 AM',
        '11:30 AM',
        '01:00 PM',
        '03:00 PM',
        '04:30 PM',
      ],
      fee: 2000,
      hospitalLocation: 'Neuroscience Institute, Tower 2, 4th Floor',
      aboutBio:
          'Renowned neurologist focused on complex neurological conditions, migraine management, seizure disorders, and brain health therapies.',
      patientsCount: '3,100+',
      reviewsCount: 220,
      reviews: [
        DoctorReview(
          patientName: 'Hamza Malik',
          rating: 5.0,
          comment:
              'Helped solve my chronic migraines. Very thorough evaluation and gentle bedside manner.',
          date: '3 days ago',
        ),
      ],
    ),
    Doctor(
      id: 'd3',
      name: 'Dr. Fatima Ali',
      qualification: 'MBBS, FCPS (Pediatrics), DCH',
      specialization: 'Pediatrician',
      experience: '8 Years',
      rating: 4.9,
      availability: 'Tue - Sun',
      imageEmoji: '👶',
      availableSlots: [
        '08:30 AM',
        '09:30 AM',
        '11:00 AM',
        '02:30 PM',
        '04:00 PM',
      ],
      fee: 1200,
      hospitalLocation: 'Child Health Clinic, OPD Floor 1',
      aboutBio:
          'Dr. Fatima specializes in newborn care, child development milestones, vaccinations, and pediatric nutrition guidance with a child-friendly approach.',
      patientsCount: '1,900+',
      reviewsCount: 156,
      reviews: [
        DoctorReview(
          patientName: 'Ayesha Bibi',
          rating: 5.0,
          comment:
              'Great with kids! My son was so comfortable during the whole checkup.',
          date: '5 days ago',
        ),
      ],
    ),
    Doctor(
      id: 'd4',
      name: 'Dr. Omar Sheikh',
      qualification: 'MBBS, MS, FRCS (Orthopedics)',
      specialization: 'Orthopedic Surgeon',
      experience: '20 Years',
      rating: 5.0,
      availability: 'Mon - Thu',
      imageEmoji: '🦴',
      availableSlots: ['09:00 AM', '10:30 AM', '12:00 PM', '03:00 PM'],
      fee: 2500,
      hospitalLocation: 'Joint & Spine Center, Room 108',
      aboutBio:
          'Senior orthopedic surgeon renowned for joint replacement, sports injury rehab, and spine health management with 20+ years of surgical experience.',
      patientsCount: '4,500+',
      reviewsCount: 310,
      reviews: [
        DoctorReview(
          patientName: 'Rehan Farooq',
          rating: 5.0,
          comment:
              'My knee pain is completely gone following Dr. Omar\'s rehabilitation plan. Master of his craft.',
          date: '4 days ago',
        ),
      ],
    ),
    Doctor(
      id: 'd5',
      name: 'Dr. Zara Malik',
      qualification: 'MBBS, FCPS, Board Certified (Dermatology)',
      specialization: 'Dermatologist',
      experience: '6 Years',
      rating: 4.7,
      availability: 'Wed - Mon',
      imageEmoji: '✨',
      availableSlots: [
        '10:00 AM',
        '11:00 AM',
        '01:00 PM',
        '02:00 PM',
        '04:30 PM',
      ],
      fee: 1800,
      hospitalLocation: 'Skin & Aesthetic Care, Room 302',
      aboutBio:
          'Expert dermatologist catering to clinical skin conditions, acne management, allergy treatments, and cosmetic dermatology.',
      patientsCount: '1,400+',
      reviewsCount: 98,
      reviews: [
        DoctorReview(
          patientName: 'Mariam Khan',
          rating: 4.9,
          comment:
              'Visible skin improvement in just 2 weeks! Very customized routine given.',
          date: '1 week ago',
        ),
      ],
    ),
    Doctor(
      id: 'd6',
      name: 'Dr. Bilal Hassan',
      qualification: 'MBBS, FRCP (Gastroenterology)',
      specialization: 'Gastroenterologist',
      experience: '10 Years',
      rating: 4.6,
      availability: 'Mon - Sat',
      imageEmoji: '🩺',
      availableSlots: [
        '09:30 AM',
        '11:00 AM',
        '01:30 PM',
        '03:30 PM',
        '05:00 PM',
      ],
      fee: 1700,
      hospitalLocation: 'Digestive Health Dept, Block C',
      aboutBio:
          'Specialist in digestive health, liver conditions, acid reflux disorders, and endoscopic procedures.',
      patientsCount: '1,750+',
      reviewsCount: 114,
      reviews: [
        DoctorReview(
          patientName: 'Naveed Akhtar',
          rating: 4.7,
          comment:
              'Great treatment for stomach ulcers. Clear lifestyle and diet plan provided.',
          date: '2 weeks ago',
        ),
      ],
    ),
    Doctor(
      id: 'd7',
      name: 'Dr. Hina Qureshi',
      qualification: 'BDS, RDS, M.Orth (Orthodontics)',
      specialization: 'Dentist',
      experience: '9 Years',
      rating: 4.9,
      availability: 'Mon - Fri',
      imageEmoji: '🦷',
      availableSlots: [
        '09:00 AM',
        '10:30 AM',
        '12:00 PM',
        '03:00 PM',
        '04:30 PM',
      ],
      fee: 1400,
      hospitalLocation: 'Dental Excellence Clinic, Floor 2',
      aboutBio:
          'Dr. Hina provides painless dental procedures, smile corrections, root canals, and pediatric dental checkups using modern digital equipment.',
      patientsCount: '2,100+',
      reviewsCount: 165,
      reviews: [
        DoctorReview(
          patientName: 'Zainab Shah',
          rating: 5.0,
          comment:
              'Completely painless tooth filling. Modern clinic and spotless hygiene.',
          date: '3 days ago',
        ),
      ],
    ),
    Doctor(
      id: 'd8',
      name: 'Dr. Kamran Javed',
      qualification: 'MBBS, FCPS (Ophthalmology)',
      specialization: 'Ophthalmologist',
      experience: '11 Years',
      rating: 4.8,
      availability: 'Tue - Sat',
      imageEmoji: '👁️',
      availableSlots: [
        '10:00 AM',
        '11:30 AM',
        '01:00 PM',
        '02:30 PM',
        '04:00 PM',
      ],
      fee: 1600,
      hospitalLocation: 'Vision & Eye Hospital, Room 104',
      aboutBio:
          'Expert ophthalmologist specializing in refractive errors, cataract surgeries, diabetic retinopathy screenings, and pediatric vision therapy.',
      patientsCount: '2,600+',
      reviewsCount: 142,
      reviews: [
        DoctorReview(
          patientName: 'Usman Ghani',
          rating: 4.8,
          comment:
              'Accurate vision testing and got the perfect prescription. Very satisfied.',
          date: '1 week ago',
        ),
      ],
    ),
  ];

  // ─── Firebase Firestore Seeding & Sync ───────────────────────────────────────
  static Future<void> seedDoctorsToFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final collection = firestore.collection('doctors');

      for (final doc in defaultDoctors) {
        final docRef = collection.doc(doc.id);
        batch.set(docRef, {
          'id': doc.id,
          'name': doc.name,
          'qualification': doc.qualification,
          'specialization': doc.specialization,
          'experience': doc.experience,
          'rating': doc.rating,
          'availability': doc.availability,
          'imageEmoji': doc.imageEmoji,
          'availableSlots': doc.availableSlots,
          'fee': doc.fee,
          'hospitalLocation': doc.hospitalLocation,
          'aboutBio': doc.aboutBio,
          'patientsCount': doc.patientsCount,
          'reviewsCount': doc.reviewsCount,
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (_) {}
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
    // 1. Try to fetch from Firestore first
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

    // 2. Fallback to SharedPreferences
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
    final prefs = await SharedPreferences.getInstance();
    final appointments = await getAppointments();
    // Remove if already exists with same id, then prepend
    appointments.removeWhere((a) => a.id == appointment.id);
    appointments.insert(0, appointment);
    await prefs.setString(
      _appointmentsKey,
      jsonEncode(appointments.map((a) => a.toMap()).toList()),
    );

    // Also sync appointment to Firestore 'appointments' collection
    try {
      final firestore = FirebaseFirestore.instance;
      final appointmentRef = firestore
          .collection('appointments')
          .doc(appointment.id);
      await firestore.runTransaction((transaction) async {
        final existing = await transaction.get(appointmentRef);
        if (existing.exists) {
          transaction.set(
            appointmentRef,
            appointment.toMap(),
            SetOptions(merge: true),
          );
          return;
        }
        final conflicts = await firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: appointment.doctorId)
            .where('date', isEqualTo: appointment.date)
            .where('slot', isEqualTo: appointment.slot)
            .get();
        final occupied = conflicts.docs.any((doc) {
          final status = doc.data()['status']?.toString().toLowerCase();
          return status != 'cancelled' && status != 'rejected';
        });
        if (occupied)
          throw StateError(
            'This time slot has just been booked. Please choose another slot.',
          );
        transaction.set(appointmentRef, appointment.toMap());
      });
    } on StateError {
      rethrow;
    } catch (_) {}
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
