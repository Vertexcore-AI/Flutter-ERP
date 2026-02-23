class UnitConverter {
  // Conversion tables (match backend logic)
  static const Map<String, double> _massConversions = {
    'kg': 1000,
    'g': 1,
    'mg': 0.001,
  };

  static const Map<String, double> _volumeConversions = {
    'l': 1000,
    'ml': 1,
    'bottle': 1000,
  };

  // Unit normalization map (handle plurals, full names, aliases)
  static const Map<String, String> _unitAliases = {
    // Mass units
    'kilogram': 'kg',
    'kilograms': 'kg',
    'kgs': 'kg',
    'kilo': 'kg',
    'gram': 'g',
    'grams': 'g',
    'gms': 'g',
    'milligram': 'mg',
    'milligrams': 'mg',
    'mgs': 'mg',
    // Volume units
    'liter': 'l',
    'liters': 'l',
    'litre': 'l',
    'litres': 'l',
    'ltr': 'l',
    'milliliter': 'ml',
    'milliliters': 'ml',
    'mls': 'ml',
    'bottle': 'bottle',
    'bottles': 'bottle',
    'btl': 'bottle',
  };

  /// Normalize unit names (handle plurals, full names)
  /// Converts any variant of unit name to standardized form
  /// Example: "kilograms" → "kg", "litres" → "l"
  static String normalizeUnit(String unit) {
    final normalized = unit.toLowerCase().trim();
    return _unitAliases[normalized] ?? normalized;
  }

  /// Convert amount between compatible units
  /// Returns null if units are incompatible (mass ↔ volume)
  /// Example: convert(1, 'kg', 'g') → 1000.0
  /// Example: convert(1, 'kg', 'ml') → null (incompatible)
  static double? convert(double amount, String fromUnit, String toUnit) {
    final from = normalizeUnit(fromUnit);
    final to = normalizeUnit(toUnit);

    // Try mass conversion
    if (_massConversions.containsKey(from) &&
        _massConversions.containsKey(to)) {
      final baseAmount = amount * _massConversions[from]!;
      return baseAmount / _massConversions[to]!;
    }

    // Try volume conversion
    if (_volumeConversions.containsKey(from) &&
        _volumeConversions.containsKey(to)) {
      final baseAmount = amount * _volumeConversions[from]!;
      return baseAmount / _volumeConversions[to]!;
    }

    // Incompatible units (mass to volume or vice versa)
    return null;
  }

  /// Get equivalent display string for amount in target unit
  /// Returns formatted string or "Incompatible units" if conversion fails
  /// Example: getEquivalent(1, 'kg', 'g') → "1000.00 g"
  static String getEquivalent(double amount, String unit, String targetUnit) {
    final converted = convert(amount, unit, targetUnit);
    if (converted == null) return 'Incompatible units';
    return '${converted.toStringAsFixed(2)} $targetUnit';
  }

  /// Check if two units are compatible for conversion
  /// Returns true if both are mass units or both are volume units
  static bool areCompatible(String unit1, String unit2) {
    final u1 = normalizeUnit(unit1);
    final u2 = normalizeUnit(unit2);

    final bothMass =
        _massConversions.containsKey(u1) && _massConversions.containsKey(u2);
    final bothVolume = _volumeConversions.containsKey(u1) &&
        _volumeConversions.containsKey(u2);

    return bothMass || bothVolume;
  }

  /// Get unit type (mass or volume)
  /// Returns 'mass', 'volume', or 'unknown'
  static String getUnitType(String unit) {
    final normalized = normalizeUnit(unit);

    if (_massConversions.containsKey(normalized)) {
      return 'mass';
    }

    if (_volumeConversions.containsKey(normalized)) {
      return 'volume';
    }

    return 'unknown';
  }
}
