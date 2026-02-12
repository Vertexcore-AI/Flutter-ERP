# Weather Icons

Downloaded from Freepik using MCP server.

## Icon Set

All icons are 512x512 PNG format for high quality display.

### 1. sunny.png ☀️
- **ID**: 15013384
- **Name**: Daylight
- **Family**: Nuricon - Generic color lineal-color
- **Description**: Clear sunny weather icon with sun rays
- **Tags**: weather, sun, summer, sunshine, sunny, daylight
- **Size**: 17KB

### 2. cloudy.png ☁️
- **ID**: 15013574
- **Name**: Cloudy
- **Family**: Nuricon - Generic color lineal-color
- **Description**: Cloudy weather icon with sun partially behind clouds
- **Tags**: sky, weather, sun, cloud, cloudy, climate, meteorology, forecast
- **Size**: 21KB

### 3. rainy.png 🌧️
- **ID**: 15012792
- **Name**: Rain
- **Family**: Nuricon - Generic color lineal-color
- **Description**: Rainy weather icon with cloud and raindrops
- **Tags**: weather, cloud, climate, downpour, rain, meteorology, rainy, forecast
- **Size**: 24KB

### 4. windy.png 💨
- **ID**: 16349950
- **Name**: Windy
- **Family**: Elastic1 - Generic color lineal-color
- **Description**: Windy weather icon with cloud and wind lines (no snow)
- **Tags**: air, wind, cloud, blow, windy, forecast
- **Size**: 31KB

### 5. thunderstorm.png ⛈️
- **ID**: 2766177
- **Name**: Thunderstorm
- **Family**: Freepik - Special Lineal color
- **Description**: Thunderstorm icon with cloud, lightning bolt, and rain
- **Tags**: weather, storm, cloud, climate, thunderstorm, thunder, rainy, forecast, thunderbolt, lightning bolt
- **Size**: 30KB

### 6. weather_sunny_cloudy.png 🌤️ (Bonus)
- **ID**: 9480117
- **Name**: Weather (Mixed conditions)
- **Family**: Nuricon - Generic color lineal-color
- **Description**: Combination sunny/cloudy/rainy weather icon
- **Tags**: weather, storm, sun, cloud, sunny, rain, rainy, forecast, cloudy day, rainy day
- **Size**: 20KB

## Usage in Flutter

Add to your pubspec.yaml:
```yaml
flutter:
  assets:
    - assets/Icons/
```

Then use in your code:
```dart
// Sunny weather
Image.asset('assets/Icons/sunny.png', width: 64, height: 64)

// Cloudy weather
Image.asset('assets/Icons/cloudy.png', width: 64, height: 64)

// Rainy weather
Image.asset('assets/Icons/rainy.png', width: 64, height: 64)

// Windy weather
Image.asset('assets/Icons/windy.png', width: 64, height: 64)

// Thunderstorm
Image.asset('assets/Icons/thunderstorm.png', width: 64, height: 64)
```

## Weather Widget Integration

These icons are perfect for the weather widget in the dashboard. Example usage:

```dart
Widget _getWeatherIcon(String condition) {
  final iconMap = {
    'sunny': 'assets/Icons/sunny.png',
    'clear': 'assets/Icons/sunny.png',
    'cloudy': 'assets/Icons/cloudy.png',
    'overcast': 'assets/Icons/cloudy.png',
    'rainy': 'assets/Icons/rainy.png',
    'rain': 'assets/Icons/rainy.png',
    'windy': 'assets/Icons/windy.png',
    'wind': 'assets/Icons/windy.png',
    'thunderstorm': 'assets/Icons/thunderstorm.png',
    'storm': 'assets/Icons/thunderstorm.png',
  };

  return Image.asset(
    iconMap[condition.toLowerCase()] ?? 'assets/Icons/sunny.png',
    width: 64,
    height: 64,
    fit: BoxFit.contain,
  );
}
```

## License
Downloaded from Freepik - https://www.freepik.com/
- Nuricon icons: https://www.freepik.com/author/nuricon
- Freepik icons: https://www.freepik.com/
