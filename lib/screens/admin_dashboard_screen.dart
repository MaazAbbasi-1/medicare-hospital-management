import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'admin_doctors_screen.dart';
import 'admin_users_screen.dart';
import 'admin_appointments_screen.dart';

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
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // Header Banner
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
                    child: Icon(Icons.shield_outlined, size: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hospital Administration',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Full control over doctors, users & appointments',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'System Overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Grid of Stat Cards
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Total Doctors',
                  _count('doctors'),
                  Icons.medical_services_rounded,
                  AppTheme.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDoctorsScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Total Patients',
                  _count('users', role: 'patient'),
                  Icons.people_alt_rounded,
                  AppTheme.secondary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Total Appointments',
                  _count('appointments'),
                  Icons.calendar_month_rounded,
                  AppTheme.primaryLight,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAppointmentsScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Pending Actions',
                  _count('appointments', status: 'Pending'),
                  Icons.pending_actions_rounded,
                  AppTheme.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAppointmentsScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Management Portals',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Portal navigation cards
          _portalCard(
            context,
            title: 'Doctors Management',
            subtitle: 'Add new doctors, edit profiles, fees & schedules',
            icon: Icons.medical_services_outlined,
            color: AppTheme.primary,
            destination: const AdminDoctorsScreen(),
          ),
          const SizedBox(height: 10),

          _portalCard(
            context,
            title: 'Patients & Users Directory',
            subtitle: 'View registered patients, contact info & booking history',
            icon: Icons.people_outline_rounded,
            color: AppTheme.secondary,
            destination: const AdminUsersScreen(),
          ),
          const SizedBox(height: 10),

          _portalCard(
            context,
            title: 'Global Appointments Oversight',
            subtitle: 'Filter, review, and override all appointment statuses',
            icon: Icons.assignment_outlined,
            color: AppTheme.primaryLight,
            destination: const AdminAppointmentsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String label,
    Stream<int> stream,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassBox(borderRadius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<int>(
              stream: stream,
              builder: (_, snapshot) => Text(
                '${snapshot.data ?? 0}',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _portalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Container(
      decoration: AppTheme.glassBox(borderRadius: 18),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textMuted,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        ),
      ),
    );
  }
}
