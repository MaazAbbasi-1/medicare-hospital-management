class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String patientName;
  final String patientAge;
  final String patientPhone;
  final String slot;
  final String date;
  final String status;
  final String problem;
  final String patientId;
  final String doctorNotes;
  final String diagnosis;
  final String medications;
  final String followUpDate;
  final int fee;
  final String type;
  final String createdAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.patientName,
    required this.patientAge,
    required this.patientPhone,
    required this.slot,
    required this.date,
    required this.status,
    required this.problem,
    this.patientId = '',
    this.doctorNotes = '',
    this.diagnosis = '',
    this.medications = '',
    this.followUpDate = '',
    this.fee = 1500,
    this.type = 'In-Person',
    this.createdAt = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientPhone': patientPhone,
      'slot': slot,
      'date': date,
      'status': status,
      'problem': problem,
      'patientId': patientId,
      'doctorNotes': doctorNotes,
      'diagnosis': diagnosis,
      'medications': medications,
      'followUpDate': followUpDate,
      'fee': fee,
      'type': type,
      'createdAt': createdAt.isNotEmpty ? createdAt : DateTime.now().toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id']?.toString() ?? '',
      doctorId: map['doctorId']?.toString() ?? '',
      doctorName: map['doctorName']?.toString() ?? '',
      doctorSpecialization: map['doctorSpecialization']?.toString() ?? '',
      patientName: map['patientName']?.toString() ?? '',
      patientAge: map['patientAge']?.toString() ?? '',
      patientPhone: map['patientPhone']?.toString() ?? '',
      slot: map['slot']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Pending',
      problem: map['problem']?.toString() ?? '',
      patientId: map['patientId']?.toString() ?? '',
      doctorNotes: map['doctorNotes']?.toString() ?? '',
      diagnosis: map['diagnosis']?.toString() ?? '',
      medications: map['medications']?.toString() ?? '',
      followUpDate: map['followUpDate']?.toString() ?? '',
      fee: map['fee'] is num
          ? (map['fee'] as num).toInt()
          : int.tryParse(map['fee']?.toString() ?? '1500') ?? 1500,
      type: map['type']?.toString() ?? 'In-Person',
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  Appointment copyWith({
    String? status,
    String? doctorNotes,
    String? diagnosis,
    String? medications,
    String? followUpDate,
    String? date,
    String? slot,
  }) {
    return Appointment(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      patientName: patientName,
      patientAge: patientAge,
      patientPhone: patientPhone,
      slot: slot ?? this.slot,
      date: date ?? this.date,
      status: status ?? this.status,
      problem: problem,
      patientId: patientId,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      diagnosis: diagnosis ?? this.diagnosis,
      medications: medications ?? this.medications,
      followUpDate: followUpDate ?? this.followUpDate,
      fee: fee,
      type: type,
      createdAt: createdAt,
    );
  }
}
