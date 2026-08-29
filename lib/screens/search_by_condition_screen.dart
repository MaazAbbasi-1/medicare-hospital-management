import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/condition_model.dart';
import '../models/doctor_model.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import 'doctor_detail_screen.dart';

class SearchByConditionScreen extends StatefulWidget {
  const SearchByConditionScreen({super.key});

  @override
  State<SearchByConditionScreen> createState() =>
      _SearchByConditionScreenState();
}

class _SearchByConditionScreenState extends State<SearchByConditionScreen> {
  Condition? _selectedCondition;
  List<Doctor> _relatedDoctors = [];

  void _selectCondition(Condition condition) {
    setState(() {
      _selectedCondition = condition;
      _findRelatedDoctors(condition);
    });
  }

  void _findRelatedDoctors(Condition condition) {
    final allDoctors = DataService.defaultDoctors;
    _relatedDoctors = allDoctors
        .where((doc) =>
            condition.relatedSpecialties.any((spec) =>
                doc.specialization.toLowerCase() == spec.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'Search by Condition',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: _selectedCondition == null
          ? _buildConditionsList()
          : _buildDoctorsForCondition(),
    );
  }

  Widget _buildConditionsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Common Health Issues',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: commonConditions.length,
          itemBuilder: (context, index) {
            final condition = commonConditions[index];
            return GestureDetector(
              onTap: () => _selectCondition(condition),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      condition.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      condition.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDoctorsForCondition() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primary.withOpacity(0.15),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _selectedCondition = null);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _selectedCondition!.icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCondition!.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Specialists: ${_selectedCondition!.relatedSpecialties.join(", ")}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _relatedDoctors.isEmpty
              ? Center(
                  child: Text(
                    'No doctors found for this condition',
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _relatedDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _relatedDoctors[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorDetailScreen(doctor: doctor),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderSubtle,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  doctor.imageEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    doctor.specialization,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${doctor.rating}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rs.${doctor.fee}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.textSecondary,
                              size: 14,
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
}
