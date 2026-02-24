import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../models/task_model.dart';
import '../models/crop_model.dart';
import '../providers/crop_provider.dart';
import 'glass_card.dart';

/// Task Form Widget
/// Reusable form for creating and editing tasks
class TaskFormWidget extends StatefulWidget {
  final Task? task; // null for create, Task object for edit
  final Function(Map<String, dynamic> data) onSubmit;
  final VoidCallback? onCancel;

  const TaskFormWidget({
    super.key,
    this.task,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<TaskFormWidget> createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _dueDate;
  String _status = TaskConstants.statusPending;
  String _category = TaskConstants.categoryTask;
  int? _selectedCropId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  void _loadTaskData() {
    if (widget.task != null) {
      // Edit mode - populate with existing data
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _dueDate = widget.task!.dueDate;
      _status = widget.task!.status;
      _category = widget.task!.category;
      _selectedCropId = widget.task!.cropId;
    } else {
      // Create mode - set due date to tomorrow
      _dueDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    HapticFeedback.lightImpact();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.limeGreen,
              onPrimary: Colors.white,
              surface: isDark ? DesignSystem.darkSurface : Colors.white,
              onSurface: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'dueDate': _dueDate,
      'status': _status,
      'category': _category,
      'cropId': _selectedCropId,
    };

    widget.onSubmit(data);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cropProvider = Provider.of<CropProvider>(context);
    final availableCrops = cropProvider.crops;

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
                  widget.task == null ? Icons.add_task : Icons.edit,
                  color: AppConstants.limeGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.task == null ? 'Create New Task' : 'Edit Task',
                  style: DesignSystem.heading(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppConstants.lightSage
                        : AppConstants.darkGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Title Field
            _buildTextField(
              label: 'Task Title *',
              controller: _titleController,
              hint: 'E.g., Apply fertilizer to wheat field',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description Field
            _buildTextField(
              label: 'Description',
              controller: _descriptionController,
              hint: 'Add more details about this task...',
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Due Date and Category Row
            Row(
              children: [
                // Due Date
                Expanded(
                  child: _buildDateField(),
                ),
                const SizedBox(width: 16),

                // Category
                Expanded(
                  child: _buildDropdown(
                    label: 'Category *',
                    value: _category,
                    items: TaskConstants.allCategories,
                    displayNames: TaskConstants.categoryDisplayNames,
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status and Crop Row
            Row(
              children: [
                // Status
                Expanded(
                  child: _buildDropdown(
                    label: 'Status *',
                    value: _status,
                    items: TaskConstants.allStatuses,
                    displayNames: TaskConstants.statusDisplayNames,
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Linked Crop (Optional)
                Expanded(
                  child: _buildCropDropdown(availableCrops),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            widget.onCancel?.call();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
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
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Submit Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppConstants.limeGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.task == null ? 'Create Task' : 'Update Task',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignSystem.text(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: DesignSystem.text(
            fontSize: 15,
            color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: DesignSystem.text(
              fontSize: 15,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.limeGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date *',
          style: DesignSystem.text(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dueDate != null
                        ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                        : 'Select date',
                    style: DesignSystem.text(
                      fontSize: 15,
                      color: _dueDate != null
                          ? (isDark ? AppConstants.lightSage : AppConstants.darkGreen)
                          : (isDark ? Colors.grey.shade600 : Colors.grey.shade500),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Map<String, String> displayNames,
    required void Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignSystem.text(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                displayNames[item] ?? item,
                style: DesignSystem.text(
                  fontSize: 15,
                  color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          style: DesignSystem.text(
            fontSize: 15,
            color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.limeGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          dropdownColor: isDark ? DesignSystem.darkSurface : Colors.white,
        ),
      ],
    );
  }

  Widget _buildCropDropdown(List<Crop> crops) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Linked Crop (Optional)',
          style: DesignSystem.text(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int?>(
          initialValue: _selectedCropId,
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'None',
                style: DesignSystem.text(
                  fontSize: 15,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
            ),
            ...crops.map((Crop crop) {
              return DropdownMenuItem<int?>(
                value: crop.id,
                child: Text(
                  crop.name,
                  style: DesignSystem.text(
                    fontSize: 15,
                    color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCropId = value;
            });
          },
          style: DesignSystem.text(
            fontSize: 15,
            color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.limeGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          dropdownColor: isDark ? DesignSystem.darkSurface : Colors.white,
          isExpanded: true,
        ),
      ],
    );
  }
}
