import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../config/api_config.dart';
import '../models/farm_model.dart';
import '../providers/farm_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_image_picker_field.dart';
import '../widgets/farm_category_dropdown.dart';
import '../widgets/photon_location_field.dart';

class FarmFormScreen extends StatefulWidget {
  final String authToken;
  final int? farmId; // null for create, ID for edit

  const FarmFormScreen({
    super.key,
    required this.authToken,
    this.farmId,
  });

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _mainCategory = FarmCategories.mainCategories[0];
  String _category = FarmCategories.subCategories[FarmCategories.mainCategories[0]]![0];
  String _areaUnit = FarmCategories.areaUnits[FarmCategories.mainCategories[0]]![0];
  File? _selectedImage;
  bool _isLoading = false;
  Farm? _existingFarm;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.farmId != null) {
      _loadExistingFarm();
    }
  }

  void _loadExistingFarm() {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    _existingFarm = farmProvider.farms.firstWhere((f) => f.id == widget.farmId);

    _nameController.text = _existingFarm!.name;
    _areaController.text = _existingFarm!.area;
    _locationController.text = _existingFarm!.location ?? '';
    _notesController.text = _existingFarm!.notes ?? '';
    _mainCategory = _existingFarm!.mainCategory;
    _category = _existingFarm!.category;
    _areaUnit = _existingFarm!.areaUnit;
    _latitude = _existingFarm!.latitude;
    _longitude = _existingFarm!.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onMainCategoryChanged(String? value) {
    if (value != null) {
      setState(() {
        _mainCategory = value;
        _category = FarmCategories.subCategories[value]![0];
        _areaUnit = FarmCategories.areaUnits[value]![0];
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    bool success;

    if (widget.farmId == null) {
      // Create
      success = await farmProvider.createFarm(
        token: widget.authToken,
        name: _nameController.text.trim(),
        mainCategory: _mainCategory,
        category: _category,
        area: _areaController.text.trim(),
        areaUnit: _areaUnit,
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        notes: _notesController.text.trim(),
        imageFile: _selectedImage,
      );
    } else {
      // Update
      success = await farmProvider.updateFarm(
        token: widget.authToken,
        farmId: widget.farmId!,
        name: _nameController.text.trim(),
        mainCategory: _mainCategory,
        category: _category,
        area: _areaController.text.trim(),
        areaUnit: _areaUnit,
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        notes: _notesController.text.trim(),
        imageFile: _selectedImage,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.farmId == null
              ? 'Farm created successfully'
              : 'Farm updated successfully'),
            backgroundColor: AppConstants.forestGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(farmProvider.error ?? 'Failed to save farm'),
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
      backgroundColor: isDark ? const Color(0xFF0d0f0a) : const Color(0xFFF5F7F0),
      appBar: AppBar(
        title: Text(
          widget.farmId == null ? 'Add New Farm' : 'Edit Farm',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1a1a16) : Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    GlassCard.large(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppConstants.limeGreen,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Basic Information',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Name Field
                          _buildLabel('Farm Name *', isDark),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'e.g., Sector A Greenhouse',
                            icon: Icons.agriculture_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Farm name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Main Category Dropdown
                          FarmCategoryDropdown(
                            label: 'Main Category *',
                            value: _mainCategory,
                            items: FarmCategories.mainCategories,
                            onChanged: _onMainCategoryChanged,
                            icon: Icons.category_outlined,
                          ),
                          const SizedBox(height: 20),

                          // Sub Category Dropdown
                          FarmCategoryDropdown(
                            label: 'Sub Category *',
                            value: _category,
                            items: FarmCategories.subCategories[_mainCategory]!,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _category = value);
                              }
                            },
                            icon: Icons.dashboard_outlined,
                          ),
                          const SizedBox(height: 20),

                          // Area Field
                          _buildLabel('Area *', isDark),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _areaController,
                                  hintText: 'e.g., 500',
                                  icon: Icons.square_foot_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Area is required';
                                    }
                                    if (double.tryParse(value.trim()) == null) {
                                      return 'Enter valid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FarmCategoryDropdown(
                                  label: '',
                                  value: _areaUnit,
                                  items: FarmCategories.areaUnits[_mainCategory]!,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _areaUnit = value);
                                    }
                                  },
                                  icon: Icons.straighten_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Additional Details Section
                    GlassCard.large(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.details_outlined,
                                color: AppConstants.limeGreen,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Additional Details',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Location Field with FREE Photon (OpenStreetMap) Autocomplete
                          _buildLabel('Location (Optional)', isDark),
                          const SizedBox(height: 8),
                          PhotonLocationField(
                            controller: _locationController,
                            initialValue: _existingFarm?.location,
                            onPlaceSelected: (lat, lng, address) {
                              setState(() {
                                _latitude = lat;
                                _longitude = lng;
                                _locationController.text = address;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Notes Field
                          _buildLabel('Notes (Optional)', isDark),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _notesController,
                            hintText: 'Add any additional notes...',
                            icon: Icons.notes_outlined,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),

                          // Image Picker
                          _buildLabel('Farm Image (Optional)', isDark),
                          const SizedBox(height: 8),
                          GlassImagePickerField(
                            initialImage: _selectedImage,
                            initialImageUrl: _existingFarm?.getImageUrl(
                              ApiConfig.baseUrl,
                            ),
                            onImageSelected: (file) {
                              setState(() => _selectedImage = file);
                            },
                            hintText: 'Select farm image',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: isDark ? Colors.white24 : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.limeGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.farmId == null ? 'Create Farm' : 'Update Farm',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: AppConstants.limeGreen,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.farmId == null
                                ? 'Creating farm...'
                                : 'Updating farm...',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
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
      style: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white70 : Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey[200]!,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.white54 : Colors.grey[400],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
