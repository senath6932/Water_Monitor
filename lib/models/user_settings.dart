class UserSettings {
  UserSettings({
    this.householdSize = 1,
    this.monthlyTarget = 4000,
    this.sleepStart = 0,
    this.sleepEnd = 5,
    this.notificationsEnabled = true,
  });

  final int householdSize;
  final double monthlyTarget;
  final int sleepStart;
  final int sleepEnd;
  final bool notificationsEnabled;


  factory UserSettings.fromMap(Map<dynamic, dynamic> map) {
    return UserSettings(
      householdSize: _asInt(map['householdSize'], fallback: 1),
      monthlyTarget: _asDouble(map['monthlyTarget'], fallback: 4000),
      sleepStart: _asInt(map['sleepStart'], fallback: 0),
      sleepEnd: _asInt(map['sleepEnd'], fallback: 5),
      notificationsEnabled: _asBool(map['notificationsEnabled'], fallback: true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'householdSize': householdSize,
      'monthlyTarget': monthlyTarget,
      'sleepStart': sleepStart,
      'sleepEnd': sleepEnd,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  static int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _asDouble(dynamic value, {required double fallback}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    return fallback;
  }
}
