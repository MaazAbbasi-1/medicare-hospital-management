import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/appointment_model.dart';
import '../services/data_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final list = await DataService.getAppointments();
    if (mounted) {
      setState(() {
        _appointments = list;
        _isLoading = false;
      });
    }
  }

  List<Appointment> _applyFilter(List<Appointment> source) {
    return source.where((app) {
      final matchesFilter = _selectedFilter == 'All' ||
          app.status.toLowerCase() == _selectedFilter.toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          app.doctorName.toLowerCase().contains(query) ||
          app.doctorSpecialization.toLowerCase().contains(query) ||
          app.patientName.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> _deleteAppointment(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.danger, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Appointment?',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This record will be permanently removed from your history.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.borderLight),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.danger,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await DataService.deleteAppointment(id);
      _loadAppointments();
    }
  }

  void _showRescheduleDialog(Appointment app) {
    String selectedSlot = app.slot;
    DateTime newDate = DateTime.now().add(const Duration(days: 1));
    final slots = [
      '09:00 AM',
      '10:30 AM',
      '11:30 AM',
      '02:00 PM',
      '03:30 PM',
      '05:00 PM'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final formattedDate = DateFormat('EEE, d MMM yyyy').format(newDate);

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Reschedule Appointment',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'With ${app.doctorName}',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Select New Date',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              color: AppTheme.primaryLight, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            formattedDate,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: newDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            setModalState(() => newDate = picked);
                          }
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select New Time Slot',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slots.map((slot) {
                    final isSel = selectedSlot == slot;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedSlot = slot),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSel ? AppTheme.primaryGradient : null,
                          color: isSel ? null : AppTheme.bgCard2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppTheme.primaryLight : AppTheme.borderSubtle,
                          ),
                        ),
                        child: Text(
                          slot,
                          style: GoogleFonts.poppins(
                            color: isSel ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final navContext = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);
                      await DataService.rescheduleAppointment(
                          app.id, formattedDate, selectedSlot);
                      navContext.pop();
                      if (mounted) {
                        _loadAppointments();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Appointment successfully rescheduled!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text('Confirm Reschedule'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointmentPass(Appointment app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_2_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              'Digital Consultation Pass',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              'Token #${app.id.substring(0, 6).toUpperCase()}',
              style: GoogleFonts.poppins(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Pass Details Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.bgCard2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  _passRow('Doctor', app.doctorName),
                  const SizedBox(height: 8),
                  _passRow('Specialty', app.doctorSpecialization),
                  const SizedBox(height: 8),
                  _passRow('Date & Time', '${app.date} • ${app.slot}'),
                  const SizedBox(height: 8),
                  _passRow('Patient Name', app.patientName),
                  const SizedBox(height: 8),
                  _passRow('Age & Phone', '${app.patientAge} Yrs • ${app.patientPhone}'),
                  if (app.problem.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _passRow('Reason / Symptoms', app.problem),
                  ],
                  Divider(color: AppTheme.divider, height: 20),
                  _passRow('Clinic Ward', 'OPD Block A - Counter 4', isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Appointment pass downloaded to your device!',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: AppTheme.primaryLight),
                label: Text(
                  'Download Pass / Slip',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 12),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: isHighlight ? AppTheme.accent : AppTheme.textPrimary,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _applyFilter(_appointments);

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      color: AppTheme.primary,
      backgroundColor: AppTheme.bgCard,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Header
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My Appointments',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_appointments.length} Total',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track, reschedule or download consultation passes',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search and Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: TextField(
                      style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Search doctor or patient...',
                                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                    icon: Icon(Icons.clear_rounded, color: AppTheme.textMuted, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Confirmed', 'Completed', 'Cancelled'].map((status) {
                        final isSel = _selectedFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = status),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isSel ? AppTheme.purpleGradient : null,
                                color: isSel ? null : AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSel ? AppTheme.purple : AppTheme.borderSubtle,
                                ),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.poppins(
                                  color: isSel ? Colors.white : AppTheme.textSecondary,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List Body
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (list.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_busy_rounded,
                          color: AppTheme.textMuted,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _selectedFilter != 'All'
                            ? 'No Matching Appointments'
                            : 'No Appointments Yet',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _searchQuery.isNotEmpty || _selectedFilter != 'All'
                            ? 'Try clearing filters or search query'
                            : 'Book your first doctor appointment from the Doctors tab.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final app = list[index];
                    return _buildAppointmentCard(app);
                  },
                  childCount: list.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment app) {
    Color statusColor;
    IconData statusIcon;

    switch (app.status.toLowerCase()) {
      case 'confirmed':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'completed':
        statusColor = AppTheme.primaryLight;
        statusIcon = Icons.task_alt_rounded;
        break;
      case 'cancelled':
        statusColor = AppTheme.danger;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppTheme.warning;
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.glassBox(borderRadius: 18),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Doctor Info + Status Chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.doctorName,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            app.doctorSpecialization,
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            app.status,
                            style: GoogleFonts.poppins(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Date & Time Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppTheme.accent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        app.date,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time_rounded,
                          color: AppTheme.accent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        app.slot,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Patient Details Row
                Row(
                  children: [
                                    Icon(Icons.badge_rounded, color: AppTheme.textMuted, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Patient: ${app.patientName} (${app.patientAge}y)',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                if (app.problem.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          color: AppTheme.textMuted, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Note: ${app.problem}',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textMuted,
                            fontSize: 11.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons Bar
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.divider)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showAppointmentPass(app),
                  icon: Icon(Icons.qr_code_rounded, size: 16, color: AppTheme.primaryLight),
                  label: Text(
                    'View Pass',
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (app.status.toLowerCase() == 'confirmed') ...[
                  TextButton.icon(
                    onPressed: () => _showRescheduleDialog(app),
                    icon: const Icon(Icons.edit_calendar_rounded, size: 15, color: AppTheme.accent),
                    label: Text(
                      'Reschedule',
                      style: GoogleFonts.poppins(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  onPressed: () => _deleteAppointment(app.id),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.danger, size: 18),
                  tooltip: 'Delete Appointment',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
