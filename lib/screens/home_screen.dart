import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import 'doctor_detail_screen.dart';
import 'appointments_screen.dart';
import 'health_hub_screen.dart';
import 'search_by_condition_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  String _userName = 'Patient';
  Uint8List? _capturedPhoto;
  bool _isCapturingPhoto = false;

  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _specialties = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'color': AppTheme.primaryLight},
    {
      'name': 'Cardiologist',
      'icon': Icons.favorite_rounded,
      'color': AppTheme.danger,
    },
    {
      'name': 'Neurologist',
      'icon': Icons.psychology_rounded,
      'color': AppTheme.purple,
    },
    {
      'name': 'Pediatrician',
      'icon': Icons.child_care_rounded,
      'color': AppTheme.warning,
    },
    {
      'name': 'Orthopedic Surgeon',
      'icon': Icons.accessible_rounded,
      'color': AppTheme.accent,
    },
    {
      'name': 'Dermatologist',
      'icon': Icons.auto_awesome_rounded,
      'color': AppTheme.pink,
    },
    {
      'name': 'Gastroenterologist',
      'icon': Icons.medical_information_rounded,
      'color': AppTheme.success,
    },
    {
      'name': 'Dentist',
      'icon': Icons.masks_rounded,
      'color': AppTheme.primaryLight,
    },
    {
      'name': 'Ophthalmologist',
      'icon': Icons.remove_red_eye_rounded,
      'color': AppTheme.accent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserData();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  Future<void> _loadUserData() async {
    final name = await AuthService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name.isNotEmpty ? name : 'Patient';
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturingPhoto) return;

    final isMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!isMobile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please run the app on an Android or iOS device to use the camera.',
          ),
        ),
      );
      return;
    }

    setState(() => _isCapturingPhoto = true);
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        final bytes = await photo.readAsBytes();
        setState(() => _capturedPhoto = bytes);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the camera.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturingPhoto = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Health Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _notificationTile(
              title: 'Consultation Reminder',
              subtitle: 'Your appointment is confirmed for this week.',
              time: '1h ago',
              icon: Icons.calendar_today_rounded,
              color: AppTheme.primaryLight,
            ),
            const SizedBox(height: 10),
            _notificationTile(
              title: 'Daily Hydration Goal',
              subtitle: 'Keep your hydration on track. Log your water intake!',
              time: '3h ago',
              icon: Icons.local_drink_rounded,
              color: AppTheme.accent,
            ),
            const SizedBox(height: 10),
            _notificationTile(
              title: 'Welcome to MediCare',
              subtitle: 'You have full access to top medical specialists.',
              time: '1d ago',
              icon: Icons.verified_user_rounded,
              color: AppTheme.success,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _notificationTile({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emergency_rounded,
                    color: AppTheme.danger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '24/7 Emergency Care',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _emergencyItem(
              'Ambulance / Rescue',
              '1122',
              Icons.local_hospital_rounded,
            ),
            const SizedBox(height: 10),
            _emergencyItem(
              'MediCare Emergency Ward',
              '+92 (021) 111-MED-CARE',
              Icons.phone_in_talk_rounded,
            ),
            const SizedBox(height: 10),
            _emergencyItem(
              'Hospital OPD Desk',
              '+92 (021) 3456-7890',
              Icons.support_agent_rounded,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _emergencyItem(String title, String number, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  number,
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.dangerGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Call',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Stream<List<Doctor>> _doctorsStream() {
    return DataService.getDoctorsStream();
  }

  List<Doctor> _filteredDoctors(List<Doctor> doctors) {
    return doctors.where((doctor) {
      final search = _searchQuery.toLowerCase();
      final matchSearch =
          _searchQuery.isEmpty ||
          doctor.name.toLowerCase().contains(search) ||
          doctor.specialization.toLowerCase().contains(search);
      final matchSpecialty =
          _selectedSpecialty == 'All' ||
          doctor.specialization == _selectedSpecialty;
      return matchSearch && matchSpecialty;
    }).toList();
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.bgCard,
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'P',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              accountName: Text(
                _userName,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              accountEmail: FutureBuilder<String>(
                future: AuthService.getUserEmail(),
                builder: (context, snapshot) => Text(snapshot.data ?? ''),
              ),
            ),
            _drawerItem(Icons.medical_services_outlined, 'Doctors', 0),
            _drawerItem(Icons.calendar_month_outlined, 'Appointments', 1),
            _drawerItem(Icons.favorite_outline, 'Health Hub', 2),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppTheme.danger),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _handleLogout,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppTheme.primaryLight : AppTheme.textSecondary,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? AppTheme.primaryLight : AppTheme.textPrimary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedTileColor: AppTheme.primary.withValues(alpha: 0.12),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _handleLogout() async {
    Navigator.of(context).pop();
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;

    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      drawer: _buildDrawer(),
      body: FadeTransition(opacity: _fadeAnim, child: _buildCurrentTab()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildDoctorsTab();
      case 1:
        return const AppointmentsScreen();
      case 2:
        return const HealthHubScreen();
      default:
        return _buildDoctorsTab();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.medical_services_rounded, 'Doctors'),
              _navItem(1, Icons.calendar_month_rounded, 'Appointments'),
              _navItem(2, Icons.favorite_rounded, 'Health Hub'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textMuted,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsTab() {
    return StreamBuilder<List<Doctor>>(
      stream: _doctorsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        final allDoctors = snapshot.data ?? const <Doctor>[];
        final doctors = _filteredDoctors(allDoctors);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emergency Hotline SOS Card
                    _buildCapturedPhotoPreview(),
                    if (_capturedPhoto != null) const SizedBox(height: 18),
                    _buildEmergencyBanner(),
                    const SizedBox(height: 18),

                    // Active Booked Appointments Banner
                    _buildUpcomingAppointmentsBanner(),
                    const SizedBox(height: 18),

                    // Health Insights Tips Carousel
                    _buildHealthTipsCarousel(),
                    const SizedBox(height: 20),

                    // Search by Condition Section
                    _buildSearchByConditionBanner(),
                    const SizedBox(height: 20),

                    // Doctors Online Now
                    _buildDoctorsOnlineNow(allDoctors),
                    if (allDoctors.isNotEmpty) const SizedBox(height: 22),

                    // Specialty Categories Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medical Specialties',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_specialties.length - 1} Departments',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSpecialtiesList(),
                    const SizedBox(height: 22),

                    // Available Doctors Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Specialists',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${doctors.length} Available',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (doctors.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard2,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            color: AppTheme.textMuted,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No doctors found',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try searching for another specialty or clear the search query.',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final doc = doctors[index];
                    return _buildDoctorCard(doc);
                  }, childCount: doctors.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        );
      },
    );
  }

  Widget _buildCapturedPhotoPreview() {
    if (_capturedPhoto == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.bgCard2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_capturedPhoto!, fit: BoxFit.cover),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Captured photo',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 175,
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    children: [
                      // Top Row: User Greeting & Notification
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _selectedIndex = 2),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _userName.isNotEmpty
                                          ? _userName[0].toUpperCase()
                                          : 'P',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppTheme.primaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _userName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Capture photo',
                                onPressed: _isCapturingPhoto
                                    ? null
                                    : _capturePhoto,
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.22),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryLight.withValues(alpha: 0.55),
                                    ),
                                  ),
                                  child: _isCapturingPhoto
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.photo_camera_rounded,
                                          color: AppTheme.primaryLight,
                                          size: 19,
                                        ),
                                ),
                              ),
                              IconButton(
                                onPressed: _showNotificationsSheet,
                                icon: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondary.withValues(alpha: 0.22),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.secondary.withValues(alpha: 0.65),
                                        ),
                                      ),
                                      child: const Icon(
                                          Icons.notifications_active_rounded,
                                          color: AppTheme.secondary,
                                          size: 19,
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            tooltip: 'Toggle light and dark theme',
                            onPressed: AppTheme.toggleTheme,
                            icon: Icon(
                              AppTheme.themeMode.value == ThemeMode.dark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search Bar
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: TextField(
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search doctor, specialty, clinic...',
                            hintStyle: GoogleFonts.poppins(
                              color: AppTheme.textMuted,
                              fontSize: 12.5,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: AppTheme.textMuted,
                                      size: 16,
                                    ),
                                    onPressed: () =>
                                        setState(() => _searchQuery = ''),
                                  )
                                : null,
                          ),
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
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
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F1D1D), Color(0xFF991B1B), Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.danger.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_in_talk_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24/7 Emergency Ambulance',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Immediate medical helpline & rescue squad',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showEmergencySheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Call SOS',
                style: GoogleFonts.poppins(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentsBanner() {
    return FutureBuilder<List<Appointment>>(
      future: DataService.getAppointments(),
      builder: (context, snapshot) {
        final appointment = (snapshot.data ?? const <Appointment>[])
            .where((app) => app.status.toLowerCase() == 'confirmed')
            .firstOrNull;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _appointmentBannerContent(
            title: 'Checking your schedule',
            subtitle: 'Loading your upcoming consultations...',
            icon: Icons.hourglass_top_rounded,
            color: AppTheme.primaryLight,
          );
        }

        if (appointment == null) {
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = 1),
            child: _appointmentBannerContent(
              title: 'No upcoming appointments',
              subtitle: 'Book a consultation with a specialist today.',
              icon: Icons.event_available_rounded,
              color: AppTheme.accent,
              actionLabel: 'View',
            ),
          );
        }

        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = 1),
          child: _appointmentBannerContent(
            title: 'Upcoming with ${appointment.doctorName}',
            subtitle: '${appointment.date} at ${appointment.slot}',
            icon: Icons.calendar_month_rounded,
            color: AppTheme.success,
            actionLabel: 'View',
          ),
        );
      },
    );
  }

  Widget _appointmentBannerContent({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthTipsCarousel() {
    final tips = [
      {
        'title': 'Stay Hydrated Daily',
        'subtitle':
            'Drink at least 8 glasses of pure water to boost organ health.',
        'icon': Icons.water_drop_rounded,
        'color': AppTheme.accent,
      },
      {
        'title': 'Heart Health Tip',
        'subtitle':
            'A 30-minute daily walk lowers cardiovascular risks by 40%.',
        'icon': Icons.favorite_rounded,
        'color': AppTheme.danger,
      },
      {
        'title': 'Routine Checkups',
        'subtitle':
            'Early diagnosis prevents 85% of chronic medical conditions.',
        'icon': Icons.shield_rounded,
        'color': AppTheme.success,
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tip = tips[index];
          final color = tip['color'] as Color;

          return Container(
            width: 270,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tip['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tip['title'] as String,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tip['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                          fontSize: 10.5,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchByConditionBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SearchByConditionScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_information_rounded,
                color: AppTheme.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search by Condition',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find doctors by symptoms',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsOnlineNow(List<Doctor> allDoctors) {
    if (allDoctors.isEmpty) return const SizedBox.shrink();
    final onlineDoctors = allDoctors.take(4).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${onlineDoctors.length} Doctors Online Now',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: onlineDoctors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final doctor = onlineDoctors[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailScreen(doctor: doctor),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                doctor.genderIcon,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        doctor.name.split(' ').last,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        doctor.specialization.split(' ').first,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesList() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _specialties.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _specialties[index];
          final name = item['name'] as String;
          final icon = item['icon'] as IconData;
          final isSelected = _selectedSpecialty == name;

          return GestureDetector(
            onTap: () => setState(() => _selectedSpecialty = name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryLight
                      : AppTheme.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.glassBox(borderRadius: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorDetailScreen(doctor: doc),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Emoji Avatar with Glowing Badge
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          doc.genderIcon,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  doc.name,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppTheme.warning,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      doc.rating.toStringAsFixed(1),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            doc.specialization,
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            doc.qualification,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Location / OPD room
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: AppTheme.textMuted,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  doc.hospitalLocation,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Divider(color: AppTheme.divider, height: 22),

                // Bottom Row: Fee + Quick Book Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consultation Fee',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textMuted,
                              fontSize: 10.5,
                            ),
                          ),
                          Text(
                            'Rs. ${doc.fee}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Book Now',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
