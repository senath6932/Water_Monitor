import 'package:firebase_database/firebase_database.dart';

import '../models/alert_data.dart';
import '../models/user_settings.dart';
import '../models/water_data.dart';
import 'firebase_service.dart';

class ContextEngine {
  ContextEngine({FirebaseService? firebaseService, FirebaseDatabase? database})
    : _firebaseService = firebaseService ?? FirebaseService(),
      _database = database ?? FirebaseDatabase.instance;

  static const Duration _duplicateWindow = Duration(minutes: 10);

  final FirebaseService _firebaseService;
  final FirebaseDatabase _database;
  final Map<String, int> _recentAlertTimestamps = <String, int>{};

  DatabaseReference get _waterRef => _database.ref('water');
  DatabaseReference get _settingsRef => _database.ref('settings');
  DatabaseReference get _alertsRef => _database.ref('alerts');

  Future<void> evaluateContext({
    WaterData? water,
    UserSettings? settings,
  }) async {
    final resolvedWater = water ?? await _fetchCurrentWaterData();
    final resolvedSettings = settings ?? await _fetchCurrentSettings();

    await _checkMonthlyTarget(resolvedWater, resolvedSettings);
    await _checkNightUsage(resolvedWater, resolvedSettings);
    await _checkLeak(resolvedWater);
  }

  Future<void> _checkMonthlyTarget(
    WaterData water,
    UserSettings settings,
  ) async {
    if (water.totalUsage <= settings.monthlyTarget) {
      return;
    }

    await _saveAlert(
      const _AlertSpec(
        key: 'monthly_target',
        title: 'Monthly target exceeded',
        message: 'Water consumption exceeded your monthly goal.',
        severity: 'warning',
      ),
    );
  }

  Future<void> _checkNightUsage(
    WaterData water,
    UserSettings settings,
  ) async {
    if (water.lastUpdated <= 0 || water.flowRate <= 1.0) {
      return;
    }

    final dateTime = _toDateTime(water.lastUpdated);
    if (!isWithinSleepHours(dateTime.hour, settings.sleepStart, settings.sleepEnd)) {
      return;
    }

    await _saveAlert(
      const _AlertSpec(
        key: 'night_usage',
        title: 'Night-time usage',
        message: 'Water usage detected during sleeping hours.',
        severity: 'warning',
      ),
    );
  }

  Future<void> _checkLeak(WaterData water) async {
    if (!water.leakDetected) {
      return;
    }

    await _saveAlert(
      const _AlertSpec(
        key: 'leak',
        title: 'Possible leak',
        message: 'Continuous flow detected.',
        severity: 'critical',
      ),
    );
  }

  Future<void> _saveAlert(_AlertSpec alert) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTriggeredAt = _recentAlertTimestamps[alert.key];
    if (lastTriggeredAt != null && now - lastTriggeredAt < _duplicateWindow.inMilliseconds) {
      return;
    }

    final recentAlerts = await _loadRecentAlerts();
    for (final existing in recentAlerts) {
      if (existing.title == alert.title &&
          now - existing.timestamp < _duplicateWindow.inMilliseconds) {
        _recentAlertTimestamps[alert.key] = existing.timestamp;
        return;
      }
    }

    await _firebaseService.createAlert(
      title: alert.title,
      message: alert.message,
      severity: alert.severity,
    );
    _recentAlertTimestamps[alert.key] = now;
  }

  Future<WaterData> _fetchCurrentWaterData() async {
    final snapshot = await _waterRef.get();
    final value = snapshot.value;
    if (value is Map) {
      return WaterData.fromMap(Map<String, dynamic>.from(value));
    }

    return WaterData(
      flowRate: 0,
      totalUsage: 0,
      dailyUsage: 0,
      leakDetected: false,
    );
  }

  Future<UserSettings> _fetchCurrentSettings() async {
    final snapshot = await _settingsRef.get();
    final value = snapshot.value;
    if (value is Map) {
      return UserSettings.fromMap(Map<dynamic, dynamic>.from(value));
    }

    return UserSettings();
  }

  Future<List<AlertData>> _loadRecentAlerts() async {
    final snapshot = await _alertsRef.orderByChild('timestamp').limitToLast(25).get();
    final value = snapshot.value;
    if (value is! Map) {
      return <AlertData>[];
    }

    final items = <AlertData>[];
    for (final rawEntry in value.values) {
      if (rawEntry is Map) {
        items.add(AlertData.fromMap(Map<dynamic, dynamic>.from(rawEntry)));
      }
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  static bool isWithinSleepHours(
    int currentHour,
    int startHour,
    int endHour,
  ) {
    if (startHour < endHour) {
      return currentHour >= startHour && currentHour < endHour;
    }

    return currentHour >= startHour || currentHour < endHour;
  }

  DateTime _toDateTime(int timestamp) {
    if (timestamp <= 0) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final milliseconds = timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}

class _AlertSpec {
  const _AlertSpec({
    required this.key,
    required this.title,
    required this.message,
    required this.severity,
  });

  final String key;
  final String title;
  final String message;
  final String severity;
}
