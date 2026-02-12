import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dashboard_models.dart';

class ProductionChartWidget extends StatelessWidget {
  final ProductionData production;

  const ProductionChartWidget({super.key, required this.production});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.grey[300]!,
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
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Semi-circular gauge placeholder
            Center(
              child: SizedBox(
                height: 120,
                width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background semi-circle
                    CustomPaint(
                      size: const Size(200, 100),
                      painter: SemiCircleGaugePainter(
                        wheatPercent: 30,
                        cornPercent: 20,
                        ricePercent: 50,
                      ),
                    ),
                    // Center value
                    Positioned(
                      bottom: 20,
                      child: Text(
                        production.totalTons,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  context,
                  color: Colors.purple[400]!,
                  label: 'Wheat',
                  value: production.wheat,
                ),
                _buildLegendItem(
                  context,
                  color: Colors.blue[400]!,
                  label: 'Corn',
                  value: production.corn,
                ),
                _buildLegendItem(
                  context,
                  color: Colors.green[400]!,
                  label: 'Rice',
                  value: production.rice,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SemiCircleGaugePainter extends CustomPainter {
  final double wheatPercent;
  final double cornPercent;
  final double ricePercent;

  SemiCircleGaugePainter({
    required this.wheatPercent,
    required this.cornPercent,
    required this.ricePercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final strokeWidth = 20.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Total is 180 degrees (pi radians)
    final wheatAngle = (wheatPercent / 100) * 3.14159;
    final cornAngle = (cornPercent / 100) * 3.14159;
    final riceAngle = (ricePercent / 100) * 3.14159;

    // Draw wheat segment (purple)
    paint.color = Colors.purple[400]!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.14159, // Start from left (180 degrees)
      wheatAngle,
      false,
      paint,
    );

    // Draw corn segment (blue)
    paint.color = Colors.blue[400]!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.14159 + wheatAngle,
      cornAngle,
      false,
      paint,
    );

    // Draw rice segment (green)
    paint.color = Colors.green[400]!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.14159 + wheatAngle + cornAngle,
      riceAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
