# Weather API Integration - Open-Meteo

## ✅ Integration Complete

Your Flutter app now fetches **real-time weather data** from the Open-Meteo API (no API key required!).

## 🌍 What Was Set Up

### 1. Weather Service Created
**File:** `lib/services/weather_service.dart`

Features:
- ✅ Fetches current weather for any coordinates
- ✅ No API key required (Open-Meteo is free and open-source)
- ✅ Pre-configured for Sri Lankan cities
- ✅ Maps weather codes to conditions (Sunny, Cloudy, Rainy, etc.)
- ✅ Returns icon paths for your downloaded weather icons
- ✅ Error handling with fallback to mock data

### 2. Dashboard Updated
**File:** `lib/screens/dashboard_screen.dart`

Changes:
- ✅ Automatically fetches weather on dashboard load
- ✅ Displays real weather for **Colombo, Sri Lanka**
- ✅ Shows current temperature, high/low temps, and condition
- ✅ Graceful fallback to mock data if API fails
- ✅ Updates day and date automatically

## 🌤️ API Details

### Endpoint
```
https://api.open-meteo.com/v1/forecast
```

### No API Key Required!
Open-Meteo is completely free and doesn't require registration or API keys.

### Features Available
- Current weather
- Temperature (current, high, low)
- Weather conditions (WMO codes)
- Wind speed and direction
- Unlimited requests
- No rate limiting

## 📍 Supported Sri Lankan Cities

Your app comes pre-configured with these cities:

| City | Coordinates |
|------|------------|
| **Colombo** | 6.9271, 79.8612 |
| Kandy | 7.2906, 80.6337 |
| Galle | 6.0535, 80.2210 |
| Jaffna | 9.6615, 80.0255 |
| Trincomalee | 8.5874, 81.2152 |
| Anuradhapura | 8.3114, 80.4037 |
| Batticaloa | 7.7310, 81.6747 |
| Negombo | 7.2083, 79.8358 |

## 🔄 How It Works

### 1. Dashboard Loads
When the dashboard screen opens:
```dart
@override
void initState() {
  super.initState();
  _loadWeatherData(); // Fetches weather data
}
```

### 2. API Call
The app calls Open-Meteo API for Colombo:
```dart
final result = await _weatherService.getWeatherByCity('Colombo');
```

### 3. Data Display
Weather widget shows:
- **Location:** "Colombo, Sri Lanka"
- **Day:** Automatically calculated (e.g., "Monday")
- **Date:** Current date (e.g., "13 Feb, 2026")
- **Temperature:** Real-time (e.g., "28°C")
- **High/Low:** From API (e.g., "32°/24°")
- **Condition:** Mapped from weather code (e.g., "Sunny")

## 🎯 Weather Condition Mapping

The API returns WMO weather codes which are mapped to conditions:

| Code Range | Condition | Icon |
|-----------|-----------|------|
| 0 | Clear | sunny.png |
| 1-3 | Cloudy | cloudy.png |
| 45-48 | Foggy | cloudy.png |
| 51-67 | Rainy | rainy.png |
| 71-77 | Snowy | rainy.png |
| 80-82 | Rainy | rainy.png |
| 95-99 | Thunderstorm | thunderstorm.png |

## 🔧 Usage Examples

### Get Weather by City Name
```dart
final weatherService = WeatherService();
final result = await weatherService.getWeatherByCity('Kandy');

if (result['success']) {
  final data = result['data'];
  print('Temperature: ${data['temperature']}°C');
  print('Condition: ${weatherService.getWeatherCondition(data['weatherCode'])}');
}
```

### Get Weather by Coordinates
```dart
final result = await weatherService.getCurrentWeather(
  latitude: 6.9271,  // Colombo
  longitude: 79.8612,
);
```

### Get Weather Icon Path
```dart
final weatherCode = 0; // Clear sky
final iconPath = weatherService.getWeatherIconPath(weatherCode);
// Returns: 'assets/Icons/sunny.png'
```

## 📱 What You'll See

On the dashboard, the weather widget will display:

```
📍 Colombo, Sri Lanka

Monday
13 Feb, 2026

28°C                     [Weather Icon]
Sunny

High: 32°
Low: 24°
```

## 🛠️ Customization

### Change Default City

Edit `lib/screens/dashboard_screen.dart`:

```dart
// Change from Colombo to another city
final result = await _weatherService.getWeatherByCity('Kandy');

// Or use custom coordinates
final result = await _weatherService.getCurrentWeather(
  latitude: YOUR_LAT,
  longitude: YOUR_LONG,
);
```

### Add More Cities

Edit `lib/services/weather_service.dart`:

```dart
static const Map<String, Map<String, double>> sriLankaCities = {
  'Colombo': {'latitude': 6.9271, 'longitude': 79.8612},
  'YourCity': {'latitude': XX.XXXX, 'longitude': XX.XXXX}, // Add here
};
```

### Update Refresh Interval

The weather currently loads once when dashboard opens. To add auto-refresh:

```dart
Timer.periodic(Duration(minutes: 30), (_) {
  _loadWeatherData(); // Refresh every 30 minutes
});
```

## ✅ Testing

### Test the Integration

1. **Run the app:**
   ```bash
   flutter run -d chrome -t lib/main_local.dart
   ```

2. **Check the dashboard:**
   - Weather widget should show real Colombo weather
   - Temperature should be current
   - Day and date should be today's date

3. **Check console for errors:**
   - Look for any API errors
   - Weather data should load successfully

### Expected Behavior

**Success:**
- Real weather data for Colombo
- Current day and date
- Appropriate weather icon
- Actual temperature values

**Fallback (if API fails):**
- Mock weather data displayed
- No app crash
- Console shows error message

## 🌐 API Reference

**Official Documentation:** https://open-meteo.com/en/docs

**Endpoint used:**
```
GET https://api.open-meteo.com/v1/forecast?latitude=6.9271&longitude=79.8612&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=Asia/Colombo&forecast_days=1
```

**Response format:**
```json
{
  "current_weather": {
    "temperature": 28.5,
    "weathercode": 0,
    "windspeed": 5.2,
    "winddirection": 180,
    "time": "2026-02-13T10:00"
  },
  "daily": {
    "temperature_2m_max": [32.1],
    "temperature_2m_min": [24.3],
    "weathercode": [0]
  }
}
```

## 🎉 Benefits

✅ **Free Forever** - No API key, no limits, no charges
✅ **No Registration** - Start using immediately
✅ **Accurate Data** - High-quality weather data
✅ **Global Coverage** - Works anywhere in the world
✅ **Fast Response** - Low latency API
✅ **Open Source** - Community-driven project

---

**Your app now has real-time weather data!** 🌤️

The weather widget will automatically fetch and display current weather conditions for Colombo, Sri Lanka every time the dashboard loads.
