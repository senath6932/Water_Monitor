import '../models/water_data.dart';

class ContextService {
  static String getInsight(WaterData data) {
    if (data.leakDetected) {
      return '🚨 Possible leak detected.';
    }

    final dateTime = _toDateTime(data.lastUpdated);
    final hour = dateTime.hour;

    if (hour >= 0 && hour <= 5 && data.flowRate > 1.0) {
      return '🌙 Unexpected water usage during sleeping hours.';
    }

    return '✅ System healthy and stable.';
  }

  static DateTime _toDateTime(int timestamp) {
    if (timestamp <= 0) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final milliseconds = timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}
