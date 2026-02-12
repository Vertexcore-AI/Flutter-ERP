import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dashboard_models.dart';
import 'glass_card.dart';

class WeatherWidget extends StatelessWidget {
  final WeatherInfo weather;

  const WeatherWidget({super.key, required this.weather});

  // Map weather condition to icon path
  String _getWeatherIconPath(String condition) {
    final conditionLower = condition.toLowerCase();

    if (conditionLower.contains('sunny') || conditionLower.contains('clear')) {
      return 'assets/Icons/sunny.png';
    } else if (conditionLower.contains('cloud')) {
      return 'assets/Icons/cloudy.png';
    } else if (conditionLower.contains('rain')) {
      return 'assets/Icons/rainy.png';
    } else if (conditionLower.contains('wind')) {
      return 'assets/Icons/windy.png';
    } else if (conditionLower.contains('thunder') || conditionLower.contains('storm')) {
      return 'assets/Icons/thunderstorm.png';
    }

    // Default to sunny
    return 'assets/Icons/sunny.png';
  }

  // Get icon background color based on condition
  Color _getIconColor(String condition) {
    final conditionLower = condition.toLowerCase();

    if (conditionLower.contains('sunny') || conditionLower.contains('clear')) {
      return Colors.amber;
    } else if (conditionLower.contains('cloud')) {
      return Colors.blueGrey;
    } else if (conditionLower.contains('rain')) {
      return Colors.blue;
    } else if (conditionLower.contains('wind')) {
      return Colors.cyan;
    } else if (conditionLower.contains('thunder') || conditionLower.contains('storm')) {
      return Colors.deepPurple;
    }

    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _getIconColor(weather.condition);

    return GlassCard.large(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                weather.location,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.day,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    weather.date,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              // Glass-enhanced weather icon with Freepik assets
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Image.asset(
                  _getWeatherIconPath(weather.condition),
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.temperature,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    weather.condition,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'High: ${weather.highTemp}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Low: ${weather.lowTemp}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
