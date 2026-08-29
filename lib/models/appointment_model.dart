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
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      doctorId: map['doctorId'],
      doctorName: map['doctorName'],
      doctorSpecialization: map['doctorSpecialization'],
      patientName: map['patientName'],
      patientAge: map['patientAge'],
      patientPhone: map['patientPhone'],
      slot: map['slot'],
      date: map['date'],
      status: map['status'],
      problem: map['problem'],
      patientId: map['patientId']?.toString() ?? '',
    );
  }

  Appointment copyWith({String? status}) {
    return Appointment(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      patientName: patientName,
      patientAge: patientAge,
      patientPhone: patientPhone,
      slot: slot,
      date: date,
      status: status ?? this.status,
      problem: problem,
      patientId: patientId,
    );
  }
}
