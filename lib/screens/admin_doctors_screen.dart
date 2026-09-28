import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'doctor_profile_edit_screen.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  String _searchQuery = '';
  final _firestore = FirebaseFirestore.instance;

  void _showAddDoctorDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final qualificationController = TextEditingController(text: 'MBBS, FCPS');
    final experienceController = TextEditingController(text: '5+ Years');
    final feeController = TextEditingController(text: '1500');
    final locationController = TextEditingController(
      text: 'MediCare Central Hospital, Islamabad - OPD Block A',
    );
    String selectedSpecialty = 'General Physician';
    String selectedGender = 'male';

    final specialties = [
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Add New Doctor Profile',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name (e.g. Dr. Usman Tariq)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedSpecialty,
                  dropdownColor: AppTheme.bgCard,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                  ),
                  items: specialties
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setModalState(() => selectedSpecialty = val);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  dropdownColor: AppTheme.bgCard,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedGender = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: qualificationController,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Qualifications',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: experienceController,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Experience (e.g. 10 Years)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: feeController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Consultation Fee (PKR)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Hospital Location / Room',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppTheme.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                if (name.isEmpty) return;

                final fee = int.tryParse(feeController.text.trim()) ?? 1500;
                final docRef = _firestore.collection('doctors').doc();

                await docRef.set({
                  'id': docRef.id,
                  'name': name.startsWith('Dr.') ? name : 'Dr. $name',
                  'email': email,
                  'specialization': selectedSpecialty,
                  'gender': selectedGender,
                  'qualification': qualificationController.text.trim(),
                  'experience': experienceController.text.trim(),
                  'fee': fee,
                  'hospitalLocation': locationController.text.trim(),
                  'rating': 4.9,
                  'availability': 'Mon - Sat',
                  'availableSlots': [
                    '09:00 AM',
                    '11:00 AM',
                    '02:00 PM',
                    '04:30 PM',
                  ],
                  'imageEmoji': 'Doctor',
                  'aboutBio':
                      '$name is a specialist doctor at MediCare Hospital.',
                  'patientsCount': '100+',
                  'reviewsCount': 10,
                  'isActive': true,
                  'createdAt': DateTime.now().toIso8601String(),
                });

                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Doctor profile added successfully.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: Text(
                'Create Doctor',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDoctor(String docId, String doctorName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Doctor?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove $doctorName from the system?',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('doctors').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Doctor $doctorName deleted.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Manage Doctors',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Doctor',
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppTheme.primaryLight,
            ),
            onPressed: _showAddDoctorDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (v) =>
                  setState(() => _searchQuery = v.trim().toLowerCase()),
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search doctors by name or specialty...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('doctors').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load doctors.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data();
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final spec =
                      data['specialization']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery) ||
                      spec.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 48,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No doctors found.',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _showAddDoctorDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Doctor'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, idx) {
                    final doc = docs[idx];
                    final data = doc.data();
                    final name = data['name']?.toString() ?? 'Doctor';
                    final specialty =
                        data['specialization']?.toString() ?? 'Specialist';
                    final fee = data['fee']?.toString() ?? '1500';
                    final qualification =
                        data['qualification']?.toString() ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassBox(borderRadius: 18),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.medical_services_outlined,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  '$specialty • $qualification',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Fee: Rs. $fee | ${data['hospitalLocation'] ?? 'OPD Block A'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.primaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: AppTheme.primaryLight,
                              size: 20,
                            ),
                            tooltip: 'Edit Doctor',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DoctorProfileEditScreen(
                                    initialData: data,
                                    doctorDocId: doc.id,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.danger,
                              size: 20,
                            ),
                            tooltip: 'Delete Doctor',
                            onPressed: () => _deleteDoctor(doc.id, name),
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
