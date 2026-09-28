import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';
  final _firestore = FirebaseFirestore.instance;

  void _showUserAppointments(String userId, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Bookings for $userName',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.borderSubtle),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('appointments')
                    .where('patientId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading patient bookings.'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No appointments booked by this patient.',
                        style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, idx) {
                      final data = docs[idx].data();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            data['doctorName'] ?? 'Doctor Consultation',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${data['date']} at ${data['slot']} • ${data['problem'] ?? ''}',
                          ),
                          trailing: Chip(
                            label: Text(
                              data['status'] ?? 'Pending',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
          'Registered Patients',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search patients by name, email, or phone...',
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load users.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter out non-patients or show role
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final email = data['email']?.toString().toLowerCase() ?? '';
                  final phone = data['phone']?.toString().toLowerCase() ?? '';
                  final matchesSearch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      phone.contains(_searchQuery);
                  return matchesSearch;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No users registered yet.',
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
                    final name = data['name']?.toString() ?? 'User';
                    final email = data['email']?.toString() ?? 'No email';
                    final phone = data['phone']?.toString() ?? '';
                    final role = data['role']?.toString() ?? 'patient';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassBox(borderRadius: 18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: role == 'doctor'
                                ? AppTheme.primary
                                : (role == 'admin' ? AppTheme.warning : AppTheme.secondary),
                            radius: 22,
                            child: Icon(
                              role == 'doctor'
                                  ? Icons.medical_services_rounded
                                  : (role == 'admin'
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.person_rounded),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.bgCard2,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        role.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                if (phone.isNotEmpty)
                                  Text(
                                    phone,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.history_rounded,
                              color: AppTheme.primaryLight,
                            ),
                            tooltip: 'View Bookings',
                            onPressed: () => _showUserAppointments(doc.id, name),
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
}
