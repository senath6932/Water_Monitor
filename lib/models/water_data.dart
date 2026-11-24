class WaterData {
  final double flowRate;
  final double totalUsage;
  final double dailyUsage;
  final bool leakDetected;
  final int lastUpdated;

  WaterData({
    required this.flowRate,
    required this.totalUsage,
    required this.dailyUsage,
    required this.leakDetected,
    this.lastUpdated = 0,
  });

  factory WaterData.fromMap(Map<String, dynamic> map) {
    return WaterData(
      flowRate: _asDouble(map['flowRate']),
      totalUsage: _asDouble(map['totalUsage']),
      dailyUsage: _asDouble(map['dailyUsage']),
      leakDetected: _asBool(map['leakDetected']),
      lastUpdated: _asInt(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flowRate': flowRate,
      'totalUsage': totalUsage,
      'dailyUsage': dailyUsage,
      'leakDetected': leakDetected,
      'lastUpdated': lastUpdated,
    };
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}


