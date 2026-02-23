import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../constants/app_constants.dart';
import '../models/crop_cycle_model.dart';
import 'glass_card.dart';
import 'resource_stat_card.dart';
import 'live_update_card.dart';
import 'crop_cycle_menu_button.dart';

/// Crop Cycle Card - Displays crop lifecycle information with management stats
/// Matches the design from Next.js crops page
class CropCycleCard extends StatelessWidget {
  final CropCycle cycle;

  const CropCycleCard({
    super.key,
    required this.cycle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout: Stack vertically on mobile, horizontal on tablet+
        final isMobile = constraints.maxWidth < 600;

        return GlassCard(
          intensity: GlassIntensity.medium,
          child: isMobile
              ? _buildMobileLayout(isDark)
              : _buildDesktopLayout(isDark),
        );
      },
    );
  }

  // Mobile layout: Stack vertically
  Widget _buildMobileLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftSection(isDark),
        const Divider(height: 1),
        _buildRightSection(isDark),
      ],
    );
  }

  // Desktop/Tablet layout: Horizontal flex (1/3 + 2/3)
  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildLeftSection(isDark),
        ),
        VerticalDivider(
          width: 0.5,
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        Expanded(
          flex: 2,
          child: _buildRightSection(isDark),
        ),
      ],
    );
  }

  // ============================================================================
  // LEFT SECTION - Crop Info
  // ============================================================================
  Widget _buildLeftSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.limeGreen.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and Crop Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.limeGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.limeGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grass,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cycle.cropType.toUpperCase(),
                  style: DesignSystem.heading(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Menu button
              CropCycleMenuButton(
                cropCycleId: cycle.id,
                cropName: cycle.cropType,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cycle.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: cycle.statusColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Text(
              cycle.status.toUpperCase(),
              style: DesignSystem.text(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: cycle.statusColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Farm Instance
          Row(
            children: [
              Icon(
                Icons.map,
                size: 14,
                color: AppConstants.limeGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'INSTANCE: ${cycle.displayFarm.toUpperCase()}',
                  style: DesignSystem.text(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppConstants.limeGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // RIGHT SECTION - Metadata and Stats
  // ============================================================================
  Widget _buildRightSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Metadata Row (Start Date, Est. Harvest, Population, Water Usage)
          _buildMetadataRow(isDark),
          const SizedBox(height: 20),

          // Resource Overview Cards (Row 1)
          _buildResourceOverview(isDark),
          const SizedBox(height: 12),

          // Resource Overview Cards (Row 2)
          _buildResourceOverviewRow2(isDark),
          const SizedBox(height: 20),

          // Today's Data Section (LIVE cards)
          if (cycle.hasTodaysActivity) ...[
            _buildTodaysDataSection(isDark),
            const SizedBox(height: 20),
          ],

          // Technical Observations (Notes)
          if (cycle.notes != null && cycle.notes!.isNotEmpty)
            _buildNotesSection(isDark, cycle.notes!),
        ],
      ),
    );
  }

  // Metadata Row: 3 columns
  Widget _buildMetadataRow(bool isDark) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        _buildMetadataItem(
          isDark,
          'Start Date',
          cycle.formattedStartDate,
        ),
        _buildMetadataItem(
          isDark,
          'Est. Harvest',
          cycle.formattedExpectedHarvestDate ?? 'TBD',
        ),
        _buildMetadataItem(
          isDark,
          'Population',
          '${cycle.plants.toStringAsFixed(0)} Units',
        ),
      ],
    );
  }

  Widget _buildMetadataItem(bool isDark, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: DesignSystem.text(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: DesignSystem.text(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Resource Overview: 4 small cards (responsive grid)
  Widget _buildResourceOverview(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ResourceStatCard(
            icon: Icons.water_drop,
            iconColor: Colors.blue,
            label: 'Water Total',
            value: '${cycle.totalWater.toStringAsFixed(0)} L',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ResourceStatCard(
            icon: Icons.eco,
            iconColor: Colors.green,
            label: 'Fertilizer',
            value: '${cycle.fertilizerLogsCount} Logs',
          ),
        ),
      ],
    );
  }

  Widget _buildResourceOverviewRow2(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ResourceStatCard(
            icon: Icons.bug_report,
            iconColor: Colors.red,
            label: 'Pesticide',
            value: '${cycle.pesticideLogsCount} Logs',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ResourceStatCard(
            icon: Icons.local_florist,
            iconColor: Colors.purple,
            label: 'Fungicide',
            value: '${cycle.fungicideLogsCount} Logs',
          ),
        ),
      ],
    );
  }

  // Today's Data Section: LIVE update cards
  Widget _buildTodaysDataSection(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Water Update
        if (cycle.todaysWatering > 0)
          SizedBox(
            width: 160,
            child: LiveUpdateCard(
              icon: Icons.water_drop,
              color: Colors.blue.shade600,
              label: 'Water Update',
              value: cycle.todaysWatering.toStringAsFixed(0),
              unit: 'liters today',
            ),
          ),

        // Fertilizer
        if (cycle.todaysFertilizer.isNotEmpty)
          SizedBox(
            width: 160,
            child: LiveUpdateCard(
              icon: Icons.eco,
              color: Colors.green.shade600,
              label: 'Fertilizer',
              value: cycle.todaysFertilizer.length.toString(),
              unit: cycle.todaysFertilizer.first.displayName,
            ),
          ),

        // Pesticide
        if (cycle.todaysPesticide.isNotEmpty)
          SizedBox(
            width: 160,
            child: LiveUpdateCard(
              icon: Icons.bug_report,
              color: Colors.red.shade600,
              label: 'Pesticide',
              value: cycle.todaysPesticide.length.toString(),
              unit: cycle.todaysPesticide.first.displayName,
            ),
          ),

        // Fungicide
        if (cycle.todaysFungicide.isNotEmpty)
          SizedBox(
            width: 160,
            child: LiveUpdateCard(
              icon: Icons.local_florist,
              color: Colors.purple.shade600,
              label: 'Fungicide',
              value: cycle.todaysFungicide.length.toString(),
              unit: cycle.todaysFungicide.first.displayName,
            ),
          ),
      ],
    );
  }

  // Notes Section
  Widget _buildNotesSection(bool isDark, String notes) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : AppConstants.lightSage.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppConstants.limeGreen,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TECHNICAL OBSERVATIONS',
            style: DesignSystem.text(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppConstants.limeGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: DesignSystem.text(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white70 : Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
