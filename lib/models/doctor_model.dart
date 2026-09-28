import 'package:flutter/material.dart';

class DoctorReview {
  final String patientName;
  final double rating;
  final String comment;
  final String date;

  DoctorReview({
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }

  factory DoctorReview.fromMap(Map<String, dynamic> map) {
    return DoctorReview(
      patientName: map['patientName'] ?? 'Anonymous Patient',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 5.0,
      comment: map['comment'] ?? 'Excellent consultation and care.',
      date: map['date'] ?? 'Recently',
    );
  }
}

class Doctor {
  final String id;
  final String userId;
  final String name;
  final String qualification;
  final String specialization;
  final String experience;
  final String gender;
  final double rating;
  final String availability;
  final String imageEmoji;
  final List<String> availableSlots;
  final int fee;
  final String hospitalLocation;
  final String aboutBio;
  final String patientsCount;
  final int reviewsCount;
  final List<DoctorReview> reviews;

  Doctor({
    required this.id,
    this.userId = '',
    required this.name,
    required this.qualification,
    required this.specialization,
    required this.experience,
    this.gender = '',
    required this.rating,
    required this.availability,
    required this.imageEmoji,
    required this.availableSlots,
    required this.fee,
    this.hospitalLocation = 'MediCare Central Hospital, Islamabad - OPD Block A',
    this.aboutBio = '',
    this.patientsCount = '1,200+',
    this.reviewsCount = 120,
    this.reviews = const [],
  });

  IconData get genderIcon {
    switch (gender) {
      case 'female':
        return Icons.woman_rounded;
      case 'male':
        return Icons.man_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'qualification': qualification,
      'specialization': specialization,
      'experience': experience,
      'gender': gender,
      'rating': rating,
      'availability': availability,
      'imageEmoji': imageEmoji,
      'availableSlots': availableSlots.join(','),
      'fee': fee,
      'hospitalLocation': hospitalLocation,
      'aboutBio': aboutBio,
      'patientsCount': patientsCount,
      'reviewsCount': reviewsCount,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    List<String> slots = [];
    if (map['availableSlots'] is List) {
      slots = List<String>.from(map['availableSlots']);
    } else if (map['availableSlots'] is String) {
      slots = (map['availableSlots'] as String)
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return Doctor(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Dr. Specialist',
      qualification: map['qualification']?.toString() ?? 'MBBS',
      specialization: map['specialization']?.toString() ?? 'General Physician',
      experience: map['experience']?.toString() ?? '5+ Years',
      gender: map['gender']?.toString().toLowerCase().trim() ?? '',
      rating: map['rating'] is num
          ? (map['rating'] as num).toDouble()
          : double.tryParse(map['rating']?.toString() ?? '4.8') ?? 4.8,
      availability: map['availability']?.toString() ?? 'Mon - Sat',
      imageEmoji: _safeImageLabel(map['imageEmoji']),
      availableSlots: slots.isNotEmpty
          ? slots
          : ['09:00 AM', '11:00 AM', '02:00 PM'],
      fee: map['fee'] is num
          ? (map['fee'] as num).toInt()
          : int.tryParse(map['fee']?.toString() ?? '1500') ?? 1500,
      hospitalLocation:
          map['hospitalLocation']?.toString() ??
          'MediCare Central Hospital, Islamabad - OPD Block A',
      aboutBio: map['aboutBio']?.toString() ?? '',
      patientsCount: map['patientsCount']?.toString() ?? '1,200+',
      reviewsCount: map['reviewsCount'] is num
          ? (map['reviewsCount'] as num).toInt()
          : int.tryParse(map['reviewsCount']?.toString() ?? '120') ?? 120,
    );
  }
}

String _safeImageLabel(Object? value) {
  final label = value?.toString() ?? '';
  return label.isNotEmpty && label.runes.every((rune) => rune <= 0x7F)
      ? label
      : 'Doctor';
}
