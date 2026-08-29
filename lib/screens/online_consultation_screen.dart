import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/consultation_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class OnlineConsultationScreen extends StatefulWidget {
  final Doctor doctor;
  const OnlineConsultationScreen({super.key, required this.doctor});

  @override
  State<OnlineConsultationScreen> createState() =>
      _OnlineConsultationScreenState();
}

class _OnlineConsultationScreenState extends State<OnlineConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay(hour: 10, minute: 0);
  String _consultationType = 'video';
  int _durationMinutes = 30;
  bool _isLoading = false;

  final List<int> _durationOptions = [15, 30, 45, 60];
  final List<String> _consultationTypes = [
    'Video Call 📹',
    'Voice Call 🎙️',
    'Chat 💬'
  ];

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _bookConsultation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final consultation = OnlineConsultation(
      id: const Uuid().v4(),
      doctorId: widget.doctor.id,
      doctorName: widget.doctor.name,
      doctorSpecialization: widget.doctor.specialization,
      patientId: AuthService.currentUser?.uid ?? '',
      patientName: await AuthService.getUserName(),
      status: 'scheduled',
      consultationType: _consultationType,
      scheduledTime: scheduledDateTime,
      durationMinutes: _durationMinutes,
      problem: _problemController.text.trim(),
      roomId: const Uuid().v4(),
      feeAmount: widget.doctor.fee,
      isPaymentDone: false,
    );

    try {
      // Save consultation to Firestore
      await FirebaseFirestore.instance
          .collection('consultations')
          .doc(consultation.id)
          .set(consultation.toMap());

      setState(() => _isLoading = false);

      if (mounted) {
        _showSuccessDialog(consultation);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showSuccessDialog(OnlineConsultation consultation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Consultation Scheduled! ✓',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dr. ${widget.doctor.name}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEE, d MMM • h:mm a').format(consultation.scheduledTime),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${consultation.durationMinutes} minutes',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'You will receive a link to join the consultation 15 minutes before the scheduled time.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Book Online Consultation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Doctor Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      widget.doctor.imageEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctor.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.doctor.specialization,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.doctor.rating}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Rs. ${widget.doctor.fee}',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Consultation Type
            Text(
              'Consultation Type',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _consultationTypes.length,
              itemBuilder: (context, index) {
                final types = ['video', 'voice', 'chat'];
                final isSelected = _consultationType == types[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _consultationType = types[index]);
                  },
                  child: Card(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    child: Center(
                      child: Text(
                        _consultationTypes[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Date Selection
            Text(
              'Select Date',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEE, d MMM yyyy').format(_selectedDate),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time Selection
            Text(
              'Select Time',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) {
                  setState(() => _selectedTime = picked);
                }
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Duration Selection
            Text(
              'Consultation Duration',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _durationMinutes,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _durationMinutes = value);
                }
              },
              items: _durationOptions
                  .map((duration) => DropdownMenuItem(
                        value: duration,
                        child: Text('$duration minutes'),
                      ))
                  .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Problem/Symptoms
            Text(
              'Your Problem/Symptoms',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _problemController,
              maxLines: 4,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please describe your problem';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Describe your symptoms or concerns...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Book Button
            ElevatedButton(
              onPressed: _isLoading ? null : _bookConsultation,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Book Consultation'),
            ),
          ],
        ),
      ),
    );
  }
}
