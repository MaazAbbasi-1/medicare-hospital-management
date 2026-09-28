import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/doctor_model.dart';
import 'booking_screen.dart';
import 'chat_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildClinicLocationCard(),
                    const SizedBox(height: 16),
                    _buildAboutSection(),
                    const SizedBox(height: 16),
                    _buildSlotsSection(),
                    const SizedBox(height: 16),
                    _buildReviewsSection(),
                    const SizedBox(height: 100), // padding for floating bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildStickyBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 270,
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Doctor profile link copied to clipboard!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0F172A),
                const Color(0xFF1E293B),
                AppTheme.primaryDark.withValues(alpha: 0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryLight.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    // Doctor Avatar with Glowing Halo
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          widget.doctor.genderIcon,
                          color: Colors.white,
                          size: 58,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.doctor.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 21,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified_rounded,
                          color: AppTheme.primaryLight,
                          size: 20,
                        ),
                      ],
                    ),
                    Text(
                      widget.doctor.specialization,
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.doctor.qualification,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('Rating', '${widget.doctor.rating}', 'Rating', AppTheme.warning),
        const SizedBox(width: 10),
        _statCard('Experience', widget.doctor.experience, 'Experience', AppTheme.accent),
        const SizedBox(width: 10),
        _statCard('Patients', widget.doctor.patientsCount, 'Patients', AppTheme.primaryLight),
        const SizedBox(width: 10),
        _statCard('Reviews', '${widget.doctor.reviewsCount}', 'Reviews', AppTheme.purple),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppTheme.textMuted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(borderRadius: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppTheme.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hospital Ward & Chamber',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.doctor.hospitalLocation,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.doctor.availability,
              style: GoogleFonts.poppins(
                color: AppTheme.success,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final bioText = widget.doctor.aboutBio.isNotEmpty
        ? widget.doctor.aboutBio
        : '${widget.doctor.name} is a highly accomplished ${widget.doctor.specialization} with ${widget.doctor.experience} of dedicated clinical experience. Graduated with ${widget.doctor.qualification} and specializes in holistic patient diagnosis and modern medical treatments.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassBox(borderRadius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'About Doctor',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            bioText,
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassBox(borderRadius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: AppTheme.primaryLight, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Available Consultation Slots',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.doctor.availableSlots.length} Slots',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.doctor.availableSlots.map((slot) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      color: AppTheme.primaryLight,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      slot,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final reviews = widget.doctor.reviews.isNotEmpty
        ? widget.doctor.reviews
        : [
            DoctorReview(
              patientName: 'Bilal Farooq',
              rating: 5.0,
              comment:
                  'Very empathetic doctor. Explained my symptoms clearly and the prescribed medicine helped immensely.',
              date: '3 days ago',
            ),
            DoctorReview(
              patientName: 'Amina Khalid',
              rating: 4.8,
              comment:
                  'Prompt consultation with zero unnecessary waiting. Spotless OPD room and helpful staff.',
              date: '1 week ago',
            ),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassBox(borderRadius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppTheme.warning, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Patient Reviews',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.doctor.reviewsCount} total',
                style: GoogleFonts.poppins(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...reviews.map((rev) => _reviewItem(rev)),
        ],
      ),
    );
  }

  Widget _reviewItem(DoctorReview rev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.3),
                    child: Text(
                      rev.patientName.isNotEmpty ? rev.patientName[0] : 'P',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rev.patientName,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppTheme.warning, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    rev.rating.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rev.comment,
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          top: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fee: Rs. ${widget.doctor.fee}',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Chat Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          recipientId: widget.doctor.id,
                          recipientName: widget.doctor.name,
                          userRole: 'patient',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '💬 Chat',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Book Appointment Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(doctor: widget.doctor),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.15),
                      border: Border.all(color: AppTheme.success),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '📅 Book',
                        style: GoogleFonts.poppins(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
