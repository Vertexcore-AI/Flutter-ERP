import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../providers/crop_cycle_provider.dart';
import '../services/secure_storage_service.dart';
import '../widgets/crop_cycle_card.dart';
import '../widgets/app_bar_glass.dart';

class CropCyclesPage extends StatefulWidget {
  const CropCyclesPage({super.key});

  @override
  State<CropCyclesPage> createState() => _CropCyclesPageState();
}

class _CropCyclesPageState extends State<CropCyclesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _secureStorage = SecureStorageService();
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page
    if (_authToken != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleRefresh();
        }
      });
    }
  }

  Future<void> _loadToken() async {
    try {
      _authToken = await _secureStorage.getAuthToken();

      if (_authToken != null && mounted) {
        final provider =
            Provider.of<CropCycleProvider>(context, listen: false);
        await provider.fetchCropCycles(_authToken!);
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
      final provider = Provider.of<CropCycleProvider>(context, listen: false);
      await provider.fetchCropCycles(_authToken!);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Consumer<CropCycleProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.cropCycles.isEmpty) {
              return Column(
                children: [
                  AppBarGlass(
                    mode: AppBarMode.title,
                    title: 'Crop Cycles',
                    subtitle: 'Lifecycle management & resource tracking',
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

            if (provider.cropCycles.isEmpty) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBarGlass(
                      mode: AppBarMode.title,
                      title: 'Crop Cycles',
                      subtitle: 'Lifecycle management & resource tracking',
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
                      title: 'Crop Cycles',
                      subtitle: 'Lifecycle management & resource tracking',
                    ),
                    const SizedBox(height: 24),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.cropCycles.length,
                      itemBuilder: (context, index) {
                        final cycle = provider.cropCycles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CropCycleCard(cycle: cycle),
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
                Icons.refresh,
                size: 64,
                color: AppConstants.limeGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Crop Cycles Yet',
              style: DesignSystem.heading(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crop cycles are created automatically when you add new crops.',
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
