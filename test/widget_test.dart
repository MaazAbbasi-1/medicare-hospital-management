import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management/models/user_model.dart';
import 'package:hospital_management/models/doctor_model.dart';

void main() {
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
}
