import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GlassDatePickerField extends StatefulWidget {
  final DateTime? initialDate;
  final String hintText;
  final Function(DateTime?) onChanged;
  final String? Function(DateTime?)? validator;
  final IconData icon;
  final bool showAgeValidation; // New parameter to control age validation
  final DateTime? firstDate; // Allow custom date ranges
  final DateTime? lastDate;

  const GlassDatePickerField({
    super.key,
    this.initialDate,
    required this.hintText,
    required this.onChanged,
    this.validator,
    this.icon = Icons.calendar_today,
    this.showAgeValidation = false, // Default to false (no age validation)
    this.firstDate,
    this.lastDate,
  });

  @override
  State<GlassDatePickerField> createState() => _GlassDatePickerFieldState();
}

class _GlassDatePickerFieldState extends State<GlassDatePickerField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF9dac17), // Lime green
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onChanged(picked);
    }
  }

  // Calculate age from date of birth
  int? _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final age = widget.showAgeValidation ? _calculateAge(_selectedDate) : null;
    final isUnderage = widget.showAgeValidation && age != null && age < 18;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnderage
                    ? Colors.red.withValues(alpha:0.5)
                    : (isDark ? Colors.white24 : Colors.grey[200]!),
                width: isUnderage ? 2 : 1,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: isDark ? Colors.white54 : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? widget.hintText
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 15,
                      color: _selectedDate == null
                          ? (isDark ? Colors.white38 : Colors.grey[400])
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
                if (widget.showAgeValidation && _selectedDate != null && age != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnderage
                          ? Colors.red.withValues(alpha:0.1)
                          : const Color(0xFF9dac17).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUnderage
                            ? Colors.red.withValues(alpha:0.3)
                            : const Color(0xFF9dac17).withValues(alpha:0.3),
                      ),
                    ),
                    child: Text(
                      'Age: $age',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 12,
                        color: isUnderage ? Colors.red : const Color(0xFF9dac17),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isUnderage)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'You must be at least 18 years old',
              style: GoogleFonts.robotoCondensed(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
