import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'doctor_profile_edit_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  String _doctorName = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
    final name = await AuthService.getUserName();
    if (mounted) setState(() => _doctorName = name.trim());
  }

  CollectionReference<Map<String, dynamic>> get _appointments =>
      FirebaseFirestore.instance.collection('appointments');

  Future<void> _updateStatus(
    BuildContext context,
    String id,
    String status, {
    String notes = '',
    String diagnosis = '',
    String medications = '',
    String followUpDate = '',
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (notes.isNotEmpty) {
        updateData['doctorNotes'] = notes;
      }
      if (diagnosis.isNotEmpty) updateData['diagnosis'] = diagnosis;
      if (medications.isNotEmpty) updateData['medications'] = medications;
      if (followUpDate.isNotEmpty) updateData['followUpDate'] = followUpDate;

      await _appointments.doc(id).update(updateData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment $status successfully.'),
            backgroundColor: status == 'Rejected' ? AppTheme.danger : AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update appointment.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _showCompleteDialog(BuildContext context, String id, String patientName) {
    final notesController = TextEditingController();
    final diagnosisController = TextEditingController();
    final medicationsController = TextEditingController();
    final followUpController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Complete Appointment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient: $patientName',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Medical Record',
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: diagnosisController,
              style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Diagnosis',
                labelStyle: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: medicationsController,
              maxLines: 2,
              style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Medicines / Instructions',
                hintText: 'Medicine, dosage and timing',
                labelStyle: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
                hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: followUpController,
              style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Follow-up date (optional)',
                hintText: 'e.g. 20 Sep 2026',
                labelStyle: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
                hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 4,
              style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Prescribed Paracetamol 500mg, rest for 3 days, follow up in 1 week...',
                hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final notes = notesController.text.trim();
              final diagnosis = diagnosisController.text.trim();
              final medications = medicationsController.text.trim();
              final followUpDate = followUpController.text.trim();
              Navigator.pop(ctx);
              _updateStatus(
                context,
                id,
                'Completed',
                notes: notes,
                diagnosis: diagnosis,
                medications: medications,
                followUpDate: followUpDate,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Save & Complete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUser?.uid;
    final appointmentQuery = _appointments.where('doctorId', isEqualTo: uid);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Doctor Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile & Slots',
            icon: const Icon(Icons.manage_accounts_rounded, color: AppTheme.primaryLight),
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorProfileEditScreen()),
              );
              if (res == true) _loadDoctorName();
            },
          ),
          IconButton(
            tooltip: 'Log out',
            icon: Icon(Icons.logout_rounded, color: AppTheme.textMuted),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
              }
            },
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in again.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: appointmentQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load appointments.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final counts = <String, int>{
                  'Pending': 0,
                  'Confirmed': 0,
                  'Completed': 0,
                  'Rejected': 0,
                };
                for (final doc in docs) {
                  final status = doc.data()['status']?.toString() ?? 'Pending';
                  if (counts.containsKey(status)) {
                    counts[status] = counts[status]! + 1;
                  }
                }

                final filteredDocs = docs.where((doc) {
                  if (_selectedFilter == 'All') return true;
                  final status = doc.data()['status']?.toString() ?? 'Pending';
                  return status == _selectedFilter;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Doctor Profile Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: AppTheme.glassBox(borderRadius: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.medical_services_outlined, size: 28),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _doctorName.isNotEmpty ? _doctorName : 'Doctor',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Managing patient consultations & slots',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryLight),
                            tooltip: 'Edit Profile & Slots',
                            onPressed: () async {
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DoctorProfileEditScreen(),
                                ),
                              );
                              if (res == true) _loadDoctorName();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Metrics Counter Cards
                    Row(
                      children: counts.entries.map((entry) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedFilter = entry.key);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _selectedFilter == entry.key
                                    ? AppTheme.primary.withValues(alpha: 0.15)
                                    : AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedFilter == entry.key
                                      ? AppTheme.primary
                                      : AppTheme.borderSubtle,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${entry.value}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: entry.key == 'Pending'
                                          ? AppTheme.warning
                                          : (entry.key == 'Confirmed'
                                              ? AppTheme.primary
                                              : (entry.key == 'Completed'
                                                  ? AppTheme.success
                                                  : AppTheme.danger)),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Filter Chips Bar
                    Row(
                      children: [
                        Text(
                          'Appointments (${filteredDocs.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedFilter != 'All')
                          TextButton(
                            onPressed: () => setState(() => _selectedFilter = 'All'),
                            child: Text(
                              'Show All',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (filteredDocs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        decoration: AppTheme.glassBox(borderRadius: 16),
                        child: Column(
                          children: [
                            Icon(Icons.event_busy_rounded, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              _selectedFilter == 'All'
                                  ? 'No appointments found.'
                                  : 'No $_selectedFilter appointments.',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ...filteredDocs.map((doc) {
                      final data = doc.data();
                      final status = data['status']?.toString() ?? 'Pending';
                      final doctorNotes = data['doctorNotes']?.toString() ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassBox(
                          borderRadius: 18,
                          borderColor: status == 'Pending'
                              ? AppTheme.warning.withValues(alpha: 0.4)
                              : AppTheme.borderSubtle,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data['patientName']?.toString() ?? 'Patient',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                _statusBadge(status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  '${data['date'] ?? ''} at ${data['slot'] ?? ''}',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.phone_outlined, size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  data['patientPhone']?.toString() ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Problem: ${data['problem'] ?? 'General Consultation'}',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            if (doctorNotes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCard2,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.borderSubtle),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.note_alt_outlined,
                                      size: 16,
                                      color: AppTheme.primaryLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Doctor Notes: $doctorNotes',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (status == 'Pending') ...[
                                  TextButton.icon(
                                    onPressed: () => _updateStatus(context, doc.id, 'Rejected'),
                                    icon: const Icon(Icons.close_rounded, size: 16),
                                    label: const Text('Reject'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.danger,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _updateStatus(context, doc.id, 'Confirmed'),
                                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                                    label: const Text('Confirm'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ] else if (status == 'Confirmed') ...[
                                  ElevatedButton.icon(
                                    onPressed: () => _showCompleteDialog(
                                      context,
                                      doc.id,
                                      data['patientName']?.toString() ?? 'Patient',
                                    ),
                                    icon: const Icon(Icons.task_alt_rounded, size: 16),
                                    label: const Text('Complete & Add Notes'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.success,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Confirmed':
        bg = AppTheme.primary.withValues(alpha: 0.15);
        fg = AppTheme.primaryLight;
        break;
      case 'Completed':
        bg = AppTheme.success.withValues(alpha: 0.15);
        fg = AppTheme.success;
        break;
      case 'Rejected':
        bg = AppTheme.danger.withValues(alpha: 0.15);
        fg = AppTheme.danger;
        break;
      default:
        bg = AppTheme.warning.withValues(alpha: 0.15);
        fg = AppTheme.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
