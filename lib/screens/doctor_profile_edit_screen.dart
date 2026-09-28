import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class DoctorProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? doctorDocId;

  const DoctorProfileEditScreen({
    super.key,
    this.initialData,
    this.doctorDocId,
  });

  @override
  State<DoctorProfileEditScreen> createState() =>
      _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState extends State<DoctorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _qualificationController;
  late TextEditingController _experienceController;
  late TextEditingController _feeController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _newSlotController;

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

  List<String> _availableSlots = [
    '09:00 AM',
    '10:30 AM',
    '02:00 PM',
    '03:30 PM',
    '05:00 PM',
  ];

  bool _isLoading = false;
  bool _isFetching = true;
  String _docId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _qualificationController = TextEditingController(text: 'MBBS, FCPS');
    _experienceController = TextEditingController(text: '5+ Years');
    _feeController = TextEditingController(text: '1500');
    _locationController = TextEditingController(text: 'MediCare Central Hospital, Islamabad - OPD Block A');
    _bioController = TextEditingController();
    _newSlotController = TextEditingController();

    _loadDoctorProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _newSlotController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _nameController.text = await AuthService.getUserName();
    _phoneController.text = await AuthService.getUserPhone();

    if (widget.initialData != null) {
      _applyData(widget.initialData!);
      if (widget.doctorDocId != null && widget.doctorDocId!.isNotEmpty) {
        _docId = widget.doctorDocId!;
      }
      setState(() => _isFetching = false);
      return;
    }

    if (uid != null) {
      try {
        // Try getting doctor profile by doc id or userId
        var doc = await FirebaseFirestore.instance.collection('doctors').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          _docId = doc.id;
          _applyData(doc.data()!);
        } else {
          final query = await FirebaseFirestore.instance
              .collection('doctors')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            _docId = query.docs.first.id;
            _applyData(query.docs.first.data());
          }
        }
      } catch (_) {}
    }

    if (mounted) setState(() => _isFetching = false);
  }

  void _applyData(Map<String, dynamic> data) {
    if (data['name'] != null && data['name'].toString().isNotEmpty) {
      _nameController.text = data['name'].toString();
    }
    if (data['phone'] != null) _phoneController.text = data['phone'].toString();
    if (data['qualification'] != null) {
      _qualificationController.text = data['qualification'].toString();
    }
    if (data['experience'] != null) {
      _experienceController.text = data['experience'].toString();
    }
    if (data['fee'] != null) _feeController.text = data['fee'].toString();
    if (data['hospitalLocation'] != null) {
      _locationController.text = data['hospitalLocation'].toString();
    }
    if (data['aboutBio'] != null) _bioController.text = data['aboutBio'].toString();

    if (data['specialization'] != null &&
        _specialties.contains(data['specialization'].toString())) {
      _selectedSpecialty = data['specialization'].toString();
    }
    final savedGender = data['gender']?.toString().toLowerCase().trim();
    if (savedGender == 'male' || savedGender == 'female') {
      _selectedGender = savedGender!;
    }

    if (data['availableSlots'] is List) {
      _availableSlots = List<String>.from(data['availableSlots']);
    } else if (data['availableSlots'] is String) {
      _availableSlots = (data['availableSlots'] as String)
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
  }

  void _addSlot() {
    final text = _newSlotController.text.trim();
    if (text.isNotEmpty && !_availableSlots.contains(text)) {
      setState(() {
        _availableSlots.add(text);
        _newSlotController.clear();
      });
    }
  }

  void _removeSlot(String slot) {
    setState(() {
      _availableSlots.remove(slot);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final feeVal = int.tryParse(_feeController.text.trim()) ?? 1500;
    final doctorName = _nameController.text.trim();

    final updateData = {
      'name': doctorName.startsWith('Dr.') ? doctorName : 'Dr. $doctorName',
      'phone': _phoneController.text.trim(),
      'qualification': _qualificationController.text.trim(),
      'specialization': _selectedSpecialty,
      'gender': _selectedGender,
      'experience': _experienceController.text.trim(),
      'fee': feeVal,
      'hospitalLocation': _locationController.text.trim(),
      'aboutBio': _bioController.text.trim(),
      'availableSlots': _availableSlots,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final firestore = FirebaseFirestore.instance;
      final targetDocId = _docId.isNotEmpty ? _docId : (uid ?? 'temp_doc');

      await firestore
          .collection('doctors')
          .doc(targetDocId)
          .set(updateData, SetOptions(merge: true));

      if (uid != null) {
        await firestore.collection('users').doc(uid).set({
          'name': doctorName,
          'phone': _phoneController.text.trim(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Profile & schedule updated successfully!',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Doctor Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Save Profile',
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_rounded, color: AppTheme.primaryLight),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: AppTheme.glassBox(borderRadius: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.medical_services_outlined, size: 30),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text
                                      : 'Doctor Profile',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Specialist: $_selectedSpecialty',
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
                    _sectionHeader('Doctor Information'),
                    const SizedBox(height: 10),

                    // Full Name Field
                    _inputField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Specialization Field
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
                      items: _specialties
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSpecialty = val);
                      },
                    ),

                    const SizedBox(height: 12),

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

                    const SizedBox(height: 12),

                    // Qualification & Experience Row
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            label: 'Qualifications',
                            controller: _qualificationController,
                            icon: Icons.school_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inputField(
                            label: 'Experience',
                            controller: _experienceController,
                            icon: Icons.work_history_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Phone & Fee Row
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            label: 'Contact Phone',
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inputField(
                            label: 'Fee (PKR)',
                            controller: _feeController,
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Clinic Location
                    _inputField(
                      label: 'Clinic / Room Location',
                      controller: _locationController,
                      icon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 12),

                    // Bio
                    Text(
                      'About Doctor / Bio',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Brief summary of expertise, background, and patient care philosophy...',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Icon(
                            Icons.description_outlined,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionHeader('Available Appointment Slots'),
                    const SizedBox(height: 6),
                    Text(
                      'Add or remove time slots available for patient bookings',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Add Slot Field
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newSlotController,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. 11:45 AM or 06:00 PM',
                              prefixIcon: Icon(
                                Icons.access_time_rounded,
                                color: AppTheme.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _addSlot,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Slots Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableSlots.map((slot) {
                        return Chip(
                          backgroundColor: AppTheme.bgCard2,
                          side: BorderSide(color: AppTheme.borderLight),
                          label: Text(
                            slot,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          deleteIcon: const Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: AppTheme.danger,
                          ),
                          onDeleted: () => _removeSlot(slot),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Save Profile Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Save Profile & Availability',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
          ),
        ),
      ],
    );
  }
}
