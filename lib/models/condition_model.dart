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
}

final List<Condition> commonConditions = [
  Condition(
    id: 'fever',
    name: 'Fever/Cold',
    description: 'Treat fever and cold symptoms',
    icon: '🤧',
    relatedSpecialties: ['General Physician', 'Pediatrician'],
    symptoms: ['High Temperature', 'Runny Nose', 'Cough', 'Body Aches'],
  ),
  Condition(
    id: 'heart',
    name: 'Heart Attack',
    description: 'Cardiac emergency & chest pain',
    icon: '❤️',
    relatedSpecialties: ['Cardiologist'],
    symptoms: ['Chest Pain', 'Shortness of Breath', 'Dizziness'],
  ),
  Condition(
    id: 'pregnancy',
    name: 'Pregnancy',
    description: 'Prenatal & postnatal care',
    icon: '🤰',
    relatedSpecialties: ['Gynecologist'],
    symptoms: ['Nausea', 'Fatigue', 'Abdominal Pain'],
  ),
  Condition(
    id: 'bp',
    name: 'Blood Pressure',
    description: 'Hypertension management',
    icon: '💊',
    relatedSpecialties: ['Cardiologist', 'General Physician'],
    symptoms: ['Headache', 'Dizziness', 'Shortness of Breath'],
  ),
  Condition(
    id: 'piles',
    name: 'Piles/Hemorrhoids',
    description: 'Hemorrhoid treatment',
    icon: '🩹',
    relatedSpecialties: ['Gastroenterologist', 'General Surgeon'],
    symptoms: ['Anal Pain', 'Bleeding', 'Itching'],
  ),
  Condition(
    id: 'diarrhea',
    name: 'Diarrhea',
    description: 'Digestive issues treatment',
    icon: '🤢',
    relatedSpecialties: ['Gastroenterologist', 'General Physician'],
    symptoms: ['Loose Stool', 'Abdominal Cramps', 'Dehydration'],
  ),
  Condition(
    id: 'skin',
    name: 'Skin Rash',
    description: 'Skin allergies & rashes',
    icon: '🩹',
    relatedSpecialties: ['Dermatologist'],
    symptoms: ['Itching', 'Redness', 'Swelling'],
  ),
  Condition(
    id: 'migraine',
    name: 'Migraine/Headache',
    description: 'Chronic headache relief',
    icon: '🤕',
    relatedSpecialties: ['Neurologist', 'General Physician'],
    symptoms: ['Severe Headache', 'Sensitivity to Light', 'Nausea'],
  ),
  Condition(
    id: 'teeth',
    name: 'Teeth/Dental',
    description: 'Dental care & treatment',
    icon: '🦷',
    relatedSpecialties: ['Dentist'],
    symptoms: ['Tooth Pain', 'Bleeding Gums', 'Cavities'],
  ),
  Condition(
    id: 'eye',
    name: 'Eye Issues',
    description: 'Vision & eye problems',
    icon: '👁️',
    relatedSpecialties: ['Ophthalmologist', 'Eye Specialist'],
    symptoms: ['Blurred Vision', 'Eye Pain', 'Redness'],
  ),
];
