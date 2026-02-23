import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../constants/app_constants.dart';
import '../../services/fertilizer_management_service.dart';
import '../../services/crop_service.dart';
import '../../services/secure_storage_service.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_item_model.dart';
import '../../widgets/resource_form_header.dart';
import '../../widgets/application_type_toggle.dart';
import '../../widgets/calculated_total_display.dart';
import '../../widgets/stock_impact_display.dart';
import '../../widgets/glass_card.dart';
import '../../utils/unit_converter.dart';

class FertilizerLogFormScreen extends StatefulWidget {
  final int cropCycleId;
  final String cropName;

  const FertilizerLogFormScreen({
    super.key,
    required this.cropCycleId,
    required this.cropName,
  });

  @override
  State<FertilizerLogFormScreen> createState() =>
      _FertilizerLogFormScreenState();
}

class _FertilizerLogFormScreenState extends State<FertilizerLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fertilizerManagementService = FertilizerManagementService();
  final _cropService = CropService();
  final _secureStorage = SecureStorageService();

  // Form fields
  DateTime _selectedDate = DateTime.now();
  String _applicationType = 'BY_PLANT';
  String? _applicationMethod = 'Manual';
  final TextEditingController _amountPerPlantController =
      TextEditingController();
  String _unit = 'g';
  final TextEditingController _notesController = TextEditingController();

  // Inventory selection
  int? _selectedInventoryId;
  InventoryItem? _selectedInventory;
  List<InventoryItem> _inventoryOptions = [];

  // State
  bool _isLoading = false;
  bool _isLoadingCrop = true;
  bool _isLoadingInventory = true;
  int _numberOfPlants = 1;
  String? _authToken;

  final List<String> _applicationMethods = [
    'Manual',
    'Drip',
    'Sprayer',
    'Broadcasting'
  ];
  final List<String> _units = ['kg', 'g', 'mg', 'l', 'ml', 'bottle'];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    _amountPerPlantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    try {
      _authToken = await _secureStorage.getAuthToken();
      if (_authToken != null && mounted) {
        await Future.wait([
          _fetchCropDetails(),
          _loadInventoryOptions(),
        ]);
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

  Future<void> _loadInventoryOptions() async {
    setState(() => _isLoadingInventory = true);

    try {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      await provider.fetchInventory(_authToken!);

      if (mounted) {
        // Filter inventory items by fertilizer category
        final filtered = provider.items
            .where((item) =>
                item.category.toLowerCase().contains('fertilizer'))
            .toList();

        setState(() {
          _inventoryOptions = filtered;
          _isLoadingInventory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInventory = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load inventory: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String get _amountPerPlantCalculated {
    final totalAmount =
        double.tryParse(_amountPerPlantController.text) ?? 0.0;

    if (totalAmount == 0.0 || _numberOfPlants == 0) {
      return '0.00 $_unit';
    }

    final perPlant = totalAmount / _numberOfPlants;
    return '${perPlant.toStringAsFixed(2)} $_unit';
  }

  double get _calculatedTotal {
    final amountPerPlant =
        double.tryParse(_amountPerPlantController.text) ?? 0.0;

    if (_applicationType == 'BY_PLANT') {
      // BY_PLANT: multiply amount per plant by number of plants
      return amountPerPlant * _numberOfPlants;
    } else {
      // ENTIRE_CROP: amount is the total directly
      return amountPerPlant;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedInventoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a fertilizer item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check stock availability (client-side warning)
    if (_selectedInventory != null) {
      final convertedUsage = UnitConverter.convert(
        _calculatedTotal,
        _unit,
        _selectedInventory!.unit,
      );

      if (convertedUsage != null &&
          convertedUsage > _selectedInventory!.quantityAvailable) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Insufficient Stock'),
            content: Text(
              'Available: ${_selectedInventory!.quantityAvailable} ${_selectedInventory!.unit}\n'
              'Required: ${convertedUsage.toStringAsFixed(2)} ${_selectedInventory!.unit}\n\n'
              'Do you want to continue anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );

        if (shouldContinue != true) return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final amountPerPlant = double.parse(_amountPerPlantController.text);

      final data = {
        'crop_id': widget.cropCycleId,
        'inventory_id': _selectedInventoryId,
        'application_date': _selectedDate.toIso8601String().split('T')[0],
        'application_type': _applicationType,
        'application_method': _applicationMethod,
        'number_of_plants': _applicationType == 'BY_PLANT' ? _numberOfPlants : 1,
        'amount_per_plant': amountPerPlant,
        'unit': _unit,
        'total_amount_used': _calculatedTotal,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      };

      final result = await _fertilizerManagementService.createFertilizerLog(
          _authToken!, data);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Fertilizer application recorded successfully'),
              backgroundColor: AppConstants.limeGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result['error'] ?? 'Failed to create fertilizer log'),
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
    final isLoading = _isLoadingCrop || _isLoadingInventory;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F5F5),
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
      body: isLoading
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
                              icon: Icons.eco,
                              color: Colors.green.shade600,
                              title: 'Fertilizer Application',
                              subtitle: widget.cropName.toUpperCase(),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Inventory selector
                                  _buildLabel('Select Fertilizer Item'),
                                  const SizedBox(height: 8),
                                  _buildInventoryDropdown(isDark),
                                  const SizedBox(height: 24),

                                  // Date field
                                  _buildLabel('Application Date'),
                                  const SizedBox(height: 8),
                                  _buildDateField(isDark),
                                  const SizedBox(height: 24),

                                  // Application type toggle
                                  _buildLabel('Application Type'),
                                  const SizedBox(height: 8),
                                  ApplicationTypeToggle(
                                    selectedType: _applicationType,
                                    onChanged: (value) {
                                      setState(() {
                                        _applicationType = value;
                                        _amountPerPlantController.clear();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Application method
                                  _buildLabel('Application Method'),
                                  const SizedBox(height: 8),
                                  _buildMethodDropdown(isDark),
                                  const SizedBox(height: 24),

                                  // Dynamic fields based on type
                                  if (_applicationType == 'BY_PLANT') ...[
                                    _buildLabel('Number of Plants'),
                                    const SizedBox(height: 8),
                                    _buildDisabledField(
                                        _numberOfPlants.toString(), isDark),
                                    const SizedBox(height: 24),

                                    _buildLabel('Amount per Plant'),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _buildAmountInputField(isDark),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildUnitDropdown(isDark),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    _buildLabel(
                                        'Total Amount for Entire Crop'),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _buildAmountInputField(isDark),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildUnitDropdown(isDark),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    _buildLabel('Amount per Plant (Calculated)'),
                                    const SizedBox(height: 8),
                                    _buildDisabledField(
                                        _amountPerPlantCalculated, isDark),
                                  ],

                                  const SizedBox(height: 24),

                                  // Unit conversion helper
                                  if (_selectedInventory != null &&
                                      _unit != _selectedInventory!.unit &&
                                      _calculatedTotal > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              Colors.blue.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info_outline,
                                              color: Colors.blue, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Equivalent: ${UnitConverter.getEquivalent(_calculatedTotal, _unit, _selectedInventory!.unit)}',
                                              style: DesignSystem.text(
                                                fontSize: 11,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // Calculated total display
                                  CalculatedTotalDisplay(
                                    total: _calculatedTotal,
                                    unit: _unit,
                                    color: Colors.green.shade600,
                                  ),

                                  const SizedBox(height: 24),

                                  // Stock impact display
                                  if (_selectedInventory != null &&
                                      _calculatedTotal > 0) ...[
                                    StockImpactDisplay(
                                      currentStock:
                                          _selectedInventory!.quantityAvailable.toDouble(),
                                      usedAmount: UnitConverter.convert(
                                            _calculatedTotal,
                                            _unit,
                                            _selectedInventory!.unit,
                                          ) ??
                                          0.0,
                                      unit: _selectedInventory!.unit,
                                    ),
                                    const SizedBox(height: 24),
                                  ],

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
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            Colors.green.shade600
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
                                              'Record Fertilizer Application',
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

  Widget _buildInventoryDropdown(bool isDark) {
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
        child: DropdownButton<int>(
          value: _selectedInventoryId,
          isExpanded: true,
          hint: Text(
            'Select fertilizer item',
            style: DesignSystem.text(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          items: _inventoryOptions.map((item) {
            final isLowStock = item.quantityAvailable < 10;
            return DropdownMenuItem<int>(
              value: item.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.itemName,
                    style: DesignSystem.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Available: ${item.quantityAvailable.toStringAsFixed(2)} ${item.unit}',
                        style: DesignSystem.text(
                          fontSize: 11,
                          color: isLowStock
                              ? Colors.orange
                              : (isDark ? Colors.white60 : Colors.grey[600]),
                        ),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.warning,
                          size: 12,
                          color: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (id) {
            if (id != null) {
              final item =
                  _inventoryOptions.firstWhere((i) => i.id == id);
              setState(() {
                _selectedInventoryId = id;
                _selectedInventory = item;
                _unit = item.unit; // Auto-set unit to match inventory
              });
            }
          },
        ),
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
              color: Colors.green.shade600,
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
          value: _applicationMethod,
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
          items: _applicationMethods.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(method),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _applicationMethod = value);
          },
        ),
      ),
    );
  }

  Widget _buildAmountInputField(bool isDark) {
    return TextFormField(
      controller: _amountPerPlantController,
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
        hintText: _applicationType == 'BY_PLANT'
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
            color: Colors.green.shade600,
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
          value: _unit,
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
          items: _units.map((unit) {
            return DropdownMenuItem(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _unit = value);
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
            color: Colors.green.shade600,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
