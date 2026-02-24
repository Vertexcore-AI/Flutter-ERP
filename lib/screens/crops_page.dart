import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../providers/crop_provider.dart';
import '../services/secure_storage_service.dart';
import '../widgets/crop_card.dart';
import '../widgets/app_bar_glass.dart';
import 'crop_form_screen.dart';

class CropsPage extends StatefulWidget {
  const CropsPage({super.key});

  @override
  State<CropsPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _secureStorage = SecureStorageService();
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      _authToken = await _secureStorage.getAuthToken();

      if (_authToken != null && mounted) {
        final cropProvider = Provider.of<CropProvider>(context, listen: false);
        await cropProvider.fetchCrops(_authToken!);
      } else {
        if (_authToken == null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not authenticated. Please log in.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> _handleRefresh() async {
    if (_authToken != null) {
      final cropProvider = Provider.of<CropProvider>(context, listen: false);
      await cropProvider.fetchCrops(_authToken!);
    }
  }

  void _navigateToForm({int? cropId}) {
    if (_authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropFormScreen(
          authToken: _authToken!,
          cropId: cropId,
        ),
      ),
    ).then((_) {
      if (_authToken != null) {
        _handleRefresh();
      }
    });
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
      body: SafeArea(
        child: Consumer<CropProvider>(
          builder: (context, cropProvider, child) {
            if (cropProvider.isLoading && cropProvider.crops.isEmpty) {
              return Column(
                children: [
                  AppBarGlass(
                    mode: AppBarMode.title,
                    title: 'Crop Management',
                    subtitle: 'Track and manage your crop lifecycles',
                    trailingActions: [
                      IconButton(
                        onPressed: () => _navigateToForm(),
                        icon: const Icon(Icons.add, size: 22),
                        tooltip: 'Add Crop',
                      ),
                    ],
                  ),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.limeGreen,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (cropProvider.crops.isEmpty) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBarGlass(
                      mode: AppBarMode.title,
                      title: 'Crop Management',
                      subtitle: 'Track and manage your crop lifecycles',
                    ),
                    const SizedBox(height: 24),
                    _buildEmptyState(isDark),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppConstants.limeGreen,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBarGlass(
                      mode: AppBarMode.title,
                      title: 'Crop Management',
                      subtitle: 'Track and manage your crop lifecycles',
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToForm(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.limeGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size.zero,
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          'Add Crop',
                          style: DesignSystem.text(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate max width per card based on screen width
                        double maxCardWidth;
                        if (constraints.maxWidth < 600) {
                          maxCardWidth = constraints.maxWidth; // Mobile (full width)
                        } else if (constraints.maxWidth < 900) {
                          maxCardWidth = 380; // Small tablet (2 columns)
                        } else if (constraints.maxWidth < 1200) {
                          maxCardWidth = 340; // Large tablet (3 columns)
                        } else {
                          maxCardWidth = 320; // Desktop (4+ columns)
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
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
          ],
        ),
      ),
    );
  }
}
