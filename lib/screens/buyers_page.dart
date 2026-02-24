import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../models/buyer_model.dart';
import '../providers/buyer_provider.dart';
import '../widgets/app_bar_glass.dart';
import '../widgets/glass_card.dart';
import '../widgets/buyer_card.dart';
import '../widgets/buyer_form_widget.dart';

/// Buyers Page
/// Full CRUD interface for buyer management
class BuyersPage extends StatefulWidget {
  const BuyersPage({super.key});

  @override
  State<BuyersPage> createState() => _BuyersPageState();
}

class _BuyersPageState extends State<BuyersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _showForm = false;
  Buyer? _editingBuyer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final buyerProvider = Provider.of<BuyerProvider>(context, listen: false);
    await buyerProvider.fetchBuyers();
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _showCreateForm() {
    HapticFeedback.lightImpact();
    setState(() {
      _editingBuyer = null;
      _showForm = true;
    });
  }

  void _showEditForm(Buyer buyer) {
    HapticFeedback.lightImpact();
    setState(() {
      _editingBuyer = buyer;
      _showForm = true;
    });
  }

  void _hideForm() {
    setState(() {
      _showForm = false;
      _editingBuyer = null;
    });
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    final buyerProvider = Provider.of<BuyerProvider>(context, listen: false);

    bool success;

    if (_editingBuyer == null) {
      // Create new buyer
      success = await buyerProvider.createBuyer(
        name: data['name'],
        city: data['city'],
        province: data['province'],
        postalCode: data['postalCode'],
        latitude: data['latitude'],
        longitude: data['longitude'],
      );
    } else {
      // Update existing buyer
      success = await buyerProvider.updateBuyer(
        buyerId: _editingBuyer!.id,
        name: data['name'],
        city: data['city'],
        province: data['province'],
        postalCode: data['postalCode'],
        latitude: data['latitude'],
        longitude: data['longitude'],
      );
    }

    if (success && mounted) {
      _hideForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingBuyer == null
                ? 'Buyer created successfully'
                : 'Buyer updated successfully',
          ),
          backgroundColor: AppConstants.forestGreen,
        ),
      );
    } else if (mounted && buyerProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(buyerProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete(Buyer buyer) async {
    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteConfirmDialog(buyer),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final buyerProvider = Provider.of<BuyerProvider>(context, listen: false);

    final success = await buyerProvider.deleteBuyer(buyer.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buyer deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted && buyerProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(buyerProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDeleteConfirmDialog(Buyer buyer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? DesignSystem.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
      ),
      title: Text(
        'Delete Buyer',
        style: DesignSystem.text(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${buyer.name}"? This action cannot be undone.',
        style: DesignSystem.text(
          fontSize: 14,
          color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: DesignSystem.text(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
            ),
          ),
          child: Text(
            'Delete',
            style: DesignSystem.text(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buyerProvider = Provider.of<BuyerProvider>(context);

    return GlassCard(
      intensity: GlassIntensity.medium,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppConstants.limeGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.store_outlined,
              color: AppConstants.limeGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Buyers',
                  style: DesignSystem.text(
                    fontSize: 14,
                    color: isDark
                        ? AppConstants.lightSage.withValues(alpha: 0.8)
                        : AppConstants.darkGreen.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${buyerProvider.totalBuyers}',
                  style: DesignSystem.text(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppConstants.lightSage : AppConstants.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: isDark
                ? AppConstants.lightSage.withValues(alpha: 0.3)
                : AppConstants.darkGreen.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No buyers yet',
            style: DesignSystem.text(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppConstants.lightSage.withValues(alpha: 0.6)
                  : AppConstants.darkGreen.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first buyer to get started',
            style: DesignSystem.text(
              fontSize: 14,
              color: isDark
                  ? AppConstants.lightSage.withValues(alpha: 0.5)
                  : AppConstants.darkGreen.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 1; // Mobile: 1 column
    } else if (width < 1200) {
      return 2; // Tablet: 2 columns
    } else {
      return 3; // Desktop: 3 columns
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final buyerProvider = Provider.of<BuyerProvider>(context);
    final buyers = buyerProvider.allBuyers;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Glass - Fixed at top
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: AppBarGlass(
                mode: AppBarMode.title,
                title: 'Buyers',
                subtitle: 'Manage your buyers',
              ),
            ),
            const SizedBox(height: 16),

            // Add Buyer Button - Top Right Corner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showCreateForm,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: Text(
                      'Add Buyer',
                      style: DesignSystem.text(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.limeGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppConstants.limeGreen,
                child: buyerProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppConstants.limeGreen,
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Card
                            _buildSummaryCard(context),
                            const SizedBox(height: 24),

                            // Form (if visible)
                            if (_showForm) ...[
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutCubic,
                                child: BuyerFormWidget(
                                  buyer: _editingBuyer,
                                  onSubmit: _handleFormSubmit,
                                  onCancel: _hideForm,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Buyers Grid
                            if (buyers.isEmpty)
                              SizedBox(
                                height: 300,
                                child: _buildEmptyState(),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _getCrossAxisCount(screenWidth),
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.5,
                                ),
                                itemCount: buyers.length,
                                itemBuilder: (context, index) {
                                  final buyer = buyers[index];
                                  return BuyerCard(
                                    buyer: buyer,
                                    onEdit: () => _showEditForm(buyer),
                                    onDelete: () => _handleDelete(buyer),
                                  );
                                },
                              ),
                          ],
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
