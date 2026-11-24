import 'package:firebase_database/firebase_database.dart';

import '../models/alert_data.dart';
import '../models/user_settings.dart';
import '../models/water_data.dart';

class FirebaseService {
  FirebaseService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference get _waterRef => _database.ref('water');
  DatabaseReference get _historyRef => _database.ref('history');
  DatabaseReference get _alertsRef => _database.ref('alerts');
  DatabaseReference get _settingsRef => _database.ref('settings');

  Stream<WaterData> watchCurrentWaterData() {
    return _waterRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return WaterData.fromMap(Map<String, dynamic>.from(value));
      }
      return WaterData(
        flowRate: 0,
        totalUsage: 0,
        dailyUsage: 0,
        leakDetected: false,
      );
    });
  }

  Stream<List<WaterData>> watchHistory() {
    return _historyRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return <WaterData>[];
      }

      final entries = Map<String, dynamic>.from(value);
      final items = <WaterData>[];

      for (final entry in entries.entries) {
        final rawValue = entry.value;
        if (rawValue is Map) {
          final data = Map<String, dynamic>.from(rawValue);
          data['lastUpdated'] ??= _parseTimestamp(entry.key);
          items.add(WaterData.fromMap(data));
        }
      }

      items.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
      return items;
    });
  }

  Stream<List<AlertData>> watchAlerts() {
    return _alertsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return <AlertData>[];
      }

      final entries = Map<String, dynamic>.from(value);
      final items = <AlertData>[];

      for (final entry in entries.values) {
        if (entry is Map) {
          items.add(AlertData.fromMap(Map<String, dynamic>.from(entry)));
        }
      }

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    });
  }

  Stream<double> watchMonthlyTarget() {
    return _settingsRef.child('monthlyTarget').onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) {
        return 4000.0;
      }

      return (value as num).toDouble();
    });
  }

  Stream<UserSettings> watchSettings() {
    return _settingsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return UserSettings.fromMap(Map<dynamic, dynamic>.from(value));
      }

      return UserSettings();
    });
  }

  Future<void> updateSettings(UserSettings settings) async {
    await _settingsRef.set(settings.toMap());
  }

  Future<void> createAlert({
    required String title,
    required String message,
    required String severity,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _alertsRef.child(timestamp.toString()).set({
      'title': title,
      'message': message,
      'severity': severity,
      'timestamp': timestamp,
      'read': false,
    });
  }

  int _parseTimestamp(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
