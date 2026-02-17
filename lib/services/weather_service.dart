import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetch current weather for given coordinates
  /// Sri Lanka coordinates: Colombo (6.9271, 79.8612)
  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      '$baseUrl?latitude=$latitude&longitude=$longitude'
      '&current_weather=true'
      '&daily=temperature_2m_max,temperature_2m_min,weathercode'
      '&timezone=Asia/Colombo'
      '&forecast_days=1',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final currentWeather = data['current_weather'];
        final daily = data['daily'];

        return {
          'success': true,
          'data': {
            'temperature': currentWeather['temperature'],
            'weatherCode': currentWeather['weathercode'],
            'windSpeed': currentWeather['windspeed'],
            'windDirection': currentWeather['winddirection'],
            'time': currentWeather['time'],
            'highTemp': daily['temperature_2m_max'][0],
            'lowTemp': daily['temperature_2m_min'][0],
            'dailyWeatherCode': daily['weathercode'][0],
          }
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch weather data. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Map WMO weather codes to readable conditions
  /// Reference: https://open-meteo.com/en/docs
  String getWeatherCondition(int code) {
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Cloudy';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 67) return 'Rainy';
    if (code >= 71 && code <= 77) return 'Snowy';
    if (code >= 80 && code <= 82) return 'Rainy';
    if (code >= 85 && code <= 86) return 'Snowy';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  /// Get icon path based on weather code
  String getWeatherIconPath(int code) {
    if (code == 0) return 'assets/Icons/sunny.png';
    if (code >= 1 && code <= 3) return 'assets/Icons/cloudy.png';
    if (code >= 45 && code <= 48) return 'assets/Icons/cloudy.png';
    if (code >= 51 && code <= 67) return 'assets/Icons/rainy.png';
    if (code >= 71 && code <= 77) return 'assets/Icons/rainy.png'; // Snow (use rain for Sri Lanka)
    if (code >= 80 && code <= 82) return 'assets/Icons/rainy.png';
    if (code >= 85 && code <= 86) return 'assets/Icons/rainy.png';
    if (code >= 95 && code <= 99) return 'assets/Icons/thunderstorm.png';
    return 'assets/Icons/sunny.png';
  }

  /// Common Sri Lankan cities with coordinates
  static const Map<String, Map<String, double>> sriLankaCities = {
    'Colombo': {'latitude': 6.9271, 'longitude': 79.8612},
    'Kandy': {'latitude': 7.2906, 'longitude': 80.6337},
    'Galle': {'latitude': 6.0535, 'longitude': 80.2210},
    'Jaffna': {'latitude': 9.6615, 'longitude': 80.0255},
    'Trincomalee': {'latitude': 8.5874, 'longitude': 81.2152},
    'Anuradhapura': {'latitude': 8.3114, 'longitude': 80.4037},
    'Batticaloa': {'latitude': 7.7310, 'longitude': 81.6747},
    'Negombo': {'latitude': 7.2083, 'longitude': 79.8358},
  };

  /// Get weather for a Sri Lankan city by name
  Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    final coords = sriLankaCities[cityName];
    if (coords == null) {
      return {
        'success': false,
        'error': 'City not found. Available cities: ${sriLankaCities.keys.join(", ")}'
      };
    }

    return getCurrentWeather(
      latitude: coords['latitude']!,
      longitude: coords['longitude']!,
    );
  }
}
