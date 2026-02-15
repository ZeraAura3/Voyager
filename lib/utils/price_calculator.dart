// lib/utils/price_calculator.dart

/// Utility class for calculating ticket prices based on routes
class PriceCalculator {
  /// Predefined routes with fixed prices (in INR)
  static const Map<String, Map<String, double>> _routePrices = {
    'IIT Mandi (North Campus)': {
      'IIT Mandi (South Campus)': 3.0,
      'Mandi': 15.0,
      'Mandi ISBT': 15.0,
    },
    'North Campus': {
      'South Campus': 3.0,
      'Mandi': 15.0,
      'Mandi ISBT': 15.0,
    },
    // Reverse routes
    'IIT Mandi (South Campus)': {
      'IIT Mandi (North Campus)': 3.0,
      'Mandi': 12.0,
    },
    'South Campus': {
      'North Campus': 3.0,
      'Mandi': 12.0,
      'Mandi ISBT': 12.0,
    },
    'Mandi': {
      'IIT Mandi (North Campus)': 15.0,
      'IIT Mandi (South Campus)': 12.0,
      'North Campus': 15.0,
      'South Campus': 12.0,
    },
    'Mandi ISBT': {
      'IIT Mandi (North Campus)': 15.0,
      'IIT Mandi (South Campus)': 12.0,
      'North Campus': 15.0,
      'South Campus': 12.0,
    },
  };

  /// Calculate price for a given route
  /// Returns null if route not found in predefined prices
  static double? calculatePrice({
    required String fromLocation,
    required String toLocation,
  }) {
    // Normalize location names (trim and handle case variations)
    final from = _normalizeLocation(fromLocation);
    final to = _normalizeLocation(toLocation);

    // Check direct route
    if (_routePrices.containsKey(from) && _routePrices[from]!.containsKey(to)) {
      return _routePrices[from]![to];
    }

    return null;
  }

  /// Normalize location name for matching
  static String _normalizeLocation(String location) {
    final normalized = location.trim();

    // Handle common variations
    if (normalized.toLowerCase().contains('north campus')) {
      return 'North Campus';
    }
    if (normalized.toLowerCase().contains('south campus')) {
      return 'South Campus';
    }
    if (normalized.toLowerCase() == 'mandi' ||
        normalized.toLowerCase().contains('mandi isbt')) {
      return normalized.contains('ISBT') ? 'Mandi ISBT' : 'Mandi';
    }

    return normalized;
  }

  /// Get list of common locations
  static List<String> getCommonLocations() {
    return [
      'IIT Mandi (North Campus)',
      'IIT Mandi (South Campus)',
      'North Campus',
      'South Campus',
      'Mandi',
      'Mandi ISBT',
    ];
  }

  /// Check if a route has a predefined price
  static bool hasFixedPrice({
    required String fromLocation,
    required String toLocation,
  }) {
    return calculatePrice(
          fromLocation: fromLocation,
          toLocation: toLocation,
        ) !=
        null;
  }
}
