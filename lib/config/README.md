# Design System Configuration Guide

## Quick Start: Changing Fonts & Colors

All design tokens (fonts, colors, spacing, etc.) are now centralized in **`design_system.dart`** for easy customization.

---

## 🔤 How to Change the Font

### Option 1: Change App-Wide Font
Open [`design_system.dart`](design_system.dart) and update line 24:

```dart
// Current (Manrope)
static TextStyle Function({...}) get primaryFont => GoogleFonts.manrope;

// Change to Plus Jakarta Sans
static TextStyle Function({...}) get primaryFont => GoogleFonts.plusJakartaSans;

// Change to Outfit
static TextStyle Function({...}) get primaryFont => GoogleFonts.outfit;

// Change to DM Sans
static TextStyle Function({...}) get primaryFont => GoogleFonts.dmSans;
```

Then update the TextTheme methods (lines 49 & 55):
```dart
// Light mode
static TextTheme lightTextTheme() {
  return GoogleFonts.plusJakartaSansTextTheme().apply(  // Match your choice
    bodyColor: AppConstants.darkGreen,
    displayColor: AppConstants.darkGreen,
  );
}

// Dark mode
static TextTheme darkTextTheme() {
  return GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: AppConstants.lightSage,
    displayColor: AppConstants.lightSage,
  );
}
```

### Option 2: Use Different Font for Headings
To use a different font for headings vs body text:

```dart
// Body text font
static TextStyle Function({...}) get primaryFont => GoogleFonts.dmSans;

// Heading font
static TextStyle Function({...}) get headingFont => GoogleFonts.plusJakartaSans;
```

---

## 🎨 How to Change Colors

### Quick Color Updates
Edit the color constants in [`design_system.dart`](design_system.dart) (lines 62-80):

```dart
/// Primary brand color - CTAs, buttons, active states
static const Color primary = Color(0xFF9dac17); // Change this hex code

/// Secondary - backgrounds, subtle fills
static const Color secondary = Color(0xFFccd4a4);

/// Accent - success, completed states
static const Color accent = Color(0xFF74981e);
```

### Full Color Palette Change
To change the entire agriculture color palette:

1. Open [`lib/constants/app_constants.dart`](../constants/app_constants.dart)
2. Update the 6 main colors (lines 5-10):
   ```dart
   static const Color limeGreen = Color(0xFF9dac17);
   static const Color lightSage = Color(0xFFccd4a4);
   static const Color forestGreen = Color(0xFF74981e);
   static const Color olive = Color(0xFF97a25c);
   static const Color beige = Color(0xFFcfcabb);
   static const Color darkGreen = Color(0xFF5d7534);
   ```

---

## ✨ How to Adjust Glass Effect

### Increase/Decrease Blur Strength
Edit blur constants in [`design_system.dart`](design_system.dart) (lines 94-97):

```dart
// Current values
static const double glassBlurSmall = 6.0;   // Increase to 8.0 for more blur
static const double glassBlurMedium = 10.0; // Increase to 12.0
static const double glassBlurLarge = 12.0;  // Increase to 15.0
static const double glassBlurNav = 15.0;    // Increase to 18.0
```

### Adjust Transparency
Edit alpha values (lines 100-106):

```dart
// Light mode transparency (0.0 = invisible, 1.0 = solid)
static const double glassAlphaLightLarge = 0.75;  // Decrease for more transparency

// Dark mode transparency
static const double glassAlphaDarkLarge = 0.70;   // Decrease for more transparency
```

---

## 📐 Spacing & Radius

### Update Spacing System
Edit spacing constants (lines 111-117):

```dart
static const double spacingMd = 16.0;  // Default card padding
static const double spacingLg = 24.0;  // Large section spacing
```

### Update Border Radius
Edit radius constants (lines 123-128):

```dart
static const double radiusLg = 16.0;   // Card corners
static const double radiusXl = 24.0;   // Large modals
```

---

## 🚀 Using DesignSystem in Your Code

### In Widgets
```dart
import '../config/design_system.dart';

// Use primary color
Container(color: DesignSystem.primary)

// Use custom text style
Text('Hello', style: DesignSystem.text(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: DesignSystem.darkText,
))

// Use heading style
Text('Title', style: DesignSystem.heading(
  fontSize: 24,
  fontWeight: FontWeight.bold,
))

// Use spacing
SizedBox(height: DesignSystem.spacingMd)

// Use border radius
BorderRadius.circular(DesignSystem.radiusLg)
```

---

## 🔄 Hot Reload

After making changes to `design_system.dart`:
1. Save the file
2. Press `r` in terminal for hot reload (Flutter will update the UI instantly)
3. For font changes, you may need to press `R` for hot restart

---

## 📝 Summary

**One file to rule them all:** [`lib/config/design_system.dart`](design_system.dart)

- **Fonts** → Lines 24-55
- **Colors** → Lines 62-80
- **Glass Effects** → Lines 94-106
- **Spacing** → Lines 111-117
- **Border Radius** → Lines 123-128

All widgets in the app automatically use these settings!
