import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  String _doctorName = '';

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
    String status,
  ) async {
    try {
      await _appointments.doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Appointment $status.')));
    } catch (_) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update appointment.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUser?.uid;
    // Query by doctor name to show all appointments for this doctor
    // Works for both Firebase doctors and default doctors
    final appointmentQuery = _doctorName.isNotEmpty
        ? _appointments.where('doctorName', isEqualTo: _doctorName)
        : _appointments.where('doctorId', isEqualTo: uid);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doctor Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted)
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (_) => false);
            },
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in again.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: appointmentQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(
                    child: Text('Unable to load appointments.'),
                  );
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                final counts = <String, int>{
                  'Pending': 0,
                  'Confirmed': 0,
                  'Completed': 0,
                };
                for (final doc in docs) {
                  final status = doc.data()['status']?.toString() ?? 'Pending';
                  if (counts.containsKey(status))
                    counts[status] = counts[status]! + 1;
                }
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    FutureBuilder<String>(
                      future: AuthService.getUserName(),
                      builder: (_, name) => Text(
                        'Welcome, ${name.data ?? 'Doctor'}',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: counts.entries.map((entry) {
                        return Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text(
                                    '${entry.value}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
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
                    const SizedBox(height: 24),
                    Text(
                      'Appointment Requests',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (docs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text('No appointment requests yet.'),
                        ),
                      ),
                    ...docs.map((doc) {
                      final data = doc.data();
                      final status = data['status']?.toString() ?? 'Pending';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['patientName']?.toString() ?? 'Patient',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '${data['date'] ?? ''} at ${data['slot'] ?? ''}',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                'Reason: ${data['problem'] ?? 'General consultation'}',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(label: Text(status)),
                                  const Spacer(),
                                  if (status == 'Pending') ...[
                                    TextButton(
                                      onPressed: () => _updateStatus(
                                        context,
                                        doc.id,
                                        'Rejected',
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(
                                        context,
                                        doc.id,
                                        'Confirmed',
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_outline_rounded,
                                              size: 16),
                                          SizedBox(width: 6),
                                          Text('Confirm'),
                                        ],
                                      ),
                                    ),
                                  ] else if (status == 'Confirmed')
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(
                                        context,
                                        doc.id,
                                        'Completed',
                                      ),
                                      child: const Text('Complete'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }
}
