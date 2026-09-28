import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _problemController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  String _selectedReason = 'General Checkup';
  bool _isLoading = false;

  final List<String> _quickReasons = [
    'General Checkup',
    'Follow-up Visit',
    'Fever / Cold',
    'Chest / Heart Issue',
    'Skin Rash / Allergy',
    'Lab Report Review',
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    if (widget.doctor.availableSlots.isNotEmpty) {
      _selectedSlot = widget.doctor.availableSlots.first;
    }
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await AuthService.getUserName();
    final phone = await AuthService.getUserPhone();
    if (mounted) {
      if (name != 'User' && name.isNotEmpty) {
        _nameController.text = name;
      }
      if (phone.isNotEmpty) {
        _phoneController.text = phone;
      }
      if (_ageController.text.isEmpty) {
        _ageController.text = '28';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _problemController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String get _formattedSelectedDate {
    return DateFormat('EEE, d MMM yyyy').format(_selectedDate);
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSlot == null) {
      _showSnack('Please select an appointment time slot', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final finalProblem = _problemController.text.trim().isNotEmpty
        ? _problemController.text.trim()
        : _selectedReason;

    final appointment = Appointment(
      id: const Uuid().v4(),
      doctorId: widget.doctor.userId.isNotEmpty
          ? widget.doctor.userId
          : widget.doctor.id,
      doctorName: widget.doctor.name,
      doctorSpecialization: widget.doctor.specialization,
      patientName: _nameController.text.trim(),
      patientAge: _ageController.text.trim(),
      patientPhone: _phoneController.text.trim(),
      slot: _selectedSlot!,
      date: _formattedSelectedDate,
      status: 'Pending',
      problem: finalProblem,
      patientId: AuthService.currentUser?.uid ?? '',
    );

    try {
      await DataService.saveAppointment(appointment);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(e.toString().replaceFirst('Bad state: ', ''), isError: true);
      }
      return;
    }
    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccessDialog(appointment);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: isError ? AppTheme.danger : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog(Appointment appointment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Appointment Confirmed!',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your consultation has been scheduled successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 18),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  children: [
                    _dialogSummaryRow('Doctor', widget.doctor.name),
                    const SizedBox(height: 8),
                    _dialogSummaryRow('Date', appointment.date),
                    const SizedBox(height: 8),
                    _dialogSummaryRow('Time Slot', appointment.slot),
                    const SizedBox(height: 8),
                    _dialogSummaryRow('Patient', appointment.patientName),
                    Divider(color: AppTheme.divider, height: 18),
                    _dialogSummaryRow(
                      'Fee Paid at OPD',
                      'Rs. ${widget.doctor.fee}',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Return to home / previous screen
                  },
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogSummaryRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: isHighlight ? AppTheme.primaryLight : AppTheme.textPrimary,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            fontSize: isHighlight ? 13.5 : 12.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.bgCard2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Appointment',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Summary Header Card
                _buildDoctorSummaryCard(),
                const SizedBox(height: 22),

                // Date Picker Strip
                Text(
                  'Select Date',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDatePickerStrip(),
                const SizedBox(height: 22),

                // Time Slots Section
                Text(
                  'Select Time Slot',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTimeSlotsGrid(),
                const SizedBox(height: 22),

                // Visit Reason Selector
                Text(
                  'Reason for Visit',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                _buildReasonChips(),
                const SizedBox(height: 22),

                // Patient Information Card
                Text(
                  'Patient Information',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPatientForm(),
                const SizedBox(height: 22),

                // Bill Breakdown Card
                _buildPaymentSummaryCard(),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isLoading ? null : _bookAppointment,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Confirm Booking (Rs. ${widget.doctor.fee})',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(borderRadius: 18),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(
                widget.doctor.genderIcon,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${widget.doctor.specialization} • ${widget.doctor.qualification}',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryLight,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
                        widget.doctor.hospitalLocation,
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
    );
  }

  Widget _buildDatePickerStrip() {
    final now = DateTime.now();
    final dates = List.generate(7, (index) => now.add(Duration(days: index)));

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;

          final dayName = index == 0
              ? 'Today'
              : (index == 1 ? 'Tomorrow' : DateFormat('EEE').format(date));
          final dayNum = DateFormat('d').format(date);
          final monthName = DateFormat('MMM').format(date);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryLight
                      : AppTheme.borderSubtle,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayNum,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    monthName,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppTheme.textMuted,
                      fontSize: 10.5,
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

  Widget _buildTimeSlotsGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.doctor.availableSlots.map((slot) {
        final isSelected = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected ? null : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryLight
                    : AppTheme.borderSubtle,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: isSelected ? Colors.white : AppTheme.primaryLight,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  slot,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _quickReasons.map((reason) {
        final isSelected = _selectedReason == reason;
        return GestureDetector(
          onTap: () => setState(() => _selectedReason = reason),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accent.withValues(alpha: 0.2)
                  : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.accent : AppTheme.borderSubtle,
              ),
            ),
            child: Text(
              reason,
              style: GoogleFonts.poppins(
                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatientForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassBox(borderRadius: 18),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.poppins(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Patient Full Name',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter patient name'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(
                      Icons.cake_outlined,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Age required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Contact Phone',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Phone number required'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _problemController,
            style: GoogleFonts.poppins(color: AppTheme.textPrimary),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Additional Notes or Symptoms (Optional)',
              hintText: 'Describe any specific symptoms...',
              prefixIcon: Icon(
                Icons.notes_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    const serviceFee = 100;
    final totalFee = widget.doctor.fee + serviceFee;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_rounded,
                color: AppTheme.primaryLight,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment & Consultation Breakdown',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _summaryLine('Doctor Consultation Fee', 'Rs. ${widget.doctor.fee}'),
          const SizedBox(height: 8),
          _summaryLine('Hospital Registration & Tax', 'Rs. $serviceFee'),
          const SizedBox(height: 8),
          _summaryLine(
            'Online Booking Discount',
            '- Rs. 100',
            isDiscount: true,
          ),
          Divider(color: AppTheme.divider, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable at Hospital',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'Rs. ${totalFee - 100}',
                style: GoogleFonts.poppins(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
            fontSize: 12.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: isDiscount ? AppTheme.success : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
