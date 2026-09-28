import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final _firestore = FirebaseFirestore.instance;

  Future<void> _updateStatus(String docId, String status) async {
    await _firestore.collection('appointments').doc(docId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment status changed to $status.')),
      );
    }
  }

  void _showStatusOverrideDialog(String docId, String currentStatus) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Override Appointment Status',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        children: ['Pending', 'Confirmed', 'Completed', 'Cancelled', 'Rejected'].map((status) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(docId, status);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    status == currentStatus
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontWeight: status == currentStatus ? FontWeight.w700 : FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'All Appointments',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled', 'Rejected'].map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                    backgroundColor: AppTheme.bgCard,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.25),
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.borderSubtle,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by Doctor or Patient name...',
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('appointments').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load appointments.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final status = data['status']?.toString() ?? 'Pending';
                  if (_selectedStatus != 'All' && status != _selectedStatus) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    final doctor = data['doctorName']?.toString().toLowerCase() ?? '';
                    final patient = data['patientName']?.toString().toLowerCase() ?? '';
                    return doctor.contains(_searchQuery) || patient.contains(_searchQuery);
                  }
                  return true;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No matching appointments found.',
                      style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, idx) {
                    final doc = docs[idx];
                    final data = doc.data();
                    final status = data['status']?.toString() ?? 'Pending';
                    final docNotes = data['doctorNotes']?.toString() ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassBox(borderRadius: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['doctorName']?.toString() ?? 'Doctor',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              _statusChip(status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Patient: ${data['patientName'] ?? 'Anonymous'} (${data['patientPhone'] ?? 'No phone'})',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Schedule: ${data['date']} at ${data['slot']}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryLight,
                              fontSize: 12,
                            ),
                          ),
                          if (data['problem'] != null)
                            Text(
                              'Problem: ${data['problem']}',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          if (docNotes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Doctor Notes: $docNotes',
                              style: GoogleFonts.poppins(
                                color: AppTheme.success,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showStatusOverrideDialog(doc.id, status),
                                icon: const Icon(Icons.edit_note_rounded, size: 18),
                                label: const Text('Change Status'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'Confirmed':
        color = AppTheme.primary;
        break;
      case 'Completed':
        color = AppTheme.success;
        break;
      case 'Cancelled':
      case 'Rejected':
        color = AppTheme.danger;
        break;
      default:
        color = AppTheme.warning;
    }
    return Chip(
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      label: Text(
        status,
        style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}
