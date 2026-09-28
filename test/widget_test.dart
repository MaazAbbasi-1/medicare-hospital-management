import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management/models/user_model.dart';
import 'package:hospital_management/models/doctor_model.dart';
import 'package:hospital_management/models/condition_model.dart';

void main() {
  test('Condition specialty matcher should handle common aliases and synonyms', () {
    expect(
      Condition.matchesDoctorSpecialization(
        'Gastroenterologist',
        'Gastroenterologist',
      ),
      isTrue,
    );
    expect(
      Condition.matchesDoctorSpecialization(
        'General Physician',
        'General Practitioner',
      ),
      isTrue,
    );
    expect(
      Condition.matchesDoctorSpecialization(
        'Eye Specialist',
        'Ophthalmologist',
      ),
      isTrue,
    );
    expect(
      Condition.matchesDoctorSpecialization(
        'General Surgeon',
        'Surgeon',
      ),
      isTrue,
    );
    expect(
      Condition.matchesDoctorSpecialization(
        'Cardiologist',
        'Dermatologist',
      ),
      isFalse,
    );
  });

  test('UserModel serialization and deserialization test', () {
    final user = UserModel(
      uid: 'user123',
      name: 'Ahmed Khan',
      email: 'ahmed@example.com',
      phone: '+923001234567',
      createdAt: '2026-08-17T12:00:00.000Z',
    );

    final map = user.toMap();
    expect(map['uid'], 'user123');
    expect(map['name'], 'Ahmed Khan');
    expect(map['email'], 'ahmed@example.com');
    expect(map['phone'], '+923001234567');

    final fromMapUser = UserModel.fromMap(map);
    expect(fromMapUser.uid, user.uid);
    expect(fromMapUser.name, user.name);
    expect(fromMapUser.email, user.email);
    expect(fromMapUser.phone, user.phone);
  });

  test('Doctor model test', () {
    final doctor = Doctor(
      id: 'd1',
      name: 'Dr. Sarah Khan',
      qualification: 'MBBS, MD',
      specialization: 'Cardiologist',
      experience: '10 Years',
      rating: 4.9,
      availability: 'Mon - Fri',
      imageEmoji: '👩‍⚕️',
      availableSlots: ['09:00 AM', '10:00 AM'],
      fee: 1500,
    );

    expect(doctor.name, 'Dr. Sarah Khan');
    expect(doctor.availableSlots.length, 2);
    expect(doctor.fee, 1500);
  });

  test('Consult online feature should be removed from the app UI', () {
    final homeScreen = File('lib/screens/home_screen.dart').readAsStringSync();
    final doctorDetailScreen =
        File('lib/screens/doctor_detail_screen.dart').readAsStringSync();

    expect(homeScreen.contains('Consult Online Now'), isFalse);
    expect(homeScreen.contains('OnlineConsultationScreen'), isFalse);
    expect(doctorDetailScreen.contains('📹 Online'), isFalse);
    expect(doctorDetailScreen.contains('OnlineConsultationScreen'), isFalse);
  });
}
