import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'role_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _qualificationController = TextEditingController(text: 'MBBS, FCPS');
  final _experienceController = TextEditingController(text: '5+ Years');
  final _feeController = TextEditingController(text: '1500');
  final _locationController = TextEditingController(text: 'MediCare Central Hospital, Islamabad - OPD Block A');

  String _selectedRole = 'patient'; // 'patient' or 'doctor'
  String _selectedSpecialty = 'General Physician';
  String _selectedGender = 'male';
  final List<String> _specialties = [
    'General Physician',
    'Cardiologist',
    'Neurologist',
    'Pediatrician',
    'Dermatologist',
    'Orthopedic',
    'Psychiatrist',
    'ENT Specialist',
    'Gynecologist',
    'Ophthalmologist',
  ];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _locationController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept the Terms of Service & Privacy Policy',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final feeParsed = int.tryParse(_feeController.text.trim()) ?? 1500;
      await AuthService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        specialization: _selectedSpecialty,
        gender: _selectedGender,
        qualification: _qualificationController.text.trim(),
        experience: _experienceController.text.trim(),
        fee: feeParsed,
        hospitalLocation: _locationController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedRole == 'doctor'
                      ? 'Doctor account created! Welcome to MediCare.'
                      : 'Account created successfully! Welcome to MediCare.',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, anim, secAnim) => const RoleRouter(),
          transitionsBuilder: (context, anim, secAnim, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AuthService.getErrorMessage(e),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withValues(alpha: 0.12),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back Button & Title Bar
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.borderSubtle,
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppTheme.textPrimary,
                                size: 18,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: AppTheme.glassBox(
                          borderRadius: 24,
                          borderColor: AppTheme.borderLight,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Join MediCare Today',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create an account to book or manage appointments',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Role Selector Tabs (Patient vs Doctor)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCard2,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppTheme.borderSubtle,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _selectedRole = 'patient');
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: _selectedRole == 'patient'
                                                ? AppTheme.primaryGradient
                                                : null,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                size: 18,
                                                color: _selectedRole == 'patient'
                                                    ? Colors.white
                                                    : AppTheme.textSecondary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Patient',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedRole == 'patient'
                                                      ? Colors.white
                                                      : AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _selectedRole = 'doctor');
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: _selectedRole == 'doctor'
                                                ? AppTheme.primaryGradient
                                                : null,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.medical_services_rounded,
                                                size: 18,
                                                color: _selectedRole == 'doctor'
                                                    ? Colors.white
                                                    : AppTheme.textSecondary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Doctor',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedRole == 'doctor'
                                                      ? Colors.white
                                                      : AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Full Name
                              Text(
                                _selectedRole == 'doctor' ? 'Doctor Full Name' : 'Full Name',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: _selectedRole == 'doctor' ? 'e.g. Dr. Asad Malik' : 'e.g. Ali Ahmed',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                    color: AppTheme.textMuted,
                                    size: 20,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),

                              if (_selectedRole == 'doctor') ...[
                                const SizedBox(height: 14),

                                // Specialization Dropdown
                                Text(
                                  'Specialization',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedSpecialty,
                                  dropdownColor: AppTheme.bgCard,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.category_outlined,
                                      color: AppTheme.textMuted,
                                      size: 20,
                                    ),
                                  ),
                                  items: _specialties.map((s) {
                                    return DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedSpecialty = val);
                                    }
                                  },
                                ),

                                const SizedBox(height: 14),

                                DropdownButtonFormField<String>(
                                  initialValue: _selectedGender,
                                  dropdownColor: AppTheme.bgCard,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Gender',
                                    prefixIcon: Icon(Icons.wc_outlined),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'male', child: Text('Male')),
                                    DropdownMenuItem(value: 'female', child: Text('Female')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedGender = val);
                                  },
                                ),

                                const SizedBox(height: 14),

                                // Qualification & Experience Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Qualification',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _qualificationController,
                                            style: GoogleFonts.poppins(
                                              color: AppTheme.textPrimary,
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'MBBS, FCPS',
                                              prefixIcon: Icon(
                                                Icons.school_outlined,
                                                color: AppTheme.textMuted,
                                                size: 20,
                                              ),
                                            ),
                                            validator: (val) {
                                              if (_selectedRole == 'doctor' && (val == null || val.trim().isEmpty)) {
                                                return 'Required';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Experience',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _experienceController,
                                            style: GoogleFonts.poppins(
                                              color: AppTheme.textPrimary,
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'e.g. 8+ Years',
                                              prefixIcon: Icon(
                                                Icons.work_history_outlined,
                                                color: AppTheme.textMuted,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Consultation Fee & Location Row
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fee (PKR)',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _feeController,
                                            keyboardType: TextInputType.number,
                                            style: GoogleFonts.poppins(
                                              color: AppTheme.textPrimary,
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '1500',
                                              prefixIcon: Icon(
                                                Icons.payments_outlined,
                                                color: AppTheme.textMuted,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Clinic / Room',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _locationController,
                                            style: GoogleFonts.poppins(
                                              color: AppTheme.textPrimary,
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'MediCare Central Hospital, Islamabad - OPD Block A',
                                              prefixIcon: Icon(
                                                Icons.location_on_outlined,
                                                color: AppTheme.textMuted,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 14),

                              // Email
                              Text(
                                'Email Address',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'name@example.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppTheme.textMuted,
                                    size: 20,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!val.contains('@') ||
                                      !val.contains('.')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Phone Number
                              Text(
                                'Phone Number (Optional)',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: '+92 300 1234567',
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                    color: AppTheme.textMuted,
                                    size: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Password
                              Text(
                                'Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'At least 6 characters',
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppTheme.textMuted,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppTheme.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (val.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Confirm Password
                              Text(
                                'Confirm Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Re-enter your password',
                                  prefixIcon: Icon(
                                    Icons.lock_reset_rounded,
                                    color: AppTheme.textMuted,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppTheme.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (val) {
                                  if (val != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Terms Agreement
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _agreeToTerms,
                                      activeColor: AppTheme.primary,
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _agreeToTerms = val ?? true;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'I agree to the Terms of Service and Privacy Policy',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleSignup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Create Account',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Back to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Log In',
                              style: GoogleFonts.poppins(
                                color: AppTheme.primaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
