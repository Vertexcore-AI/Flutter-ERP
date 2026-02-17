import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/dashboard_models.dart';
import '../widgets/glass_card.dart';
import '../widgets/production_chart_widget.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static final mockProduction = ProductionData(
    wheat: '30%',
    corn: '20%',
    rice: '50%',
    totalTons: '1,000 Tons',
  );

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Icon(Icons.bar_chart_outlined, color: AppConstants.limeGreen, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Analytics Dashboard',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'View farm performance and insights',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            // Key Metrics
            if (isMobile)
              Column(
                children: [
                  _buildMetricCard(context, 'Total Revenue', '\$500,000', '+18.48%', Icons.trending_up, Colors.green),
                  const SizedBox(height: 16),
                  _buildMetricCard(context, 'Total Yield', '1,000 Tons', '+12.5%', Icons.agriculture, AppConstants.limeGreen),
                  const SizedBox(height: 16),
                  _buildMetricCard(context, 'Active Fields', '15', '+3', Icons.landscape, AppConstants.forestGreen),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: _buildMetricCard(context, 'Total Revenue', '\$500,000', '+18.48%', Icons.trending_up, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard(context, 'Total Yield', '1,000 Tons', '+12.5%', Icons.agriculture, AppConstants.limeGreen)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard(context, 'Active Fields', '15', '+3', Icons.landscape, AppConstants.forestGreen)),
                ],
              ),
            const SizedBox(height: 32),
            // Production Chart
            ProductionChartWidget(production: mockProduction),
            const SizedBox(height: 32),
            // Monthly Trends
            GlassCard(
              intensity: GlassIntensity.medium,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Trends',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTrendRow(context, 'January', '850 Tons', '+5%'),
                  _buildTrendRow(context, 'February', '920 Tons', '+8%'),
                  _buildTrendRow(context, 'March', '1,000 Tons', '+9%'),
                  _buildTrendRow(context, 'April', '980 Tons', '+7%'),
                  _buildTrendRow(context, 'May', '1,050 Tons', '+7%'),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, String change, IconData icon, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      intensity: GlassIntensity.medium,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.arrow_upward, color: AppConstants.forestGreen, size: 14),
              const SizedBox(width: 4),
              Text(
                change,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppConstants.forestGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendRow(BuildContext context, String month, String value, String change) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              month,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(Icons.arrow_upward, color: AppConstants.forestGreen, size: 14),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppConstants.forestGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
