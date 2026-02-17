import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../providers/crop_provider.dart';
import '../widgets/crop_card.dart';
import 'crop_form_screen.dart';

class CropsPage extends StatefulWidget {
  const CropsPage({super.key});

  @override
  State<CropsPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    print('CropsPage._loadToken - token: ${_authToken != null ? "found" : "null"}'); // DEBUG
    if (_authToken != null && mounted) {
      final cropProvider = Provider.of<CropProvider>(context, listen: false);
      print('CropsPage._loadToken - calling fetchCrops'); // DEBUG
      await cropProvider.fetchCrops(_authToken!);
      print('CropsPage._loadToken - fetchCrops completed'); // DEBUG
    } else {
      print('CropsPage._loadToken - token is null or widget not mounted'); // DEBUG
    }
  }

  Future<void> _handleRefresh() async {
    if (_authToken != null) {
      final cropProvider = Provider.of<CropProvider>(context, listen: false);
      await cropProvider.fetchCrops(_authToken!);
    }
  }

  void _navigateToForm({int? cropId}) {
    if (_authToken == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropFormScreen(
          authToken: _authToken!,
          cropId: cropId,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int cropId, String cropType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Crop',
          style: DesignSystem.heading(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "$cropType"? This action cannot be undone.',
          style: DesignSystem.text(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: DesignSystem.text()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: DesignSystem.text()),
          ),
        ],
      ),
    );

    if (confirmed == true && _authToken != null && mounted) {
      final cropProvider = Provider.of<CropProvider>(context, listen: false);
      final success = await cropProvider.deleteCrop(
        token: _authToken!,
        cropId: cropId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Crop deleted successfully' : cropProvider.error ?? 'Failed to delete crop'),
            backgroundColor: success ? AppConstants.forestGreen : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DesignSystem.darkScaffoldBackground
          : DesignSystem.lightScaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.grass_outlined,
                              color: AppConstants.limeGreen,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Crop Management',
                                style: DesignSystem.heading(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Text(
                            'Track and manage your crop lifecycles',
                            style: DesignSystem.text(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _navigateToForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.limeGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Add',
                          style: DesignSystem.text(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Crops Grid
            Expanded(
              child: Consumer<CropProvider>(
                builder: (context, cropProvider, child) {
                  if (cropProvider.isLoading && cropProvider.crops.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.limeGreen,
                      ),
                    );
                  }

                  if (cropProvider.crops.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: AppConstants.limeGreen,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate max width per card based on screen width
                        double maxCardWidth;
                        if (constraints.maxWidth < 600) {
                          maxCardWidth = constraints.maxWidth - 48; // Mobile (full width minus padding)
                        } else if (constraints.maxWidth < 900) {
                          maxCardWidth = 380; // Small tablet (2 columns)
                        } else if (constraints.maxWidth < 1200) {
                          maxCardWidth = 340; // Large tablet (3 columns)
                        } else {
                          maxCardWidth = 320; // Desktop (4+ columns)
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 110), // Space for nav bar
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: maxCardWidth,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75, // Shorter cards
                            ),
                            itemCount: cropProvider.crops.length,
                            itemBuilder: (context, index) {
                              final crop = cropProvider.crops[index];
                              return CropCard(
                                crop: crop,
                                onEdit: () => _navigateToForm(cropId: crop.id),
                                onDelete: () => _confirmDelete(
                                  context,
                                  crop.id,
                                  crop.cropType,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConstants.limeGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.grass_outlined,
                size: 64,
                color: AppConstants.limeGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Crops Yet',
              style: DesignSystem.heading(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your crop lifecycles by adding your first crop.',
              style: DesignSystem.text(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.limeGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Your First Crop',
                style: DesignSystem.text(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
