import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../models/buyer_model.dart';
import '../widgets/photon_location_field.dart';
import 'glass_card.dart';

/// Buyer Form Widget
/// Reusable form for creating and editing buyers
class BuyerFormWidget extends StatefulWidget {
  final Buyer? buyer; // null for create, Buyer object for edit
  final Function(Map<String, dynamic> data) onSubmit;
  final VoidCallback? onCancel;

  const BuyerFormWidget({
    super.key,
    this.buyer,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<BuyerFormWidget> createState() => _BuyerFormWidgetState();
}

class _BuyerFormWidgetState extends State<BuyerFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBuyerData();
  }

  void _loadBuyerData() {
    if (widget.buyer != null) {
      // Edit mode - populate with existing data
      _nameController.text = widget.buyer!.name;
      _cityController.text = widget.buyer!.city;
      _provinceController.text = widget.buyer!.province;
      _postalCodeController.text = widget.buyer!.postalCode ?? '';
      _latitude = widget.buyer!.latitude;
      _longitude = widget.buyer!.longitude;

      // Set location controller text to formatted location
      _locationController.text = widget.buyer!.formattedLocation();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'city': _cityController.text.trim(),
      'province': _provinceController.text.trim(),
      'postalCode': _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
    };

    widget.onSubmit(data);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      intensity: GlassIntensity.large,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Form Title
            Row(
              children: [
                Icon(
                  Icons.store_outlined,
                  color: AppConstants.limeGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.buyer == null ? 'Add New Buyer' : 'Edit Buyer',
                  style: DesignSystem.text(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                  ),
                ),
                const Spacer(),
                if (widget.onCancel != null)
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Icon(
                      Icons.close,
                      color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                      size: 24,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Buyer/Company Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Buyer/Company Name',
                hintText: 'Enter buyer or company name',
                prefixIcon: Icon(Icons.business_outlined, color: AppConstants.limeGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: AppConstants.limeGreen,
                    width: 2,
                  ),
                ),
                labelStyle: DesignSystem.text(
                  color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                ),
              ),
              style: DesignSystem.text(
                color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter buyer name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                if (value.trim().length > 255) {
                  return 'Name must not exceed 255 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Location Search Field
            Text(
              'Search Location',
              style: DesignSystem.text(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            PhotonLocationField(
              controller: _locationController,
              initialValue: widget.buyer?.formattedLocation(),
              onPlaceSelected: (place) {
                setState(() {
                  _latitude = place.latitude;
                  _longitude = place.longitude;
                  _cityController.text = place.city ?? '';
                  _provinceController.text = place.state ?? '';
                });
              },
            ),
            const SizedBox(height: 20),

            // City Field (auto-filled, manual override allowed)
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                hintText: 'Enter city name',
                prefixIcon: Icon(Icons.location_city_outlined, color: AppConstants.limeGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: AppConstants.limeGreen,
                    width: 2,
                  ),
                ),
                labelStyle: DesignSystem.text(
                  color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                ),
              ),
              style: DesignSystem.text(
                color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter city name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Province Field (auto-filled, manual override allowed)
            TextFormField(
              controller: _provinceController,
              decoration: InputDecoration(
                labelText: 'Province',
                hintText: 'Enter province name',
                prefixIcon: Icon(Icons.map_outlined, color: AppConstants.limeGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: AppConstants.limeGreen,
                    width: 2,
                  ),
                ),
                labelStyle: DesignSystem.text(
                  color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                ),
              ),
              style: DesignSystem.text(
                color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter province name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Postal Code Field (optional)
            TextFormField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: 'Postal Code (Optional)',
                hintText: 'Enter postal code',
                prefixIcon: Icon(Icons.mail_outline, color: AppConstants.limeGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  borderSide: BorderSide(
                    color: AppConstants.limeGreen,
                    width: 2,
                  ),
                ),
                labelStyle: DesignSystem.text(
                  color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                ),
              ),
              style: DesignSystem.text(
                color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 12),

            // Coordinates Display (if available)
            if (_latitude != null && _longitude != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  border: Border.all(
                    color: AppConstants.forestGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      size: 18,
                      color: AppConstants.forestGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Coordinates: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                        style: DesignSystem.text(
                          fontSize: 13,
                          color: AppConstants.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.limeGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.buyer == null ? 'Create Buyer' : 'Update Buyer',
                        style: DesignSystem.text(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
