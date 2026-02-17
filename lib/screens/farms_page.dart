import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../config/api_config.dart';
import '../providers/farm_provider.dart';
import '../widgets/farm_card.dart';
import 'farm_form_screen.dart';

class FarmsPage extends StatefulWidget {
  const FarmsPage({super.key});

  @override
  State<FarmsPage> createState() => _FarmsPageState();
}

class _FarmsPageState extends State<FarmsPage> with AutomaticKeepAliveClientMixin {
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
    if (_authToken != null && mounted) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      await farmProvider.fetchFarms(_authToken!);
    }
  }

  Future<void> _handleRefresh() async {
    if (_authToken != null) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      await farmProvider.fetchFarms(_authToken!);
    }
  }

  void _navigateToForm({int? farmId}) {
    if (_authToken == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmFormScreen(
          authToken: _authToken!,
          farmId: farmId,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int farmId, String farmName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Farm',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "$farmName"? This will also remove all linked crops.',
          style: GoogleFonts.spaceGrotesk(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.spaceGrotesk()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.spaceGrotesk()),
          ),
        ],
      ),
    );

    if (confirmed == true && _authToken != null && mounted) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final success = await farmProvider.deleteFarm(
        token: _authToken!,
        farmId: farmId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Farm deleted successfully' : farmProvider.error ?? 'Failed to delete farm'),
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
      backgroundColor: isDark ? const Color(0xFF0d0f0a) : const Color(0xFFF5F7F0),
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
                        Text(
                          'Farm Management',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your farm instances',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                          style: GoogleFonts.spaceGrotesk(
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

            // Farms Grid
            Expanded(
              child: Consumer<FarmProvider>(
                builder: (context, farmProvider, child) {
                  if (farmProvider.isLoading && farmProvider.farms.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.limeGreen,
                      ),
                    );
                  }

                  if (farmProvider.farms.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: AppConstants.limeGreen,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1200
                            ? 4
                            : constraints.maxWidth > 900
                                ? 3
                                : constraints.maxWidth > 600
                                    ? 2
                                    : 1;

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: farmProvider.farms.length,
                          itemBuilder: (context, index) {
                            final farm = farmProvider.farms[index];
                            return FarmCard(
                              farm: farm,
                              baseUrl: ApiConfig.baseUrl,
                              onEdit: () => _navigateToForm(farmId: farm.id),
                              onDelete: () => _confirmDelete(context, farm.id, farm.name),
                            );
                          },
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No farms yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first farm to get started',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
