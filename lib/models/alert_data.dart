class AlertData {
  final String title;
  final String message;
  final String severity;
  final int timestamp;
  final bool read;

  AlertData({
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.read,
  });

  factory AlertData.fromMap(Map<dynamic, dynamic> map) {
    return AlertData(
      title: _asString(map['title']),
      message: _asString(map['message']),
      severity: _asString(map['severity']),
      timestamp: _asInt(map['timestamp']),
      read: _asBool(map['read']),
    );
  }

  static String _asString(dynamic value) {
    return value?.toString() ?? '';
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
