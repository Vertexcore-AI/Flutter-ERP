import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:fl_chart/fl_chart.dart';  // Backup - keeping for reference
import '../constants/app_constants.dart';
import '../models/dashboard_models.dart';
import 'glass_card.dart';

class ProductionChartWidget extends StatefulWidget {
  final ProductionData production;

  const ProductionChartWidget({super.key, required this.production});

  @override
  State<ProductionChartWidget> createState() => _ProductionChartWidgetState();
}

class _ProductionChartWidgetState extends State<ProductionChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _wheatAnimation;
  late Animation<double> _cornAnimation;
  late Animation<double> _riceAnimation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Staggered animations for each ring
    _wheatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _cornAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _riceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    // Calculate which ring was touched
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final distance = (localPosition - center).distance;

    setState(() {
      // Distance-based ring detection (with tolerance)
      if (distance >= 42 && distance <= 58) {
        touchedIndex = 0; // Wheat (inner ring)
      } else if (distance >= 58 && distance <= 74) {
        touchedIndex = 1; // Corn (middle ring)
      } else if (distance >= 74 && distance <= 90) {
        touchedIndex = 2; // Rice (outer ring)
      } else {
        touchedIndex = -1; // Outside rings
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Parse percentages from strings like "30%"
    final wheatPercent = double.parse(widget.production.wheat.replaceAll('%', ''));
    final cornPercent = double.parse(widget.production.corn.replaceAll('%', ''));
    final ricePercent = double.parse(widget.production.rice.replaceAll('%', ''));

    return GlassCard.large(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Production Overview',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              // Glass Dropdown Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppConstants.darkGreen.withValues(alpha: 0.08),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppConstants.darkGreen.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Yearly',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Circular Progress Ring Chart
          Center(
            child: SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Custom painter for rings
                  GestureDetector(
                    onTapDown: _handleTapDown,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(220, 220),
                          painter: CircularProgressRingPainter(
                            wheatProgress: (wheatPercent / 100) * _wheatAnimation.value,
                            cornProgress: (cornPercent / 100) * _cornAnimation.value,
                            riceProgress: (ricePercent / 100) * _riceAnimation.value,
                            selectedIndex: touchedIndex,
                            isDark: isDark,
                            wheatColor: AppConstants.forestGreen,
                            cornColor: AppConstants.limeGreen,
                            riceColor: AppConstants.olive,
                          ),
                        );
                      },
                    ),
                  ),

                  // Center text (value + label)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.production.totalTons,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Production',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Interactive Legend
          _buildLegend(wheatPercent, cornPercent, ricePercent, isDark),
        ],
      ),
    );
  }

  Widget _buildLegend(double wheatPercent, double cornPercent, double ricePercent, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(0, 'Wheat', wheatPercent, AppConstants.forestGreen, isDark),
        const SizedBox(height: 8),
        _buildLegendItem(1, 'Corn', cornPercent, AppConstants.limeGreen, isDark),
        const SizedBox(height: 8),
        _buildLegendItem(2, 'Rice', ricePercent, AppConstants.olive, isDark),
      ],
    );
  }

  Widget _buildLegendItem(int index, String label, double percentage, Color color, bool isDark) {
    final isSelected = touchedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => touchedIndex = index),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            '${percentage.toInt()}%',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CircularProgressRingPainter - Custom Painter for Concentric Rings
// ============================================================================

class CircularProgressRingPainter extends CustomPainter {
  final double wheatProgress;
  final double cornProgress;
  final double riceProgress;
  final int selectedIndex;
  final bool isDark;
  final Color wheatColor;
  final Color cornColor;
  final Color riceColor;

  CircularProgressRingPainter({
    required this.wheatProgress,
    required this.cornProgress,
    required this.riceProgress,
    required this.selectedIndex,
    required this.isDark,
    required this.wheatColor,
    required this.cornColor,
    required this.riceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Ring configuration (concentric layout)
    const baseStrokeWidth = 12.0;
    const ringGap = 4.0;
    const wheatRadius = 50.0;
    const cornRadius = wheatRadius + baseStrokeWidth + ringGap;
    const riceRadius = cornRadius + baseStrokeWidth + ringGap;

    // Draw background rings (inactive state)
    _drawBackgroundRing(canvas, center, wheatRadius, baseStrokeWidth);
    _drawBackgroundRing(canvas, center, cornRadius, baseStrokeWidth);
    _drawBackgroundRing(canvas, center, riceRadius, baseStrokeWidth);

    // Draw progress arcs with gradients
    _drawProgressArc(
      canvas,
      center,
      wheatRadius,
      wheatProgress,
      wheatColor,
      baseStrokeWidth,
      isSelected: selectedIndex == 0,
    );
    _drawProgressArc(
      canvas,
      center,
      cornRadius,
      cornProgress,
      cornColor,
      baseStrokeWidth,
      isSelected: selectedIndex == 1,
    );
    _drawProgressArc(
      canvas,
      center,
      riceRadius,
      riceProgress,
      riceColor,
      baseStrokeWidth,
      isSelected: selectedIndex == 2,
    );
  }

  void _drawBackgroundRing(Canvas canvas, Offset center, double radius, double strokeWidth) {
    final backgroundPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.grey[300]!.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
  }

  void _drawProgressArc(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
    Color baseColor,
    double strokeWidth,
    {required bool isSelected}
  ) {
    if (progress <= 0) return;

    // Adjust stroke width and color for selection
    final adjustedStrokeWidth = isSelected ? strokeWidth + 2.0 : strokeWidth;
    final adjustedColor = isSelected
        ? Color.lerp(baseColor, Colors.white, 0.15)!
        : baseColor;

    // Create gradient shader
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      colors: [
        adjustedColor.withValues(alpha: 0.7),
        adjustedColor,
        adjustedColor.withValues(alpha: 0.7),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = adjustedStrokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc (start from top, sweep clockwise)
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressRingPainter oldDelegate) {
    return wheatProgress != oldDelegate.wheatProgress ||
           cornProgress != oldDelegate.cornProgress ||
           riceProgress != oldDelegate.riceProgress ||
           selectedIndex != oldDelegate.selectedIndex ||
           isDark != oldDelegate.isDark;
  }
}
