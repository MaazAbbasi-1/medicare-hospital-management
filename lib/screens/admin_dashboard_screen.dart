import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Stream<int> _count(String collection, {String? role, String? status}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      collection,
    );
    if (role != null) query = query.where('role', isEqualTo: role);
    if (status != null) query = query.where('status', isEqualTo: status);
    return query.snapshots().map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'System overview',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          _statCard(
            'Total Doctors',
            _count('users', role: 'doctor'),
            Icons.medical_services_rounded,
          ),
          _statCard(
            'Total Patients',
            _count('users', role: 'patient'),
            Icons.people_alt_rounded,
          ),
          _statCard(
            'Total Appointments',
            _count('appointments'),
            Icons.calendar_month_rounded,
          ),
          _statCard(
            'Pending Appointments',
            _count('appointments', status: 'Pending'),
            Icons.pending_actions_rounded,
          ),
          const SizedBox(height: 16),
          Text(
            'Management',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.medical_services_outlined),
            title: Text('Doctor accounts'),
            subtitle: Text('Manage profiles and activation status'),
          ),
          const ListTile(
            leading: Icon(Icons.people_outline),
            title: Text('Patients'),
            subtitle: Text('View registered patient accounts'),
          ),
          const ListTile(
            leading: Icon(Icons.assignment_outlined),
            title: Text('Appointments'),
            subtitle: Text('Review and manage appointment status'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, Stream<int> stream, IconData icon) =>
      StreamBuilder<int>(
        stream: stream,
        builder: (_, snapshot) => Card(
          child: ListTile(
            leading: Icon(icon, color: AppTheme.primary),
            title: Text(
              '${snapshot.data ?? 0}',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(label),
          ),
        ),
      );
}
