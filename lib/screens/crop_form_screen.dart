import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../models/crop_model.dart';
import '../providers/crop_provider.dart';
import '../providers/crop_category_provider.dart';
import '../providers/farm_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_date_picker_field.dart';

class CropFormScreen extends StatefulWidget {
  final String authToken;
  final int? cropId; // null for create, ID for edit

  const CropFormScreen({
    super.key,
    required this.authToken,
    this.cropId,
  });

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  // REMOVED: final _cropTypeController = TextEditingController();
  final _plantsController = TextEditingController();
  final _waterUsageController = TextEditingController();
  final _notesController = TextEditingController();
  final _totalHarvestController = TextEditingController();

  int? _selectedFarmId;
  int? _selectedCategoryId; // NEW
  int? _selectedTypeId; // NEW
  DateTime? _startDate;
  DateTime? _expectedHarvestDate;
  String _status = CropStatus.planned;
  bool _isLoading = false;
  Crop? _existingCrop;

  @override
  void initState() {
    super.initState();
    // Load farms and categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final categoryProvider = Provider.of<CropCategoryProvider>(context, listen: false);

      if (farmProvider.farms.isEmpty) {
        farmProvider.fetchFarms(widget.authToken);
      }

      // Load crop categories
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.fetchCategories(widget.authToken);
      }

      if (widget.cropId != null) {
        _loadExistingCrop();
      }
    });
  }

  void _loadExistingCrop() async {
    final cropProvider = Provider.of<CropProvider>(context, listen: false);
    try {
      _existingCrop = cropProvider.crops.firstWhere((c) => c.id == widget.cropId);

      // REMOVED: _cropTypeController.text = _existingCrop!.cropType;
      _selectedCategoryId = _existingCrop!.cropCategoryId; // NEW
      _selectedTypeId = _existingCrop!.cropTypeId; // NEW
      _plantsController.text = _existingCrop!.plants.toString();
      _waterUsageController.text = _existingCrop!.waterUsage?.toString() ?? '';
      _notesController.text = _existingCrop!.notes ?? '';
      _totalHarvestController.text = _existingCrop!.totalHarvest ?? '';
      _selectedFarmId = _existingCrop!.farmId;
      _startDate = _existingCrop!.startDate;
      _expectedHarvestDate = _existingCrop!.expectedHarvestDate;
      _status = _existingCrop!.status;

      // Load crop types for selected category
      if (_selectedCategoryId != null) {
        final categoryProvider = Provider.of<CropCategoryProvider>(context, listen: false);
        await categoryProvider.fetchTypesByCategory(widget.authToken, _selectedCategoryId!);
      }

      setState(() {});
    } catch (e) {
      // Crop not found
      debugPrint('Crop not found: $e');
    }
  }

  @override
  void dispose() {
    // REMOVED: _cropTypeController.dispose();
    _plantsController.dispose();
    _waterUsageController.dispose();
    _notesController.dispose();
    _totalHarvestController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation
    if (_selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a farm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategoryId == null || _selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both crop category and type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final cropProvider = Provider.of<CropProvider>(context, listen: false);
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    // Get farm name from selected farm ID
    final selectedFarm = farmProvider.farms.firstWhere((f) => f.id == _selectedFarmId);
    final farmName = selectedFarm.name;

    bool success;

    if (widget.cropId == null) {
      // Create
      success = await cropProvider.createCrop(
        token: widget.authToken,
        farmName: farmName,
        cropCategoryId: _selectedCategoryId!, // NEW
        cropTypeId: _selectedTypeId!, // NEW
        cropType: '', // Deprecated - backend will populate from crop_type_id
        startDate: _startDate!,
        plants: int.parse(_plantsController.text.trim()),
        status: _status,
        farmId: _selectedFarmId!,
        expectedHarvestDate: _expectedHarvestDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        waterUsage: _waterUsageController.text.trim().isEmpty
            ? null
            : double.parse(_waterUsageController.text.trim()),
      );
    } else {
      // Update
      success = await cropProvider.updateCrop(
        token: widget.authToken,
        cropId: widget.cropId!,
        farmName: farmName,
        cropCategoryId: _selectedCategoryId!, // NEW
        cropTypeId: _selectedTypeId!, // NEW
        cropType: '', // Deprecated - backend will populate from crop_type_id
        startDate: _startDate!,
        plants: int.parse(_plantsController.text.trim()),
        status: _status,
        farmId: _selectedFarmId!,
        expectedHarvestDate: _expectedHarvestDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        waterUsage: _waterUsageController.text.trim().isEmpty
            ? null
            : double.parse(_waterUsageController.text.trim()),
        totalHarvest: _totalHarvestController.text.trim().isEmpty
            ? null
            : _totalHarvestController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cropId == null
                ? 'Crop created successfully'
                : 'Crop updated successfully'),
            backgroundColor: AppConstants.forestGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cropProvider.error ?? 'Failed to save crop'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle crop category selection - cascades to load crop types
  Future<void> _onCategorySelected(int? categoryId) async {
    if (categoryId == null) return;

    setState(() {
      _selectedCategoryId = categoryId;
      _selectedTypeId = null; // Reset crop type when category changes
    });

    // Fetch types for this category
    final categoryProvider = Provider.of<CropCategoryProvider>(context, listen: false);
    await categoryProvider.fetchTypesByCategory(widget.authToken, categoryId);
  }

  /// Handle crop type selection
  void _onTypeSelected(int? typeId) {
    setState(() {
      _selectedTypeId = typeId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DesignSystem.darkScaffoldBackground
          : DesignSystem.lightScaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppConstants.darkGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.cropId == null ? 'Add New Crop' : 'Edit Crop',
          style: DesignSystem.heading(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppConstants.darkGreen,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Basic Information
                  GlassCard.large(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppConstants.limeGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Basic Information',
                              style: DesignSystem.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.limeGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Farm Instance dropdown
                        _buildLabel('Farm Instance *', isDark),
                        const SizedBox(height: 8),
                        Consumer<FarmProvider>(
                          builder: (context, farmProvider, child) {
                            if (farmProvider.isLoading) {
                              return const CircularProgressIndicator(
                                color: AppConstants.limeGreen,
                              );
                            }

                            if (farmProvider.farms.isEmpty) {
                              return Text(
                                'No farms available. Please create a farm first.',
                                style: DesignSystem.text(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              );
                            }

                            return _buildDropdown(
                              value: _selectedFarmId,
                              items: farmProvider.farms
                                  .map((farm) => DropdownMenuItem<int>(
                                        value: farm.id,
                                        child: Text(farm.name),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedFarmId = value);
                              },
                              hintText: 'Select Farm',
                              isDark: isDark,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Crop Category Dropdown
                        _buildLabel('Crop Category *', isDark),
                        const SizedBox(height: 8),
                        Consumer<CropCategoryProvider>(
                          builder: (context, categoryProvider, child) {
                            return _buildDropdown<int>(
                              value: _selectedCategoryId,
                              items: categoryProvider.categories
                                  .map((cat) => DropdownMenuItem<int>(
                                        value: cat.id,
                                        child: Row(
                                          children: [
                                            if (cat.icon != null) ...[
                                              Text(cat.icon!, style: const TextStyle(fontSize: 20)),
                                              const SizedBox(width: 8),
                                            ],
                                            Expanded(child: Text(cat.name)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) => _onCategorySelected(value),
                              hintText: 'Select crop category',
                              isDark: isDark,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Crop Type Dropdown (shows after category selected)
                        if (_selectedCategoryId != null) ...[
                          _buildLabel('Crop Type *', isDark),
                          const SizedBox(height: 8),
                          Consumer<CropCategoryProvider>(
                            builder: (context, categoryProvider, child) {
                              final types = categoryProvider.getTypesForCategory(_selectedCategoryId!);

                              return _buildDropdown<int>(
                                value: _selectedTypeId,
                                items: types
                                    .map((type) => DropdownMenuItem<int>(
                                          value: type.id,
                                          child: Text(type.name),
                                        ))
                                    .toList(),
                                onChanged: (value) => _onTypeSelected(value),
                                hintText: 'Select crop type',
                                isDark: isDark,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Status dropdown
                        _buildLabel('Status *', isDark),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _status,
                          items: CropStatus.all
                              .map((status) => DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                          hintText: 'Select Status',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Planting Details
                  GlassCard.large(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: AppConstants.forestGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Planting Details',
                              style: DesignSystem.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.forestGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Start Date
                        _buildLabel('Start Date *', isDark),
                        const SizedBox(height: 8),
                        GlassDatePickerField(
                          hintText: 'Select start date',
                          initialDate: _startDate,
                          onChanged: (date) {
                            setState(() => _startDate = date);
                          },
                        ),
                        const SizedBox(height: 20),

                        // Expected Harvest Date
                        _buildLabel('Expected Harvest Date', isDark),
                        const SizedBox(height: 8),
                        GlassDatePickerField(
                          hintText: 'Select expected harvest date',
                          initialDate: _expectedHarvestDate,
                          onChanged: (date) {
                            setState(() => _expectedHarvestDate = date);
                          },
                        ),
                        const SizedBox(height: 20),

                        // Number of Plants
                        _buildLabel('Number of Plants *', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _plantsController,
                          hintText: 'e.g., 100',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Number of plants is required';
                            }
                            if (int.tryParse(value.trim()) == null) {
                              return 'Enter a valid number';
                            }
                            if (int.parse(value.trim()) <= 0) {
                              return 'Number must be greater than 0';
                            }
                            return null;
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Additional Information
                  GlassCard.large(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notes_outlined,
                              color: AppConstants.olive,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Additional Information',
                              style: DesignSystem.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.olive,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Water Usage
                        _buildLabel('Water Usage (Liters)', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _waterUsageController,
                          hintText: 'e.g., 500',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              if (double.tryParse(value.trim()) == null) {
                                return 'Enter a valid number';
                              }
                            }
                            return null;
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),

                        // Total Harvest (for update only)
                        if (widget.cropId != null) ...[
                          _buildLabel('Total Harvest', isDark),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _totalHarvestController,
                            hintText: 'e.g., 200 kg',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Notes
                        _buildLabel('Notes', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _notesController,
                          hintText: 'Add any additional notes...',
                          maxLines: 4,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDark ? Colors.white54 : AppConstants.darkGreen,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: DesignSystem.text(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppConstants.darkGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.limeGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.cropId == null ? 'Create Crop' : 'Update Crop',
                            style: DesignSystem.text(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppConstants.limeGreen,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: DesignSystem.text(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : Colors.grey[700],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: DesignSystem.text(
          color: isDark ? Colors.white30 : Colors.grey[400],
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.limeGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: DesignSystem.text(
        fontSize: 15,
        color: isDark ? Colors.white : Colors.black87,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required String hintText,
    required bool isDark,
  }) {
    return DropdownButtonFormField<T>(
      value: items.any((item) => item.value == value) ? value : null,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: DesignSystem.text(
          color: isDark ? Colors.white30 : Colors.grey[400],
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.limeGreen,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: DesignSystem.text(
        fontSize: 15,
        color: isDark ? Colors.white : Colors.black87,
      ),
      dropdownColor: isDark ? DesignSystem.darkSurface : Colors.white,
    );
  }
}
