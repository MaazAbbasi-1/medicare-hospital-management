import 'package:flutter/material.dart';

class Condition {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> relatedSpecialties;
  final List<String> symptoms;

  Condition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.relatedSpecialties,
    required this.symptoms,
  });

  static String _normalizeSpecialty(String value) {
    final compact = value
        .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    const aliases = {
      'general physician': 'general physician',
      'general practitioner': 'general physician',
      'family physician': 'general physician',
      'general medicine': 'general physician',
      'gp': 'general physician',
      'cardiologist': 'cardiologist',
      'cardiology': 'cardiologist',
      'heart specialist': 'cardiologist',
      'gastroenterologist': 'gastroenterologist',
      'gastroenterology': 'gastroenterologist',
      'gastro': 'gastroenterologist',
      'general surgeon': 'general surgeon',
      'general surgery': 'general surgeon',
      'surgeon': 'general surgeon',
      'dermatologist': 'dermatologist',
      'dermatology': 'dermatologist',
      'skin specialist': 'dermatologist',
      'neurologist': 'neurologist',
      'neurology': 'neurologist',
      'neuro specialist': 'neurologist',
      'ophthalmologist': 'ophthalmologist',
      'ophthalmology': 'ophthalmologist',
      'eye specialist': 'ophthalmologist',
      'eye doctor': 'ophthalmologist',
      'dentist': 'dentist',
      'dentistry': 'dentist',
      'dental surgeon': 'dentist',
      'pediatrician': 'pediatrician',
      'paediatrician': 'pediatrician',
      'pediatrics': 'pediatrician',
      'paediatrics': 'pediatrician',
      'child specialist': 'pediatrician',
      'gynecologist': 'gynecologist',
      'gynecology': 'gynecologist',
      'obgyn': 'gynecologist',
      'gynae': 'gynecologist',
      'obstetrician': 'gynecologist',
      'obstetrician and gynecologist': 'gynecologist',
    };

    final normalized = aliases[compact] ?? compact;
    return normalized.endsWith('s') && normalized.length > 3
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  static bool matchesDoctorSpecialization(
    String specialty,
    String doctorSpecialization,
  ) {
    final normalizedSpecialty = _normalizeSpecialty(specialty);
    final normalizedDoctor = _normalizeSpecialty(doctorSpecialization);

    if (normalizedSpecialty.isEmpty || normalizedDoctor.isEmpty) {
      return false;
    }

    if (normalizedSpecialty == normalizedDoctor) {
      return true;
    }

    final specialtyFamily = _specialtyFamily(normalizedSpecialty);
    final doctorFamily = _specialtyFamily(normalizedDoctor);
    if (specialtyFamily != null || doctorFamily != null) {
      return specialtyFamily != null && specialtyFamily == doctorFamily;
    }

    return normalizedSpecialty.contains(normalizedDoctor) ||
        normalizedDoctor.contains(normalizedSpecialty);
  }

  static String? _specialtyFamily(String value) {
    const families = {
      'general physician': [
        'general physician',
        'general practitioner',
        'family physician',
        'general medicine',
        'physician',
      ],
      'cardiologist': ['cardiologist', 'cardiology', 'cardiac', 'heart'],
      'gastroenterologist': ['gastroenterologist', 'gastroenterology', 'gastro'],
      'general surgeon': ['general surgeon', 'general surgery', 'surgeon'],
      'dermatologist': ['dermatologist', 'dermatology', 'skin'],
      'neurologist': ['neurologist', 'neurology', 'neuro'],
      'ophthalmologist': ['ophthalmologist', 'ophthalmology', 'eye'],
      'dentist': ['dentist', 'dentistry', 'dental'],
      'pediatrician': ['pediatrician', 'paediatrician', 'pediatrics', 'child'],
      'gynecologist': ['gynecologist', 'gynecology', 'obgyn', 'gynae', 'obstetrician'],
    };

    for (final entry in families.entries) {
      if (entry.value.any(value.contains)) return entry.key;
    }
    return null;
  }

  IconData get materialIcon {
    switch (id) {
      case 'fever':
        return Icons.thermostat_rounded;
      case 'heart':
        return Icons.favorite_rounded;
      case 'pregnancy':
        return Icons.pregnant_woman_rounded;
      case 'bp':
        return Icons.monitor_heart_rounded;
      case 'piles':
        return Icons.healing_rounded;
      case 'diarrhea':
        return Icons.water_drop_rounded;
      case 'skin':
        return Icons.face_retouching_natural_rounded;
      case 'migraine':
        return Icons.psychology_rounded;
      case 'teeth':
        return Icons.sentiment_very_satisfied_rounded;
      case 'eye':
        return Icons.visibility_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }
}

final List<Condition> commonConditions = [
  Condition(
    id: 'fever',
    name: 'Fever/Cold',
    description: 'Treat fever and cold symptoms',
    icon: 'FC',
    relatedSpecialties: ['General Physician', 'Pediatrician'],
    symptoms: ['High Temperature', 'Runny Nose', 'Cough', 'Body Aches'],
  ),
  Condition(
    id: 'heart',
    name: 'Heart Attack',
    description: 'Cardiac emergency & chest pain',
    icon: 'HR',
    relatedSpecialties: ['Cardiologist'],
    symptoms: ['Chest Pain', 'Shortness of Breath', 'Dizziness'],
  ),
  Condition(
    id: 'pregnancy',
    name: 'Pregnancy',
    description: 'Prenatal & postnatal care',
    icon: 'PR',
    relatedSpecialties: ['Gynecologist'],
    symptoms: ['Nausea', 'Fatigue', 'Abdominal Pain'],
  ),
  Condition(
    id: 'bp',
    name: 'Blood Pressure',
    description: 'Hypertension management',
    icon: 'BP',
    relatedSpecialties: ['Cardiologist', 'General Physician'],
    symptoms: ['Headache', 'Dizziness', 'Shortness of Breath'],
  ),
  Condition(
    id: 'piles',
    name: 'Piles/Hemorrhoids',
    description: 'Hemorrhoid treatment',
    icon: 'PL',
    relatedSpecialties: ['Gastroenterologist', 'General Surgeon'],
    symptoms: ['Anal Pain', 'Bleeding', 'Itching'],
  ),
  Condition(
    id: 'diarrhea',
    name: 'Diarrhea',
    description: 'Digestive issues treatment',
    icon: 'DG',
    relatedSpecialties: ['Gastroenterologist', 'General Physician'],
    symptoms: ['Loose Stool', 'Abdominal Cramps', 'Dehydration'],
  ),
  Condition(
    id: 'skin',
    name: 'Skin Rash',
    description: 'Skin allergies & rashes',
    icon: 'SK',
    relatedSpecialties: ['Dermatologist'],
    symptoms: ['Itching', 'Redness', 'Swelling'],
  ),
  Condition(
    id: 'migraine',
    name: 'Migraine/Headache',
    description: 'Chronic headache relief',
    icon: 'MG',
    relatedSpecialties: ['Neurologist', 'General Physician'],
    symptoms: ['Severe Headache', 'Sensitivity to Light', 'Nausea'],
  ),
  Condition(
    id: 'teeth',
    name: 'Teeth/Dental',
    description: 'Dental care & treatment',
    icon: 'DN',
    relatedSpecialties: ['Dentist'],
    symptoms: ['Tooth Pain', 'Bleeding Gums', 'Cavities'],
  ),
  Condition(
    id: 'eye',
    name: 'Eye Issues',
    description: 'Vision & eye problems',
    icon: 'EY',
    relatedSpecialties: ['Ophthalmologist', 'Eye Specialist'],
    symptoms: ['Blurred Vision', 'Eye Pain', 'Redness'],
  ),
];
