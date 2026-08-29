class OnlineConsultation {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String patientId;
  final String patientName;
  final String status; // 'scheduled', 'active', 'completed', 'cancelled'
  final String consultationType; // 'video', 'voice', 'chat'
  final DateTime scheduledTime;
  final int durationMinutes;
  final String problem;
  final String roomId;
  final String? recordingUrl;
  final String? prescription;
  final int feeAmount;
  final bool isPaymentDone;

  OnlineConsultation({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.patientId,
    required this.patientName,
    required this.status,
    required this.consultationType,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.problem,
    required this.roomId,
    this.recordingUrl,
    this.prescription,
    required this.feeAmount,
    required this.isPaymentDone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'patientId': patientId,
      'patientName': patientName,
      'status': status,
      'consultationType': consultationType,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'problem': problem,
      'roomId': roomId,
      'recordingUrl': recordingUrl,
      'prescription': prescription,
      'feeAmount': feeAmount,
      'isPaymentDone': isPaymentDone,
    };
  }

  factory OnlineConsultation.fromMap(Map<String, dynamic> map) {
    return OnlineConsultation(
      id: map['id'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? 'Dr. Unknown',
      doctorSpecialization: map['doctorSpecialization'] ?? 'General',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? 'Patient',
      status: map['status'] ?? 'scheduled',
      consultationType: map['consultationType'] ?? 'video',
      scheduledTime: DateTime.parse(map['scheduledTime'] ?? DateTime.now().toIso8601String()),
      durationMinutes: map['durationMinutes'] ?? 30,
      problem: map['problem'] ?? 'General consultation',
      roomId: map['roomId'] ?? '',
      recordingUrl: map['recordingUrl'],
      prescription: map['prescription'],
      feeAmount: map['feeAmount'] ?? 1000,
      isPaymentDone: map['isPaymentDone'] ?? false,
    );
  }
}
