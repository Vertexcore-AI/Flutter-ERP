import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system.dart';
import '../../constants/app_constants.dart';
import '../../services/water_management_service.dart';
import '../../services/crop_service.dart';
import '../../services/secure_storage_service.dart';
import '../../widgets/resource_form_header.dart';
import '../../widgets/application_type_toggle.dart';
import '../../widgets/calculated_total_display.dart';
import '../../widgets/glass_card.dart';

class WaterLogFormScreen extends StatefulWidget {
  final int cropCycleId;
  final String cropName;

  const WaterLogFormScreen({
    super.key,
    required this.cropCycleId,
    required this.cropName,
  });

  @override
  State<WaterLogFormScreen> createState() => _WaterLogFormScreenState();
}

class _WaterLogFormScreenState extends State<WaterLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _waterManagementService = WaterManagementService();
  final _cropService = CropService();
  final _secureStorage = SecureStorageService();

  // Form fields
  DateTime _selectedDate = DateTime.now();
  String _wateringType = 'BY_PLANT';
  String? _wateringMethod = 'Drip';
  final TextEditingController _waterPerPlantController =
      TextEditingController();
  String _waterUnit = 'liters';
  final TextEditingController _notesController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isLoadingCrop = true;
  int _numberOfPlants = 1;
  String? _authToken;

  final List<String> _wateringMethods = ['Drip', 'Sprinkler', 'Manual'];
  final List<String> _waterUnits = ['ml', 'liters'];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    _waterPerPlantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    try {
      _authToken = await _secureStorage.getAuthToken();
      if (_authToken != null && mounted) {
        await _fetchCropDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load authentication: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchCropDetails() async {
    setState(() => _isLoadingCrop = true);

    try {
      final result = await _cropService.fetchCrops(_authToken!);

      if (result['success'] && mounted) {
        final crops = result['data'] as List;

        try {
          final crop = crops.firstWhere(
            (c) => c.id == widget.cropCycleId,
          );

          setState(() {
            _numberOfPlants = crop.plants;
            _isLoadingCrop = false;
          });
        } catch (e) {
          setState(() => _isLoadingCrop = false);
        }
      } else {
        setState(() => _isLoadingCrop = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCrop = false);
      }
    }
  }

  String get _waterPerCropCalculated {
    final totalWater =
        double.tryParse(_waterPerPlantController.text) ?? 0.0;

    if (totalWater == 0.0 || _numberOfPlants == 0) {
      return '0.00 $_waterUnit';
    }

    final waterPerCrop = totalWater / _numberOfPlants;
    return '${waterPerCrop.toStringAsFixed(2)} $_waterUnit';
  }

  double get _calculatedTotal {
    final waterPerPlant =
        double.tryParse(_waterPerPlantController.text) ?? 0.0;

    if (_wateringType == 'BY_PLANT') {
      // BY_PLANT: multiply water per plant by number of plants
      return waterPerPlant * _numberOfPlants;
    } else {
      // ENTIRE_CROP: water amount is the total directly
      return waterPerPlant;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final waterPerPlant =
          double.parse(_waterPerPlantController.text);

      final data = {
        'crop_id': widget.cropCycleId,
        'watering_date': _selectedDate.toIso8601String().split('T')[0],
        'watering_type': _wateringType,
        'watering_method': _wateringMethod,
        'number_of_plants': _wateringType == 'BY_PLANT' ? _numberOfPlants : 1,
        'water_per_plant': waterPerPlant,
        'water_unit': _waterUnit,
        'total_water_used': _calculatedTotal,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      };

      final result =
          await _waterManagementService.createWaterLog(_authToken!, data);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Water log created successfully'),
              backgroundColor: AppConstants.limeGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to create water log'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E21)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoadingCrop
          ? Center(
              child: CircularProgressIndicator(
                color: AppConstants.limeGreen,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Glass card container
                      GlassCard(
                        intensity: GlassIntensity.medium,
                        child: Column(
                          children: [
                            // Header
                            ResourceFormHeader(
                              icon: Icons.water_drop,
                              color: Colors.blue.shade600,
                              title: 'Water Management',
                              subtitle: widget.cropName.toUpperCase(),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date field
                                  _buildLabel('Watering Date'),
                                  const SizedBox(height: 8),
                                  _buildDateField(isDark),
                                  const SizedBox(height: 24),

                                  // Watering type toggle
                                  _buildLabel('Application Type'),
                                  const SizedBox(height: 8),
                                  ApplicationTypeToggle(
                                    selectedType: _wateringType,
                                    onChanged: (value) {
                                      setState(() {
                                        _wateringType = value;
                                        _waterPerPlantController.clear();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Watering method
                                  _buildLabel('Watering Method'),
                                  const SizedBox(height: 8),
                                  _buildMethodDropdown(isDark),
                                  const SizedBox(height: 24),

                                  // Dynamic fields based on type
                                  if (_wateringType == 'BY_PLANT') ...[
                                    _buildLabel('Number of Plants'),
                                    const SizedBox(height: 8),
                                    _buildDisabledField(
                                        _numberOfPlants.toString(), isDark),
                                    const SizedBox(height: 24),

                                    _buildLabel('Water per Plant'),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _buildWaterInputField(isDark),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildUnitDropdown(isDark),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    _buildLabel(
                                        'Total Water for Entire Crop'),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _buildWaterInputField(isDark),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildUnitDropdown(isDark),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    _buildLabel('Water per Crop (Calculated)'),
                                    const SizedBox(height: 8),
                                    _buildDisabledField(
                                        _waterPerCropCalculated, isDark),
                                  ],

                                  const SizedBox(height: 24),

                                  // Calculated total display
                                  CalculatedTotalDisplay(
                                    total: _calculatedTotal,
                                    unit: _waterUnit,
                                    color: Colors.blue.shade600,
                                  ),

                                  const SizedBox(height: 24),

                                  // Notes field
                                  _buildLabel('Notes (Optional)'),
                                  const SizedBox(height: 8),
                                  _buildNotesField(isDark),

                                  const SizedBox(height: 32),

                                  // Submit button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            Colors.blue.shade600
                                                .withValues(alpha: 0.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Create Water Log',
                                              style: DesignSystem.text(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: DesignSystem.text(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : Colors.black54,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildDateField(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppConstants.limeGreen,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              style: DesignSystem.text(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _wateringMethod,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          style: DesignSystem.text(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          items: _wateringMethods.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(method),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _wateringMethod = value);
          },
        ),
      ),
    );
  }

  Widget _buildWaterInputField(bool isDark) {
    return TextFormField(
      controller: _waterPerPlantController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: DesignSystem.text(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: _wateringType == 'BY_PLANT'
            ? 'Enter amount per plant'
            : 'Enter total amount',
        hintStyle: DesignSystem.text(
          fontSize: 14,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blue.shade600,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Must be > 0';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildUnitDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _waterUnit,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          style: DesignSystem.text(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          items: _waterUnits.map((unit) {
            return DropdownMenuItem(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _waterUnit = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDisabledField(String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Text(
        value,
        style: DesignSystem.text(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );
  }

  Widget _buildNotesField(bool isDark) {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      style: DesignSystem.text(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Add observations, conditions, or special notes...',
        hintStyle: DesignSystem.text(
          fontSize: 14,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blue.shade600,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
