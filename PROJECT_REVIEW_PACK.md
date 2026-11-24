# Water Monitor Review Pack

Use this file as the source bundle for GPT review.
It includes the project source files most relevant to app behavior, data flow, Firebase integration, and the context-engine pipeline.

## Suggested Review Prompt

Review this Flutter + Firebase + Python project for bugs, architecture issues, UI regressions, data flow problems, and missing tests. Focus on actionable findings with file references, and explain how the system works end to end.

## Notes

- Build artifacts, the local virtualenv, and generated cache folders were intentionally excluded.
- The Firebase service account secret itself is not included. Use `context_engine_python/serviceAccountKey.json.example` as the safe reference.
- The bundle is organized by file path so GPT can review each layer in context.

## System Overview

- Flutter app authenticates users with Firebase Auth and renders a tabbed dashboard.
- The app listens to Firebase Realtime Database nodes for current water data, history, alerts, and user settings.
- Local alerts are shown through `flutter_local_notifications`, and Firebase Messaging is used for push notification delivery.
- A Dart `ContextEngine` evaluates live water readings against settings to generate deduplicated alerts.
- Cloud Functions mirror `/water` updates into `/history` and keep a history state record.
- The Python context engine is a separate, more advanced monitoring loop that reads Firebase, learns a statistical baseline, detects anomalies, and can create alerts plus push notifications.

## README.md
```markdown
# water_monitor

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
```

## analysis_options.yaml
```yaml
# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/flutter.yaml

linter:
  # The lint rules applied to this project can be customized in the
  # section below to disable rules from the `package:flutter_lints/flutter.yaml`
  # included above or to enable additional rules. A list of all available lints
  # and their documentation is published at https://dart.dev/lints.
  #
  # Instead of disabling a lint rule for the entire project in the
  # section below, it can also be suppressed for a single line of code
  # or a specific dart file by using the `// ignore: name_of_lint` and
  # `// ignore_for_file: name_of_lint` syntax on the line or in the file
  # producing the lint.
  rules:
    # avoid_print: false  # Uncomment to disable the `avoid_print` rule
    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule

# Additional information about this file can be found at
# https://dart.dev/guides/language/analysis-options
```

## pubspec.yaml
```yaml
name: water_monitor
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.11.4

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  firebase_core: ^4.1.1
  firebase_database: ^12.0.1
  firebase_auth: ^6.0.0
  firebase_messaging: ^16.0.0
  fl_chart: ^1.0.0
  flutter_local_notifications: ^17.2.2
  timeago: ^3.7.0

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
```

## firebase.json
```json
{"flutter":{"platforms":{"android":{"default":{"projectId":"watermonitor-36e94","appId":"1:847865678329:android:fa97c43e5ba9644a685528","fileOutput":"android/app/google-services.json"}},"dart":{"lib/firebase_options.dart":{"projectId":"watermonitor-36e94","configurations":{"android":"1:847865678329:android:fa97c43e5ba9644a685528","ios":"1:847865678329:ios:cc5ab6d2205ed4c5685528","macos":"1:847865678329:ios:cc5ab6d2205ed4c5685528","web":"1:847865678329:web:ec71d8fbac78b2a7685528","windows":"1:847865678329:web:e322c11af3fbd10a685528"}}}}}}
```

## functions/package.json
```json
{
  "name": "water-monitor-functions",
  "description": "Firebase Cloud Functions for Water Monitor",
  "private": true,
  "engines": {
    "node": "20"
  },
  "main": "index.js",
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "shell": "firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "dependencies": {
    "firebase-admin": "^12.7.0",
    "firebase-functions": "^5.1.1"
  }
}
```

## functions/index.js
```javascript
const admin = require('firebase-admin');
const { onValueWritten } = require('firebase-functions/v2/database');

admin.initializeApp();

const NORMAL_RECORD_INTERVAL_MS = 5 * 60 * 1000;
const HISTORY_STATE_PATH = '/history_state';

exports.mirrorWaterToHistory = onValueWritten('/water', async (event) => {
  const after = event.data.after.val();

  if (!after || typeof after !== 'object') {
    return;
  }

  const now = Date.now();
  const currentStatus = Boolean(after.leakDetected) ? 'leak' : 'normal';
  const stateRef = admin.database().ref(HISTORY_STATE_PATH);
  const stateSnapshot = await stateRef.get();
  const state = stateSnapshot.val() || {};
  const previousStatus = state.lastStatus || null;
  const lastNormalRecordedAt = Number(state.lastNormalRecordedAt) || 0;
  const statusChanged = previousStatus !== currentStatus;
  const shouldRecordNormalSnapshot =
    currentStatus === 'normal' &&
    now - lastNormalRecordedAt >= NORMAL_RECORD_INTERVAL_MS;
  const shouldRecord = statusChanged || shouldRecordNormalSnapshot;

  await stateRef.set({
    lastStatus: currentStatus,
    lastSeenAt: now,
    lastNormalRecordedAt:
      currentStatus === 'normal' && shouldRecord ? now : lastNormalRecordedAt,
  });

  if (!shouldRecord) {
    return;
  }

  const historyEntry = {
    flowRate: Number(after.flowRate) || 0,
    totalUsage: Number(after.totalUsage) || 0,
    dailyUsage: Number(after.dailyUsage) || 0,
    leakDetected: Boolean(after.leakDetected),
    lastUpdated: now,
    sourceUpdatedAt: Number(after.lastUpdated) || 0,
    status: currentStatus,
  };

  await admin.database().ref('history').push(historyEntry);
});
```

## lib/main.dart
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  await NotificationService().listenForNewAlerts();
  runApp(const WaterMonitorApp());
}

class WaterMonitorApp extends StatelessWidget {
  const WaterMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;

    return AnimatedBuilder(
      animation: themeService,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Water Monitor',
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              return snapshot.hasData ? const HomeScreen() : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
```

## lib/firebase_options.dart
```dart
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQMrGPf4EQLQQuMX9Gap0WIJXvKYe5U7E',
    appId: '1:847865678329:web:ec71d8fbac78b2a7685528',
    messagingSenderId: '847865678329',
    projectId: 'watermonitor-36e94',
    authDomain: 'watermonitor-36e94.firebaseapp.com',
    databaseURL: 'https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'watermonitor-36e94.firebasestorage.app',
    measurementId: 'G-XVWB7FTQQ4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEvVprbvSqEMrAiJFZX-C1wwjUR3VSUlc',
    appId: '1:847865678329:android:fa97c43e5ba9644a685528',
    messagingSenderId: '847865678329',
    projectId: 'watermonitor-36e94',
    databaseURL: 'https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'watermonitor-36e94.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABxENTLHR705WdkpAs-tHjJqrysYvNWWo',
    appId: '1:847865678329:ios:cc5ab6d2205ed4c5685528',
    messagingSenderId: '847865678329',
    projectId: 'watermonitor-36e94',
    databaseURL: 'https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'watermonitor-36e94.firebasestorage.app',
    iosBundleId: 'com.example.waterMonitor',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyABxENTLHR705WdkpAs-tHjJqrysYvNWWo',
    appId: '1:847865678329:ios:cc5ab6d2205ed4c5685528',
    messagingSenderId: '847865678329',
    projectId: 'watermonitor-36e94',
    databaseURL: 'https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'watermonitor-36e94.firebasestorage.app',
    iosBundleId: 'com.example.waterMonitor',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQMrGPf4EQLQQuMX9Gap0WIJXvKYe5U7E',
    appId: '1:847865678329:web:e322c11af3fbd10a685528',
    messagingSenderId: '847865678329',
    projectId: 'watermonitor-36e94',
    authDomain: 'watermonitor-36e94.firebaseapp.com',
    databaseURL: 'https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'watermonitor-36e94.firebasestorage.app',
    measurementId: 'G-GR40SB9P1B',
  );
}
```

## lib/models/water_data.dart
```dart
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
```

## lib/models/alert_data.dart
```dart
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
```

## lib/models/user_settings.dart
```dart
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
```

## lib/services/firebase_service.dart
```dart
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
```

## lib/services/context_service.dart
```dart
import '../models/water_data.dart';

class ContextService {
  static String getInsight(WaterData data) {
    if (data.leakDetected) {
      return 'ðŸš¨ Possible leak detected.';
    }

    final dateTime = _toDateTime(data.lastUpdated);
    final hour = dateTime.hour;

    if (hour >= 0 && hour <= 5 && data.flowRate > 1.0) {
      return 'ðŸŒ™ Unexpected water usage during sleeping hours.';
    }

    return 'âœ… System healthy and stable.';
  }

  static DateTime _toDateTime(int timestamp) {
    if (timestamp <= 0) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final milliseconds = timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}
```

## lib/services/context_engine.dart
```dart
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
```

## lib/services/notification_service.dart
```dart
import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import '../models/user_settings.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().handleBackgroundMessage(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('Local notification tapped from background: ${response.payload}');
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DatabaseReference _alertsRef = FirebaseDatabase.instance.ref('alerts');
  final DatabaseReference _settingsRef = FirebaseDatabase.instance.ref('settings');
  final DatabaseReference _deviceTokensRef =
      FirebaseDatabase.instance.ref('deviceTokens');

  StreamSubscription<DatabaseEvent>? _alertsSubscription;
  StreamSubscription<DatabaseEvent>? _settingsSubscription;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _notificationTapSubscription;
  bool _initialized = false;
  bool _permissionsRequested = false;
  bool _notificationsEnabled = true;
  bool _localNotificationsInitialized = false;
  String? _lastSyncedDeviceId;
  String? _lastSyncedToken;
  int _lastNotifiedTimestamp = 0;

  Future<void> initialize() async {
    if (_initialized) return;

    if (!kIsWeb) {
      await _ensureLocalNotificationsInitialized();
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _foregroundMessageSubscription ??=
          FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      _notificationTapSubscription ??=
          FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      _tokenRefreshSubscription ??=
          _messaging.onTokenRefresh.listen((_) => syncDeviceToken());
      _authSubscription ??=
          FirebaseAuth.instance.authStateChanges().listen((user) {
            if (user != null) {
              unawaited(syncDeviceToken());
            }
          });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    }

    _settingsSubscription ??= _settingsRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        _notificationsEnabled =
            UserSettings.fromMap(Map<dynamic, dynamic>.from(value))
                .notificationsEnabled;
      }
    });

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (_permissionsRequested) return;

    if (kIsWeb) {
      _permissionsRequested = true;
      return;
    }

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final macPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await macPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await syncDeviceToken();

    _permissionsRequested = true;
  }

  Future<void> syncDeviceToken() async {
    if (kIsWeb) return;

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        _lastSyncedDeviceId == user.uid &&
        _lastSyncedToken == token) {
      return;
    }

    debugPrint('FCM token: $token');

    if (user == null) {
      return;
    }

    await _saveDeviceToken(user.uid, token);
    _lastSyncedDeviceId = user.uid;
    _lastSyncedToken = token;
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    if (kIsWeb) return;
    if (!await _backgroundNotificationsEnabled()) return;
    await _showRemoteMessage(message);
  }

  Future<bool> _backgroundNotificationsEnabled() async {
    try {
      final snapshot = await _settingsRef.child('notificationsEnabled').get();
      final value = snapshot.value;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) return value.toLowerCase() == 'true';
    } catch (_) {
      return true;
    }

    return true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_notificationsEnabled) return;

    await _ensureLocalNotificationsInitialized();

    const androidDetails = AndroidNotificationDetails(
      'water_alerts',
      'Water Alerts',
      channelDescription: 'Context-aware water monitoring alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

    await _localNotifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> listenForNewAlerts() async {
    if (_alertsSubscription != null) return;

    final snapshot =
        await _alertsRef.orderByChild('timestamp').limitToLast(1).get();
    _lastNotifiedTimestamp = _extractLatestTimestamp(snapshot.value) ?? 0;

    _alertsSubscription = _alertsRef.onChildAdded.listen((event) async {
      final alert = _alertFromSnapshot(event.snapshot.value);
      if (alert == null) return;

      if (alert.timestamp > _lastNotifiedTimestamp) {
        _lastNotifiedTimestamp = alert.timestamp;
        await showNotification(
          title: alert.title,
          body: alert.message,
        );
      }
    });
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsInitialized || kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _localNotificationsInitialized = true;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kIsWeb) return;
    await _showRemoteMessage(message);
  }

  Future<void> _showRemoteMessage(RemoteMessage message) async {
    if (!_notificationsEnabled) return;

    await _ensureLocalNotificationsInitialized();

    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Water Monitor';
    final body =
        message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        'You have a new notification.';

    const androidDetails = AndroidNotificationDetails(
      'water_alerts',
      'Water Alerts',
      channelDescription: 'Context-aware water monitoring alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

    await _localNotifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint(
      'FCM notification tapped: '
      'messageId=${message.messageId ?? 'unknown'} data=${message.data}',
    );
  }

  void _handleLocalNotificationResponse(NotificationResponse response) {
    debugPrint(
      'Local notification tapped: payload=${response.payload ?? 'none'}',
    );
  }

  Future<void> _saveDeviceToken(String deviceId, String token) async {
    await _deviceTokensRef.child(deviceId).set({
      'token': token,
      'platform': _platformLabel,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  String get _platformLabel {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  int? _extractLatestTimestamp(dynamic value) {
    if (value is! Map) return null;

    int? latest;
    for (final raw in value.values) {
      if (raw is Map) {
        final timestamp = _asInt(raw['timestamp']);
        if (timestamp > 0 && (latest == null || timestamp > latest)) {
          latest = timestamp;
        }
      }
    }

    return latest;
  }

  _AlertPayload? _alertFromSnapshot(dynamic value) {
    if (value is! Map) return null;

    final map = Map<String, dynamic>.from(value);
    final timestamp = _asInt(map['timestamp']);
    final title = map['title']?.toString() ?? '';
    final message = map['message']?.toString() ?? '';

    if (timestamp <= 0 || title.isEmpty || message.isEmpty) {
      return null;
    }

    return _AlertPayload(
      title: title,
      message: message,
      timestamp: timestamp,
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _AlertPayload {
  const _AlertPayload({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  final String title;
  final String message;
  final int timestamp;
}
```

## lib/services/theme_service.dart
```dart
import 'package:flutter/material.dart';

enum ThemePreset {
  ocean,
  emerald,
  sunset,
  midnight,
}

class ThemeOption {
  const ThemeOption({
    required this.preset,
    required this.name,
    required this.subtitle,
    required this.seedColor,
    required this.accentColor,
  });

  final ThemePreset preset;
  final String name;
  final String subtitle;
  final Color seedColor;
  final Color accentColor;
}

class ThemeService extends ChangeNotifier {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  final List<ThemeOption> options = const [
    ThemeOption(
      preset: ThemePreset.ocean,
      name: 'Ocean Teal',
      subtitle: 'Cool blue-green clarity',
      seedColor: Color(0xFF0EA5E9),
      accentColor: Color(0xFF38BDF8),
    ),
    ThemeOption(
      preset: ThemePreset.emerald,
      name: 'Emerald Tide',
      subtitle: 'Fresh green energy',
      seedColor: Color(0xFF10B981),
      accentColor: Color(0xFF22C55E),
    ),
    ThemeOption(
      preset: ThemePreset.sunset,
      name: 'Sunset Coral',
      subtitle: 'Warm amber-coral glow',
      seedColor: Color(0xFFF97316),
      accentColor: Color(0xFFF59E0B),
    ),
    ThemeOption(
      preset: ThemePreset.midnight,
      name: 'Midnight Lagoon',
      subtitle: 'Deep indigo calm',
      seedColor: Color(0xFF6366F1),
      accentColor: Color(0xFFA78BFA),
    ),
  ];

  ThemePreset _selectedPreset = ThemePreset.ocean;

  ThemePreset get selectedPreset => _selectedPreset;

  ThemeOption get selectedOption =>
      options.firstWhere((option) => option.preset == _selectedPreset);

  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);
  ThemeMode get themeMode => ThemeMode.dark;

  void selectTheme(ThemePreset preset) {
    if (_selectedPreset == preset) return;
    _selectedPreset = preset;
    notifyListeners();
  }

  ThemeOption optionFor(ThemePreset preset) {
    return options.firstWhere((option) => option.preset == preset);
  }

  ThemeData _buildTheme(Brightness brightness) {
    final option = selectedOption;
    final scheme = ColorScheme.fromSeed(
      seedColor: option.seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? Colors.transparent : scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: brightness == Brightness.dark ? Colors.white : scheme.onSurface,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            brightness == Brightness.dark ? const Color(0xFF0A2F4D) : scheme.surface,
        contentTextStyle: TextStyle(
          color: brightness == Brightness.dark ? Colors.white : scheme.onSurface,
        ),
      ),
    );
  }
}
```

## lib/widgets/water_card.dart
```dart
import 'package:flutter/material.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.18),
            accent.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withOpacity(0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## lib/widgets/usage_chart.dart
```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/water_data.dart';

class UsageChart extends StatelessWidget {
  const UsageChart({
    super.key,
    required this.history,
  });

  final List<WaterData> history;

  @override
  Widget build(BuildContext context) {
    final reversed = history.reversed.toList();
    final points = reversed
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.flowRate,
            ))
        .toList();

    return AspectRatio(
      aspectRatio: 1.8,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: points.length < 2
            ? Center(
                child: Text(
                  'Not enough history yet to draw the chart.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
            : LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      barWidth: 3,
                      color: Theme.of(context).colorScheme.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(enabled: true),
                ),
              ),
      ),
    );
  }
}
```

## lib/screens/home_screen.dart
```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import 'alerts_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    AlertsScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04111D),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 86,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                  boxShadow: const [],
                ),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Dashboard',
                      selected: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'History',
                      selected: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    _NavItem(
                      icon: Icons.notifications_rounded,
                      label: 'Alerts',
                      selected: _currentIndex == 2,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                    _NavItem(
                      icon: Icons.analytics_rounded,
                      label: 'Reports',
                      selected: _currentIndex == 3,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      selected: _currentIndex == 4,
                      onTap: () => setState(() => _currentIndex = 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Colors.grey.shade500;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: selected
                    ? selectedColor.withOpacity(0.10)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? selectedColor.withOpacity(0.16)
                      : Colors.transparent,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: selectedColor.withOpacity(0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: selected ? 26 : 24,
                    color: selected ? selectedColor : unselectedColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? selectedColor : unselectedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## lib/screens/dashboard_screen.dart
```dart
import 'dart:async';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/water_data.dart';
import '../models/user_settings.dart';
import '../services/context_engine.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ContextEngine _contextEngine = ContextEngine();
  final DatabaseReference _waterRef = FirebaseDatabase.instance.ref('water');

  StreamSubscription<DatabaseEvent>? _subscription;
  StreamSubscription<UserSettings>? _settingsSubscription;

  double flowRate = 0;
  double totalUsage = 0;
  double dailyUsage = 0;
  bool leakDetected = false;
  UserSettings userSettings = UserSettings(
    householdSize: 1,
    monthlyTarget: 4000,
    sleepStart: 0,
    sleepEnd: 5,
  );
  int lastUpdated = 0;

  @override
  void initState() {
    super.initState();

    _subscription = _waterRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || !mounted) return;

      final water = WaterData.fromMap(Map<String, dynamic>.from(data as Map));

      setState(() {
        flowRate = water.flowRate;
        totalUsage = water.totalUsage;
        dailyUsage = water.dailyUsage;
        leakDetected = water.leakDetected;
        lastUpdated = water.lastUpdated;
      });
      _evaluateContext();
    });

    _settingsSubscription = _firebaseService.watchSettings().listen((settings) {
      if (!mounted) return;

      setState(() {
        userSettings = settings;
      });

      _evaluateContext();
    });
  }

  void _evaluateContext() {
    unawaited(
      _contextEngine
          .evaluateContext(
            water: WaterData(
              flowRate: flowRate,
              totalUsage: totalUsage,
              dailyUsage: dailyUsage,
              leakDetected: leakDetected,
              lastUpdated: lastUpdated,
            ),
            settings: userSettings,
          )
          .catchError((_) {}),
    );
  }

  double get monthlyProgress {
    if (monthlyTarget <= 0) return 0;

    return (totalUsage / monthlyTarget).clamp(0.0, 1.0);
  }

  double get monthlyTarget => userSettings.monthlyTarget;

  String _getInsight(WaterData data) {
    if (data.leakDetected) {
      return '🚨 Possible leak detected.';
    }

    final dateTime = _toDateTime(data.lastUpdated);
    if (ContextEngine.isWithinSleepHours(
          dateTime.hour,
          userSettings.sleepStart,
          userSettings.sleepEnd,
        ) &&
        data.flowRate > 1.0) {
      return '🌙 Unexpected water usage during sleeping hours.';
    }

    if (data.totalUsage > monthlyTarget) {
      return '⚠️ Monthly water target exceeded.';
    }

    return '✅ System healthy and stable.';
  }

  DateTime _toDateTime(int timestamp) {
    if (timestamp <= 0) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final milliseconds = timestamp < 1000000000000
        ? timestamp * 1000
        : timestamp;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _settingsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final flowProgress = (flowRate / 20).clamp(0.0, 1.0);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 120;
    final currentData = WaterData(
      flowRate: flowRate,
      totalUsage: totalUsage,
      dailyUsage: dailyUsage,
      leakDetected: leakDetected,
      lastUpdated: lastUpdated,
    );
    final insight = _getInsight(currentData);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Water Monitor',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      body: Stack(
        children: [
          const _WaterBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroGlassCard(
                    flowRate: flowRate,
                    flowProgress: flowProgress,
                    leakDetected: leakDetected,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassMetricCard(
                          title: 'Total Usage',
                          value: '${totalUsage.toStringAsFixed(1)} L',
                          subtitle: 'All-time consumption',
                          icon: Icons.opacity_rounded,
                          accent: const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassMetricCard(
                          title: 'Daily Usage',
                          value: '${dailyUsage.toStringAsFixed(1)} L',
                          subtitle: 'Today so far',
                          icon: Icons.today_rounded,
                          accent: const Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MonthlyGoalCard(
                    currentUsage: totalUsage,
                    monthlyTarget: monthlyTarget,
                    progress: monthlyProgress,
                  ),
                  const SizedBox(height: 12),
                  _GlassMetricCard(
                    title: 'Leak Status',
                    value: leakDetected ? 'Leak Detected' : 'System Normal',
                    subtitle: leakDetected
                        ? 'Please check your lines and valves immediately.'
                        : 'No leak indicators are active right now.',
                    icon: leakDetected
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_rounded,
                    accent: leakDetected
                        ? const Color(0xFFF97316)
                        : const Color(0xFF06B6D4),
                    wide: true,
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Water Pulse',
                    subtitle: 'A quick view of the current system rhythm',
                    accent: scheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _PulseGraph(
                    flowRate: flowRate,
                    accent: leakDetected
                        ? const Color(0xFFF97316)
                        : const Color(0xFF38BDF8),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Live Notes',
                    subtitle: 'Context around the latest sensor reading',
                    accent: scheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _GlassInfoTile(
                    icon: Icons.water_drop_rounded,
                    title: 'Flow rate',
                    value: '${flowRate.toStringAsFixed(2)} L/min',
                    trailing: 'Live',
                  ),
                  const SizedBox(height: 10),
                  _GlassInfoTile(
                    icon: Icons.bubble_chart_rounded,
                    title: 'System state',
                    value: insight,
                    trailing: leakDetected ? 'Alert' : 'Normal',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterBackdrop extends StatelessWidget {
  const _WaterBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF061C2E),
              const Color(0xFF0A3D62),
              const Color(0xFF0E7490).withOpacity(0.88),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const _GlowCircle(
              alignment: Alignment.topRight,
              size: 240,
              color: Color(0xFF38BDF8),
            ),
            const _GlowCircle(
              alignment: Alignment.bottomLeft,
              size: 220,
              color: Color(0xFF22C55E),
            ),
            Positioned(
              left: -90,
              top: 120,
              child: _WaveBlob(
                size: 220,
                color: const Color(0xFF7DD3FC).withOpacity(0.18),
              ),
            ),
            Positioned(
              right: -50,
              bottom: 140,
              child: _WaveBlob(
                size: 180,
                color: const Color(0xFF06B6D4).withOpacity(0.16),
              ),
            ),
            const _WaterRidge(),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.35), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _WaterRidge extends StatelessWidget {
  const _WaterRidge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0E7490).withOpacity(0.18),
              const Color(0xFF0A3D62).withOpacity(0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _HeroGlassCard extends StatelessWidget {
  const _HeroGlassCard({
    required this.flowRate,
    required this.flowProgress,
    required this.leakDetected,
  });

  final double flowRate;
  final double flowProgress;
  final bool leakDetected;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration radar',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withOpacity(0.72),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${flowRate.toStringAsFixed(2)} L/min',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _FlowDial(
                progress: flowProgress,
                accent: leakDetected
                    ? const Color(0xFFF97316)
                    : const Color(0xFF38BDF8),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatusChip(
                icon: leakDetected
                    ? Icons.warning_amber_rounded
                    : Icons.water_drop_rounded,
                label: leakDetected ? 'Leak active' : 'Flow stable',
                color: leakDetected
                    ? const Color(0xFFF97316)
                    : const Color(0xFF22C55E),
              ),
              const SizedBox(width: 10),
              _StatusChip(
                icon: Icons.timelapse_rounded,
                label: 'Realtime',
                color: const Color(0xFF38BDF8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowDial extends StatelessWidget {
  const _FlowDial({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(value * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'flow',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent,
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassMetricCard extends StatelessWidget {
  const _GlassMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.wide = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: wide ? double.infinity : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accent.withOpacity(0.5), accent.withOpacity(0.12)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.68),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyGoalCard extends StatelessWidget {
  const _MonthlyGoalCard({
    required this.currentUsage,
    required this.monthlyTarget,
    required this.progress,
  });

  final double currentUsage;
  final double monthlyTarget;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).round();

    return _GlassShell(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Goal',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${currentUsage.toStringAsFixed(0)} L / ${monthlyTarget.toStringAsFixed(0)} L',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progressPercent%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.78),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF38BDF8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassInfoTile extends StatelessWidget {
  const _GlassInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String value;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withOpacity(0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withOpacity(0.82),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PulseGraph extends StatelessWidget {
  const _PulseGraph({required this.flowRate, required this.accent});

  final double flowRate;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bars = List<double>.generate(10, (index) {
      final base = 0.25 + ((index % 3) * 0.12);
      final flowImpact = (flowRate / 20).clamp(0.0, 1.0) * 0.55;
      return (base + flowImpact).clamp(0.18, 1.0);
    });

    return _GlassShell(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current pulse',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Live',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (index) {
                final heightFactor = bars[index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 420 + (index * 40)),
                      curve: Curves.easeOutCubic,
                      height: 110 * heightFactor,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: LinearGradient(
                          colors: [
                            accent.withOpacity(0.95),
                            accent.withOpacity(0.25),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
```

## lib/screens/history_screen.dart
```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/water_data.dart';
import '../services/firebase_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const _HistoryBackdrop(),
          SafeArea(
            child: StreamBuilder<List<WaterData>>(
              stream: FirebaseService().watchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load history',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  );
                }

                final history = snapshot.data ?? <WaterData>[];

                if (history.isEmpty) {
                  return Center(
                    child: _GlassShell(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No history data available',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  );
                }

                final newestFirst = history.reversed.toList();

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _HistoryHero(totalEntries: history.length),
                    const SizedBox(height: 16),
                    ...newestFirst.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(item: item),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryBackdrop extends StatelessWidget {
  const _HistoryBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.80),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _GlowBlob(
                size: 220,
                color: const Color(0xFF38BDF8).withOpacity(0.20),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: _GlowBlob(
                size: 200,
                color: const Color(0xFF22C55E).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -30,
              child: _WaveBlob(
                size: 180,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _HistoryHero extends StatelessWidget {
  const _HistoryHero({required this.totalEntries});

  final int totalEntries;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flow history timeline',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.72),
                    letterSpacing: 1.0,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              '$totalEntries saved readings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Track your latest water sensor readings from Firebase Realtime Database.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.76),
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final WaterData item;

  @override
  Widget build(BuildContext context) {
    final isAlert = item.leakDetected || item.flowRate > 15;
    final accent = isAlert ? const Color(0xFFF97316) : const Color(0xFF38BDF8);

    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accent.withOpacity(0.55), accent.withOpacity(0.12)],
                ),
              ),
              child: Icon(
                isAlert
                    ? Icons.warning_amber_rounded
                    : Icons.water_drop_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatTimestamp(item.lastUpdated),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      _Pill(
                        text: isAlert ? 'Leak' : 'Normal',
                        color: accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Daily usage: ${item.dailyUsage.toStringAsFixed(1)} L',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.78),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Flow rate: ${item.flowRate.toStringAsFixed(2)} L/min',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.78),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leak status: ${item.leakDetected ? 'Detected' : 'Normal'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.64),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

String _formatTimestamp(int timestamp) {
  if (timestamp <= 0) {
    return 'Unknown date';
  }

  final milliseconds = timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
  final dateTime = DateTime.fromMillisecondsSinceEpoch(
    milliseconds,
    isUtc: false,
  );

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return '${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}/${dateTime.year} '
      '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

## lib/screens/alerts_screen.dart
```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/alert_data.dart';
import '../services/firebase_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Alerts',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const _AlertsBackdrop(),
          SafeArea(
            child: StreamBuilder<List<AlertData>>(
              stream: FirebaseService().watchAlerts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: _GlassShell(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No alerts available',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ),
                  );
                }

                final alerts = snapshot.data ?? <AlertData>[];

                if (alerts.isEmpty) {
                  return Center(
                    child: _GlassShell(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.10),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No alerts available',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _AlertsHero(totalAlerts: alerts.length),
                    const SizedBox(height: 16),
                    ...alerts.map((alert) {
                      final severityColor = _severityColor(alert.severity);
                      final severityIcon = _severityIcon(alert.severity);
                      final timeLabel = _formatAlertTime(alert.timestamp);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AlertCard(
                          alert: alert,
                          severityColor: severityColor,
                          severityIcon: severityIcon,
                          timeLabel: timeLabel,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'info':
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
      default:
        return Colors.green;
    }
  }

  String _formatAlertTime(int timestamp) {
    if (timestamp <= 0) {
      return 'Today';
    }

    final milliseconds =
        timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (_isSameCalendarDate(dateTime, now)) {
      if (difference.inHours >= 1) {
        if (difference.inHours == 1) {
          return '1 hour ago';
        }
        return timeago.format(dateTime).replaceFirst('an hour ago', '1 hour ago');
      }

      if (difference.inMinutes >= 1) {
        return '${difference.inMinutes} min ago';
      }

      return 'Today';
    }

    if (_isYesterday(dateTime, now)) {
      return 'Yesterday';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  bool _isSameCalendarDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isYesterday(DateTime dateTime, DateTime now) {
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }
}

class _AlertsBackdrop extends StatelessWidget {
  const _AlertsBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.82),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _GlowBlob(
                size: 240,
                color: const Color(0xFF38BDF8).withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -70,
              child: _GlowBlob(
                size: 210,
                color: const Color(0xFF22C55E).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -40,
              child: _WaveBlob(
                size: 180,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsHero extends StatelessWidget {
  const _AlertsHero({required this.totalAlerts});

  final int totalAlerts;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alert center',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.72),
                    letterSpacing: 1.0,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              '$totalAlerts live alerts',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.severityColor,
    required this.severityIcon,
    required this.timeLabel,
  });

  final AlertData alert;
  final Color severityColor;
  final IconData severityIcon;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    severityColor.withOpacity(0.55),
                    severityColor.withOpacity(0.12),
                  ],
                ),
              ),
              child: Icon(severityIcon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight:
                                    alert.read ? FontWeight.w600 : FontWeight.w800,
                              ),
                        ),
                      ),
                      _Pill(
                        text: alert.severity.toUpperCase(),
                        color: severityColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.78),
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        timeLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.64),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

## lib/screens/reports_screen.dart
```dart
import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/water_data.dart';
import '../models/user_settings.dart';
import '../services/firebase_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      body: Stack(
        children: [
          const _ReportsBackdrop(),
          SafeArea(
            child: StreamBuilder<UserSettings>(
              stream: FirebaseService().watchSettings(),
              builder: (context, settingsSnapshot) {
                final userSettings = settingsSnapshot.data ?? UserSettings();
                return StreamBuilder<List<WaterData>>(
                  stream: FirebaseService().watchHistory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load reports',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      );
                    }

                    final history = snapshot.data ?? <WaterData>[];

                    if (history.isEmpty) {
                      return Center(
                        child: _GlassShell(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No history data available yet.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }

                    final values =
                        history.map((item) => item.dailyUsage).toList();
                    final averageDailyUsage = _average(values);
                    final weeklyAverageUsage = _average(
                      values.length > 7
                          ? values.sublist(values.length - 7)
                          : values,
                    );
                    final monthlyAverageUsage = _average(
                      values.length > 30
                          ? values.sublist(values.length - 30)
                          : values,
                    );
                    final maxDailyUsage = values.reduce(math.max);
                    final minDailyUsage = values.reduce(math.min);
                    final latestDailyUsage = history.last.dailyUsage;
                    final householdSize = math.max(1, userSettings.householdSize);
                    final perPersonDailyUsage =
                        latestDailyUsage / householdSize;

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        _ReportsHero(totalEntries: history.length),
                        const SizedBox(height: 16),
                        _TrendChartCard(history: history),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cardWidth = constraints.maxWidth > 420
                                ? (constraints.maxWidth - 12) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Average daily usage',
                                    value:
                                        '${averageDailyUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Across all available records',
                                    accent: const Color(0xFF38BDF8),
                                    icon: Icons.timeline_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Average weekly usage',
                                    value:
                                        '${weeklyAverageUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Latest 7 readings',
                                    accent: const Color(0xFF22C55E),
                                    icon: Icons.date_range_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Monthly average',
                                    value:
                                        '${monthlyAverageUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Latest 30 readings',
                                    accent: const Color(0xFF06B6D4),
                                    icon: Icons.calendar_month_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Per-person daily usage',
                                    value:
                                        '${perPersonDailyUsage.toStringAsFixed(1)} L',
                                    subtitle:
                                        'Based on ${userSettings.householdSize} people',
                                    accent: const Color(0xFF7DD3FC),
                                    icon: Icons.groups_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Highest daily usage',
                                    value:
                                        '${maxDailyUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Peak recorded day',
                                    accent: const Color(0xFFF97316),
                                    icon: Icons.trending_up_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Lowest daily usage',
                                    value:
                                        '${minDailyUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Most efficient day',
                                    accent: const Color(0xFFA78BFA),
                                    icon: Icons.trending_down_rounded,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsBackdrop extends StatelessWidget {
  const _ReportsBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.82),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _GlowBlob(
                size: 220,
                color: const Color(0xFF38BDF8).withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: 110,
              left: -70,
              child: _GlowBlob(
                size: 200,
                color: const Color(0xFF22C55E).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: _WaveBlob(
                size: 180,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ReportsHero extends StatelessWidget {
  const _ReportsHero({required this.totalEntries});

  final int totalEntries;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historical usage overview',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.72),
                    letterSpacing: 1.0,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              '$totalEntries saved readings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Review daily trends, compare averages, and spot unusually high water usage patterns.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.76),
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({required this.history});

  final List<WaterData> history;

  @override
  Widget build(BuildContext context) {
    final spots = history.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.dailyUsage,
      );
    }).toList();

    final values = history.map((item) => item.dailyUsage).toList();
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final rangePadding = math.max(1.0, (maxValue - minValue) * 0.2);
    final minY = math.max(0.0, minValue - rangePadding);
    final maxY = maxValue + rangePadding;
    final yInterval = _safeInterval(maxY - minY, 4);
    final xInterval = history.length > 6 ? math.max(1, history.length ~/ 4).toDouble() : 1.0;

    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily water usage trend',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oldest readings on the left and newest readings on the right.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.72),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: Text(
                    'Daily usage',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.08),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: yInterval,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withOpacity(0.68),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: xInterval,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= history.length) {
                            return const SizedBox.shrink();
                          }

                          final shouldShowLabel = history.length <= 6 ||
                              index == 0 ||
                              index == history.length - 1 ||
                              index % xInterval.round() == 0;

                          if (!shouldShowLabel) {
                            return const SizedBox.shrink();
                          }

                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _formatShortDate(history[index].lastUpdated),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withOpacity(0.68),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(enabled: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      barWidth: 3,
                      color: const Color(0xFF38BDF8),
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF38BDF8).withOpacity(0.14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accent.withOpacity(0.5), accent.withOpacity(0.12)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withOpacity(0.72),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.68),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

double _average(List<double> values) {
  if (values.isEmpty) return 0.0;
  return values.reduce((a, b) => a + b) / values.length;
}

double _safeInterval(double range, int segments) {
  if (range <= 0) return 1.0;
  return math.max(0.5, range / segments);
}

String _formatShortDate(int timestamp) {
  if (timestamp <= 0) {
    return '--/--';
  }

  final milliseconds = timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
  final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}';
}
```

## lib/screens/profile_screen.dart
```dart
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/firebase_service.dart';
import '../services/theme_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _showEditProfileDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No signed-in user found')),
      );
      return;
    }

    final nameController = TextEditingController(text: user.displayName ?? '');

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0B2238),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Edit profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dialogDecoration(
                      label: 'Display name',
                      hint: 'Enter your name',
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (result != true) return;

      await user.updateDisplayName(nameController.text.trim());
      await user.reload();

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to update profile')),
      );
    } finally {
      nameController.dispose();
    }
  }
  InputDecoration _dialogDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.72)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.42)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Color(0xFF38BDF8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const _ProfileBackdrop(),
          SafeArea(
            child: StreamBuilder<UserSettings>(
              stream: service.watchSettings(),
              builder: (context, snapshot) {
                final settings = snapshot.data ?? UserSettings();

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _ProfileHero(user: user),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      title: 'Notifications',
                      subtitle: 'Control background alerts on this phone',
                    ),
                    const SizedBox(height: 12),
                    _GlassShell(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.09),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.14),
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Background notifications',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Turn on to show alerts on the phone background. Turn off to silence them.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.72),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: settings.notificationsEnabled,
                              activeColor: const Color(0xFF38BDF8),
                              onChanged: (value) async {
                                await service.updateSettings(
                                  UserSettings(
                                    householdSize: settings.householdSize,
                                    monthlyTarget: settings.monthlyTarget,
                                    sleepStart: settings.sleepStart,
                                    sleepEnd: settings.sleepEnd,
                                    notificationsEnabled: value,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      title: 'Account',
                      subtitle: 'Personal details and access',
                    ),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit profile',
                      subtitle: 'Name, email, and photo',
                      onTap: _showEditProfileDialog,
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      title: 'Settings',
                      subtitle: 'Household, target, and sleep schedule',
                    ),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: Icons.settings_outlined,
                      title: 'App settings',
                      subtitle: 'Open household, target, and sleep controls',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      title: 'Preferences',
                      subtitle: 'Customize your experience',
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      subtitle:
                          'Current: ${ThemeService.instance.selectedOption.name}',
                      onTap: () => _showThemePicker(context),
                    ),
                    const SizedBox(height: 16),
                    _GlassButton(
                      icon: Icons.logout_rounded,
                      label: 'Sign out',
                      accent: const Color(0xFFF97316),
                      onTap: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showThemePicker(BuildContext context) async {
  final themeService = ThemeService.instance;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _GlassShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose theme',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a color palette that fits your style.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.72),
                    ),
              ),
              const SizedBox(height: 16),
              ...themeService.options.map((option) {
                final isSelected = option.preset == themeService.selectedPreset;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        themeService.selectTheme(option.preset);
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${option.name} applied'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: isSelected
                              ? option.accentColor.withOpacity(0.18)
                              : Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: isSelected
                                ? option.accentColor.withOpacity(0.55)
                                : Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    option.seedColor,
                                    option.accentColor,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.subtitle,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.72),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.82),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _GlowBlob(
                size: 240,
                color: const Color(0xFF38BDF8).withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -70,
              child: _GlowBlob(
                size: 210,
                color: const Color(0xFF22C55E).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -40,
              child: _WaveBlob(
                size: 180,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.trim();
    final fallbackLabel = user?.email ?? 'Water Monitor User';
    final photoUrl = user?.photoURL;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7DD3FC),
                    Color(0xFF38BDF8),
                    Color(0xFF0EA5E9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipOval(
                child: hasPhoto
                    ? Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName?.isNotEmpty == true ? displayName! : fallbackLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if ((user?.email ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                user!.email!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.74),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.09),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: accent.withOpacity(0.16),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

## lib/screens/settings_screen.dart
```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _monthlyTargetController =
      TextEditingController();

  static const List<int> _sleepHourOptions = <int>[22, 23, 0, 1, 2, 3, 4, 5, 6];

  bool _initialized = false;
  int _householdSize = 1;
  int _sleepStart = 22;
  int _sleepEnd = 5;

  @override
  void dispose() {
    _monthlyTargetController.dispose();
    super.dispose();
  }

  void _syncControllers(UserSettings settings) {
    if (_initialized) return;

    _householdSize = settings.householdSize;
    _monthlyTargetController.text = settings.monthlyTarget.toStringAsFixed(0);
    _sleepStart = _normalizeSleepHour(settings.sleepStart);
    _sleepEnd = _normalizeSleepHour(settings.sleepEnd);
    _initialized = true;
  }

  int _normalizeSleepHour(int value) {
    if (_sleepHourOptions.contains(value)) {
      return value;
    }

    final normalized = value % 24;
    if (_sleepHourOptions.contains(normalized)) {
      return normalized;
    }

    return _sleepHourOptions.first;
  }

  String formatHour(int hour) {
    final normalizedHour = hour % 24;
    final period = normalizedHour < 12 ? 'AM' : 'PM';
    final displayHour = normalizedHour % 12 == 0 ? 12 : normalizedHour % 12;
    return '$displayHour:00 $period';
  }

  List<DropdownMenuItem<int>> _hourItems() {
    return _sleepHourOptions
        .map(
          (hour) => DropdownMenuItem<int>(
            value: hour,
            child: Text(formatHour(hour)),
          ),
        )
        .toList();
  }

  Future<void> _saveSettings(UserSettings current) async {
    if (!_formKey.currentState!.validate()) return;

    final updated = UserSettings(
      householdSize: _householdSize,
      monthlyTarget:
          double.tryParse(_monthlyTargetController.text.trim()) ??
          current.monthlyTarget,
      sleepStart: _sleepStart,
      sleepEnd: _sleepEnd,
      notificationsEnabled: current.notificationsEnabled,
    );

    await _firebaseService.updateSettings(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const _SettingsBackdrop(),
          SafeArea(
            child: StreamBuilder<UserSettings>(
              stream: _firebaseService.watchSettings(),
              builder: (context, snapshot) {
                final settings = snapshot.data ?? UserSettings();
                _syncControllers(settings);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GlassShell(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                DropdownButtonFormField<int>(
                                  value: _householdSize,
                                  dropdownColor: const Color(0xFF0A2F4D),
                                  decoration: _fieldDecoration(
                                    context,
                                    'Household size',
                                  ),
                                  items: List.generate(10, (index) {
                                    final value = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        '$value',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _householdSize = value);
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _monthlyTargetController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _fieldDecoration(
                                    context,
                                    'Monthly target (L)',
                                  ),
                                  validator: (value) {
                                    final parsed = double.tryParse(
                                      value?.trim() ?? '',
                                    );
                                    if (parsed == null || parsed <= 0) {
                                      return 'Enter a valid monthly target';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildSleepSchedule(context),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _GlassButton(
                          icon: Icons.save_rounded,
                          label: 'Save Settings',
                          accent: const Color(0xFF38BDF8),
                          onTap: () => _saveSettings(settings),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepSchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep Schedule',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: _sleepStart,
          isExpanded: true,
          dropdownColor: const Color(0xFF0A2F4D),
          decoration: _fieldDecoration(context, 'Sleep starts'),
          items: _hourItems(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _sleepStart = value);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _sleepEnd,
          isExpanded: true,
          dropdownColor: const Color(0xFF0A2F4D),
          decoration: _fieldDecoration(context, 'Wake up'),
          items: _hourItems(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _sleepEnd = value);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Water usage detected during this period will trigger Night-time Usage alerts.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.72)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Color(0xFF38BDF8)),
      ),
    );
  }
}

class _SettingsBackdrop extends StatelessWidget {
  const _SettingsBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.82),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: accent.withOpacity(0.16),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

## lib/screens/login_screen.dart
```dart
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'waterdemo');
  final _passwordController = TextEditingController(text: 'Water@1234');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _emailFromUsername(String username) {
    final normalized = username
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '.')
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '');

    return '$normalized@watermonitor.app';
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailFromUsername(_usernameController.text),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to sign in')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const _AuthBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlassShell(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7DD3FC),
                                      Color(0xFF38BDF8),
                                      Color(0xFF0EA5E9),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color(0xFF38BDF8).withOpacity(0.3),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.water_drop_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Water Monitor',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to track live flow, alerts, reports, and user preferences.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.74),
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GlassShell(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration(
                                  context,
                                  'Username',
                                  'Use your app username',
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'Enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration(
                                  context,
                                  'Password',
                                  'Enter your password',
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF38BDF8).withOpacity(0.18),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      side: BorderSide(
                                        color:
                                            const Color(0xFF38BDF8).withOpacity(0.28),
                                      ),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Need an account? Sign up',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.88),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Demo credentials: waterdemo / Water@1234',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.68),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context,
    String label,
    String hint, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.72)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.42)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Color(0xFF38BDF8)),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.82),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _GlowBlob(
                size: 220,
                color: const Color(0xFF38BDF8).withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: 110,
              left: -70,
              child: _GlowBlob(
                size: 200,
                color: const Color(0xFF22C55E).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: _WaveBlob(
                size: 180,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

## lib/screens/signup_screen.dart
```dart
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'waterdemo');
  final _passwordController = TextEditingController(text: 'Water@1234');
  final _confirmController = TextEditingController(text: 'Water@1234');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _emailFromUsername(String username) {
    final normalized = username
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '.')
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '');

    return '$normalized@watermonitor.app';
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final email = _emailFromUsername(_usernameController.text);
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: _passwordController.text.trim(),
          );

      await credential.user?.updateDisplayName(_usernameController.text.trim());
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to create account')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Sign Up',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const _AuthBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _GlassShell(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Create account',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Set up your username and password to start using the water monitor.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.74),
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GlassShell(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration(
                                  context,
                                  'Username',
                                  'Choose a username',
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'Enter a username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration(
                                  context,
                                  'Password',
                                  'Create a password',
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _obscure,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration(
                                  context,
                                  'Confirm password',
                                  'Re-enter your password',
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF22C55E).withOpacity(0.18),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      side: BorderSide(
                                        color:
                                            const Color(0xFF22C55E).withOpacity(0.28),
                                      ),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context,
    String label,
    String hint, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.72)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.42)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Color(0xFF38BDF8)),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.82),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

## test/widget_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {}
```

## context_engine_python/README.md
```markdown
# context_engine_python

## Purpose

`context_engine_python` is the future Python-based context intelligence engine
for an AI-driven context-aware smart water monitoring system.

This project is intentionally scaffolded only. It does not yet connect to
Firebase, perform statistical analysis, detect anomalies, or send alerts.

## Planned Responsibilities

- Read Firebase Realtime Database data
- Read water sensor history
- Perform statistical anomaly detection
- Generate alerts
- Send Firebase Cloud Messaging notifications

## Folder Structure

```text
context_engine_python/
â”œâ”€â”€ app.py
â”œâ”€â”€ firebase_service.py
â”œâ”€â”€ statistics_engine.py
â”œâ”€â”€ anomaly_detector.py
â”œâ”€â”€ notification_service.py
â”œâ”€â”€ config.py
â”œâ”€â”€ requirements.txt
â”œâ”€â”€ README.md
â”œâ”€â”€ .gitignore
â””â”€â”€ serviceAccountKey.json.example
```

## Future Roadmap

1. Add Firebase connectivity and configuration loading
2. Implement statistics utilities for sensor data analysis
3. Add anomaly detection workflows
4. Generate alerts from detected context patterns
5. Integrate notification delivery
6. Add testing, logging, and operational hardening
```

## context_engine_python/config.py
```python
"""Configuration constants for the context engine project."""

DATABASE_URL = "https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app"
SERVICE_ACCOUNT_FILE = "serviceAccountKey.json"
MONITOR_INTERVAL_SECONDS = 10
BASELINE_MIN_SAMPLES = 10
BASELINE_RETRAIN_INTERVAL_SECONDS = 30 * 60
BASELINE_RETRAIN_HISTORY_RECORDS = 500
HISTORY_WINDOW_SIZE = 1000
LEAK_HYSTERESIS_LPM = 1.0
```

## context_engine_python/firebase_service.py
```python
"""Firebase connectivity for the context engine."""

from __future__ import annotations

from typing import Any

import firebase_admin
from firebase_admin import credentials, db

from config import DATABASE_URL, SERVICE_ACCOUNT_FILE


class FirebaseService:
    """Read-only Firebase service for the context engine."""

    def __init__(self) -> None:
        self._app: firebase_admin.App | None = None
        self._owns_app = False

    def connect(self) -> None:
        """Initialize Firebase Admin SDK once."""
        if self._app is not None:
            return

        if not firebase_admin._apps:
            cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
            self._app = firebase_admin.initialize_app(
                cred,
                {"databaseURL": DATABASE_URL},
            )
            self._owns_app = True
            return

        self._app = firebase_admin.get_app()
        self._owns_app = False

    def get_water_data(self) -> dict[str, Any]:
        """Return the current `/water` node as a dictionary."""
        self.connect()
        snapshot = db.reference("water").get() or {}
        return snapshot if isinstance(snapshot, dict) else {}

    def get_history(self) -> Any:
        """Return the `/history` node."""
        self.connect()
        return db.reference("history").get()

    def get_history_record_count(self) -> int:
        """Return the number of history records currently stored in Firebase."""
        history = self.get_history()
        if isinstance(history, dict):
            return len(history)
        if isinstance(history, list):
            return len(history)
        return 0

    def get_settings(self) -> dict[str, Any]:
        """Return the current `/settings` node as a dictionary."""
        self.connect()
        snapshot = db.reference("settings").get() or {}
        return snapshot if isinstance(snapshot, dict) else {}

    def get_context_engine_state(self) -> dict[str, Any]:
        """Return the persisted Context Engine state from Firebase settings."""
        self.connect()
        snapshot = db.reference("settings/contextEngine").get() or {}
        return snapshot if isinstance(snapshot, dict) else {}

    def save_context_engine_state(self, state: dict[str, Any]) -> None:
        """Persist Context Engine state without disturbing the rest of settings."""
        self.connect()
        db.reference("settings/contextEngine").update(state)

    def close(self) -> None:
        """Tear down the Firebase app if it was initialized here."""
        if self._app is not None and self._owns_app:
            firebase_admin.delete_app(self._app)

        self._app = None
        self._owns_app = False
```

## context_engine_python/statistics_engine.py
```python
"""Statistical processing for the context engine."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any

import numpy as np

from config import BASELINE_MIN_SAMPLES, HISTORY_WINDOW_SIZE


@dataclass(slots=True)
class StatisticalBaseline:
    """Persisted statistical model learned from normal history."""

    sample_count: int
    mean: float
    median: float
    std: float
    threshold: float
    minimum: float
    maximum: float
    history_record_count: int
    learned_at: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "sampleCount": self.sample_count,
            "mean": self.mean,
            "median": self.median,
            "std": self.std,
            "threshold": self.threshold,
            "minimum": self.minimum,
            "maximum": self.maximum,
            "historyRecordCount": self.history_record_count,
            "learnedAt": self.learned_at,
        }

    @classmethod
    def from_dict(cls, payload: Any) -> StatisticalBaseline | None:
        if not isinstance(payload, dict):
            return None

        try:
            return cls(
                sample_count=int(payload.get("sampleCount", 0)),
                mean=float(payload.get("mean")),
                median=float(payload.get("median")),
                std=float(payload.get("std")),
                threshold=float(payload.get("threshold")),
                minimum=float(payload.get("minimum")),
                maximum=float(payload.get("maximum")),
                history_record_count=int(payload.get("historyRecordCount", 0)),
                learned_at=str(payload.get("learnedAt") or ""),
            )
        except (TypeError, ValueError):
            return None


class StatisticsEngine:
    """Compute a stable statistical baseline from historical water flow."""

    def __init__(self) -> None:
        self._last_history_records: list[Any] = []
        self._last_recent_records: list[Any] = []
        self._last_included_records: list[Any] = []
        self._last_excluded_leak_records: list[Any] = []
        self._last_summary: dict[str, int] = {
            "totalHistoryRecords": 0,
            "includedNormalSamples": 0,
            "excludedLeakSamples": 0,
        }

    def learn_baseline(self, history: Any) -> StatisticalBaseline | None:
        """Build a statistical baseline from recent normal history records only."""
        flow_rates = self.get_flow_rates(history)
        if len(flow_rates) < BASELINE_MIN_SAMPLES:
            return None

        values = np.asarray(flow_rates, dtype=float)
        mean = float(np.mean(values))
        median = float(np.median(values))
        std = float(np.std(values, ddof=0))
        minimum = float(np.min(values))
        maximum = float(np.max(values))
        threshold = mean + (2.0 * std)
        learned_at = datetime.now(timezone.utc).isoformat(timespec="seconds")

        return StatisticalBaseline(
            sample_count=int(values.size),
            mean=mean,
            median=median,
            std=std,
            threshold=threshold,
            minimum=minimum,
            maximum=maximum,
            history_record_count=len(self._last_history_records),
            learned_at=learned_at,
        )

    def get_flow_rates(self, history: Any) -> list[float]:
        """Extract valid recent flow-rate values from normal history records."""
        raw_records = self._iter_records(history)
        self._last_history_records = list(raw_records)

        recent_records = self._get_recent_records(raw_records)
        self._last_recent_records = list(recent_records)

        flow_rates: list[float] = []
        included_records: list[Any] = []
        excluded_leak_records: list[Any] = []

        for record in recent_records:
            if self._is_leak_record(record):
                excluded_leak_records.append(record)
                continue

            value = self._extract_flow_rate(record)
            if value is None:
                continue

            included_records.append(record)
            flow_rates.append(value)

        self._last_included_records = included_records
        self._last_excluded_leak_records = excluded_leak_records
        self._last_summary = {
            "totalHistoryRecords": len(raw_records),
            "includedNormalSamples": len(flow_rates),
            "excludedLeakSamples": len(excluded_leak_records),
        }

        return flow_rates

    def calculate_mean(self, flow_rates: list[float]) -> float:
        """Calculate the mean flow rate."""
        if not flow_rates:
            return 0.0
        return float(np.mean(np.asarray(flow_rates, dtype=float)))

    def calculate_standard_deviation(self, flow_rates: list[float]) -> float:
        """Calculate the population standard deviation of flow rates."""
        if not flow_rates:
            return 0.0
        return float(np.std(np.asarray(flow_rates, dtype=float), ddof=0))

    def calculate_dynamic_threshold(self, flow_rates: list[float]) -> dict[str, float | int] | None:
        """Calculate summary statistics and a dynamic leak threshold."""
        if len(flow_rates) < BASELINE_MIN_SAMPLES:
            return None

        values = np.asarray(flow_rates, dtype=float)
        mean = float(np.mean(values))
        median = float(np.median(values))
        std = float(np.std(values, ddof=0))
        minimum = float(np.min(values))
        maximum = float(np.max(values))
        threshold = mean + (2.0 * std)

        return {
            "sampleCount": int(values.size),
            "mean": mean,
            "median": median,
            "std": std,
            "minimum": minimum,
            "maximum": maximum,
            "threshold": threshold,
        }

    def get_last_summary(self) -> dict[str, int]:
        """Return the latest history sample summary."""
        return dict(self._last_summary)

    def get_last_excluded_leak_records(self) -> list[Any]:
        """Return the latest excluded leak records for debugging."""
        return list(self._last_excluded_leak_records)

    def _get_recent_records(self, records: list[Any]) -> list[Any]:
        sorted_records = list(records)
        sorted_records.sort(key=self._record_timestamp, reverse=True)
        return sorted_records[:HISTORY_WINDOW_SIZE]

    def _iter_records(self, history: Any) -> list[Any]:
        if isinstance(history, dict):
            return list(history.values())
        if isinstance(history, list):
            return list(history)
        return []

    def _is_leak_record(self, record: Any) -> bool:
        if not isinstance(record, dict):
            return False
        return record.get("leakDetected") is True

    def _record_timestamp(self, record: Any) -> int:
        if not isinstance(record, dict):
            return 0

        raw_timestamp = record.get("lastUpdated")
        if raw_timestamp is None:
            raw_timestamp = record.get("timestamp")

        if isinstance(raw_timestamp, (int, float)):
            return int(raw_timestamp)

        if isinstance(raw_timestamp, str):
            try:
                parsed = datetime.strptime(raw_timestamp, "%Y-%m-%dT%H-%M-%SZ")
            except ValueError:
                try:
                    return int(raw_timestamp)
                except (TypeError, ValueError):
                    return 0
            return int(parsed.replace(tzinfo=timezone.utc).timestamp())

        try:
            return int(raw_timestamp)
        except (TypeError, ValueError):
            return 0

    def _extract_flow_rate(self, record: Any) -> float | None:
        if not isinstance(record, dict):
            return None

        if "flowRate" not in record:
            return None

        raw_value = record.get("flowRate")
        if raw_value is None:
            return None

        try:
            flow_rate = float(raw_value)
        except (TypeError, ValueError):
            return None

        if np.isnan(flow_rate) or not np.isfinite(flow_rate):
            return None

        if flow_rate < 0.2:
            return None

        return flow_rate
```

## context_engine_python/anomaly_detector.py
```python
"""Anomaly detection for the context engine."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any

from config import (
    BASELINE_RETRAIN_HISTORY_RECORDS,
    BASELINE_RETRAIN_INTERVAL_SECONDS,
    LEAK_HYSTERESIS_LPM,
)
from statistics_engine import StatisticalBaseline, StatisticsEngine


class AnomalyDetector:
    """Detect anomalous water flow using a persisted statistical baseline."""

    def __init__(self, statistics_engine: StatisticsEngine | None = None) -> None:
        self._statistics_engine = statistics_engine or StatisticsEngine()
        self._baseline: StatisticalBaseline | None = None
        self._last_retrained_at: datetime | None = None

    @property
    def baseline(self) -> StatisticalBaseline | None:
        return self._baseline

    @property
    def has_baseline(self) -> bool:
        return self._baseline is not None

    def load_baseline(self, baseline: StatisticalBaseline | None) -> None:
        """Load a baseline learned earlier or restored from Firebase."""
        self._baseline = baseline
        if baseline is None:
            self._last_retrained_at = None
            return

        self._last_retrained_at = self._parse_timestamp(baseline.learned_at) or datetime.now(
            timezone.utc
        )

    def learn_baseline(self, history: Any) -> StatisticalBaseline | None:
        """Learn a new baseline from history without touching live monitoring."""
        baseline = self._statistics_engine.learn_baseline(history)
        if baseline is not None:
            self.load_baseline(baseline)
        return baseline

    def should_retrain(self, records_since_retrain: int, now: datetime | None = None) -> bool:
        """Return True when the stored baseline should be refreshed."""
        if self._baseline is None:
            return True

        now = now or datetime.now(timezone.utc)
        if self._last_retrained_at is None:
            return True

        if (now - self._last_retrained_at) >= timedelta(seconds=BASELINE_RETRAIN_INTERVAL_SECONDS):
            return True

        return records_since_retrain >= BASELINE_RETRAIN_HISTORY_RECORDS

    def detect_leak(
        self,
        current_flow: float,
        leak_active: bool = False,
        hysteresis_lpm: float = LEAK_HYSTERESIS_LPM,
    ) -> dict[str, Any]:
        """Compare the current flow against the stored threshold with hysteresis."""
        if self._baseline is None:
            return {
                "ready": False,
                "state": "WAITING FOR BASELINE",
                "isLeak": False,
                "enteredLeak": False,
                "exitedLeak": False,
                "shouldNotify": False,
                "currentFlow": current_flow,
                "sampleCount": 0,
                "mean": None,
                "median": None,
                "std": None,
                "minimum": None,
                "maximum": None,
                "threshold": None,
                "exitThreshold": None,
            }

        threshold = float(self._baseline.threshold)
        hysteresis_lpm = max(0.0, float(hysteresis_lpm))
        exit_threshold = threshold - hysteresis_lpm
        enter_leak = current_flow > threshold
        exit_leak = current_flow < exit_threshold

        if leak_active:
            leak_active_now = not exit_leak
            entered_leak = False
            exited_leak = exit_leak
        else:
            leak_active_now = enter_leak
            entered_leak = enter_leak
            exited_leak = False

        return {
            "ready": True,
            "state": "LEAK_ACTIVE" if leak_active_now else "NORMAL",
            "isLeak": leak_active_now,
            "enteredLeak": entered_leak,
            "exitedLeak": exited_leak,
            "shouldNotify": entered_leak,
            "currentFlow": current_flow,
            "sampleCount": self._baseline.sample_count,
            "mean": self._baseline.mean,
            "median": self._baseline.median,
            "std": self._baseline.std,
            "minimum": self._baseline.minimum,
            "maximum": self._baseline.maximum,
            "threshold": threshold,
            "exitThreshold": exit_threshold,
        }

    def record_retrain_cycle(self) -> None:
        """Mark the stored baseline as freshly retrained."""
        if self._baseline is None:
            return

        self._last_retrained_at = datetime.now(timezone.utc)

    def _parse_timestamp(self, value: Any) -> datetime | None:
        if not value:
            return None

        if isinstance(value, datetime):
            return value if value.tzinfo else value.replace(tzinfo=timezone.utc)

        if isinstance(value, str):
            try:
                parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
            except ValueError:
                return None
            return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)

        return None
```

## context_engine_python/notification_service.py
```python
"""Firebase alert creation and push notifications for the context engine."""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

import firebase_admin
from firebase_admin import credentials, db, messaging

from config import DATABASE_URL, SERVICE_ACCOUNT_FILE


class NotificationService:
    """Create Firebase alerts for detected leaks and notify devices."""

    def __init__(self) -> None:
        self._app: firebase_admin.App | None = None
        self._owns_app = False

    def _connect(self) -> None:
        """Initialize Firebase Admin SDK if needed."""
        if self._app is not None:
            return

        if not firebase_admin._apps:
            cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
            self._app = firebase_admin.initialize_app(
                cred,
                {"databaseURL": DATABASE_URL},
            )
            self._owns_app = True
            return

        self._app = firebase_admin.get_app()
        self._owns_app = False

    def create_alert(
        self,
        current_flow: float,
        threshold: float,
        event_id: str,
        last_updated: str | int | float | None = None,
    ) -> bool:
        """Create a leak alert for a new leak event."""
        self._connect()

        alert_key = self._build_alert_key(event_id)
        alert_ref = db.reference("alerts").child(alert_key)
        if alert_ref.get() is not None:
            return False

        now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
        alert = {
            "title": "Possible Water Leak",
            "message": "Current flow exceeded the learned statistical threshold.",
            "severity": "critical",
            "type": "statisticalLeak",
            "eventId": event_id,
            "currentFlow": float(current_flow),
            "threshold": float(threshold),
            "lastUpdated": last_updated,
            "timestamp": now_ms,
        }

        alert_ref.set(alert)
        return True

    def send_push_notification(
        self,
        current_flow: float,
        threshold: float,
        event_id: str,
    ) -> int:
        """Send a statistical leak push notification to all registered devices."""
        self._connect()

        now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
        tokens = self._get_device_tokens()
        sent_count = 0

        for device_id, token in tokens:
            try:
                message = messaging.Message(
                    token=token,
                    notification=messaging.Notification(
                        title="Possible Water Leak",
                        body="Current flow exceeded the learned statistical threshold.",
                    ),
                    data={
                        "type": "statisticalLeak",
                        "eventId": event_id,
                        "currentFlow": str(float(current_flow)),
                        "threshold": str(float(threshold)),
                        "timestamp": str(now_ms),
                    },
                )
                messaging.send(message)
                sent_count += 1
            except Exception:
                continue

        return sent_count

    def close(self) -> None:
        """Tear down the Firebase app if it was initialized here."""
        if self._app is not None and self._owns_app:
            firebase_admin.delete_app(self._app)

        self._app = None
        self._owns_app = False

    def _get_device_tokens(self) -> list[tuple[str, str]]:
        """Return all registered device IDs and their tokens."""
        snapshot = db.reference("deviceTokens").get()
        if not isinstance(snapshot, dict):
            return []

        tokens: list[tuple[str, str]] = []
        for device_id, raw_value in snapshot.items():
            token = self._extract_token(raw_value)
            if token:
                tokens.append((str(device_id), token))
        return tokens

    def _extract_token(self, raw_value: Any) -> str | None:
        """Pull a token string from a deviceTokens record."""
        if isinstance(raw_value, dict):
            token = raw_value.get("token")
            if token:
                return str(token)
            return None

        if raw_value:
            return str(raw_value)

        return None

    def _build_alert_key(self, event_id: str) -> str:
        """Create a Firebase-safe alert key from an event ID."""
        key = str(event_id).strip() or "event"
        safe_chars: list[str] = []
        for char in key:
            if char.isalnum() or char in {"-", "_"}:
                safe_chars.append(char)
            else:
                safe_chars.append("-")
        return "".join(safe_chars)
```

## context_engine_python/app.py
```python
"""Application entry point for the context engine service."""

from __future__ import annotations

import time
from datetime import datetime, timezone
from enum import Enum
from typing import Any

from anomaly_detector import AnomalyDetector
from config import LEAK_HYSTERESIS_LPM, MONITOR_INTERVAL_SECONDS
from firebase_service import FirebaseService
from notification_service import NotificationService
from statistics_engine import StatisticalBaseline, StatisticsEngine


class MonitorState(str, Enum):
    """Leak-monitoring state machine states."""

    NORMAL = "NORMAL"
    LEAK_ACTIVE = "LEAK_ACTIVE"


def _extract_current_flow(water_data: dict[str, Any]) -> float:
    """Return the current flow value from a water snapshot."""
    try:
        return float(water_data.get("flowRate", 0.0))
    except (TypeError, ValueError):
        return 0.0


def _format_value(value: Any, unit: str = "") -> str:
    """Format a value for terminal output."""
    if value is None:
        return "N/A"
    if isinstance(value, (int, float)):
        suffix = f" {unit}" if unit else ""
        return f"{value:.2f}{suffix}"
    return str(value)


def _print_banner() -> None:
    print("====================================================")
    print("Context Engine Started")
    print("====================================================")
    print()


def _print_firebase_connection() -> None:
    print("Connected to Firebase")
    print()


def _print_monitoring() -> None:
    print("Monitoring...")
    print()


def _print_separator() -> None:
    print("----------------------------------------------------")


def _normalize_last_updated(value: Any) -> str | None:
    """Normalize lastUpdated values so repeated snapshots compare reliably."""
    if value is None:
        return None

    if isinstance(value, (int, float)):
        return str(int(value))

    if isinstance(value, str):
        stripped = value.strip()
        return stripped or None

    return str(value)


def _load_baseline_from_state(state: dict[str, Any]) -> StatisticalBaseline | None:
    baseline_payload = state.get("baseline")
    return StatisticalBaseline.from_dict(baseline_payload)


class ContextEngineApp:
    """Stateful runner for the water-monitoring context engine."""

    def __init__(self) -> None:
        self.firebase_service = FirebaseService()
        self.notification_service = NotificationService()
        self.statistics_engine = StatisticsEngine()
        self.anomaly_detector = AnomalyDetector(self.statistics_engine)
        self.previous_last_updated: str | None = None
        self.monitor_state = MonitorState.NORMAL
        self.active_leak_event_id: str | None = None
        self.history_records_since_retrain = 0
        self.connected = False

    def run(self) -> None:
        """Start the monitoring loop."""
        _print_banner()

        try:
            self._connect_and_bootstrap()
            _print_monitoring()

            while True:
                try:
                    self._monitor_once()
                except KeyboardInterrupt:
                    raise
                except Exception:
                    self.connected = False
                    self.firebase_service.close()
                    self.notification_service.close()
                    time.sleep(MONITOR_INTERVAL_SECONDS)
                    self._connect_and_bootstrap()
                    _print_monitoring()
        finally:
            self.firebase_service.close()
            self.notification_service.close()

    def _connect_and_bootstrap(self) -> None:
        self.firebase_service.connect()
        self.connected = True
        _print_firebase_connection()
        self._load_persisted_state()
        self._ensure_baseline()

    def _load_persisted_state(self) -> None:
        state = self.firebase_service.get_context_engine_state()
        baseline = _load_baseline_from_state(state)
        if baseline is not None:
            self.anomaly_detector.load_baseline(baseline)
        else:
            self.anomaly_detector.load_baseline(None)

        self.previous_last_updated = _normalize_last_updated(state.get("lastProcessedWaterUpdated"))
        self.monitor_state = self._load_monitor_state(state)
        active_event_id = state.get("activeLeakEventId")
        self.active_leak_event_id = str(active_event_id) if active_event_id else None

        raw_retrain_count = state.get("historyRecordsSinceRetrain", 0)
        try:
            persisted_retrain_count = int(raw_retrain_count)
        except (TypeError, ValueError):
            persisted_retrain_count = 0

        if baseline is not None:
            current_history_count = self.firebase_service.get_history_record_count()
            history_gap = max(0, current_history_count - baseline.history_record_count)
            self.history_records_since_retrain = max(persisted_retrain_count, history_gap)
        else:
            self.history_records_since_retrain = persisted_retrain_count

    def _load_monitor_state(self, state: dict[str, Any]) -> MonitorState:
        raw_state = state.get("monitorState")
        if isinstance(raw_state, str):
            normalized = raw_state.strip().upper()
            if normalized in MonitorState.__members__:
                return MonitorState[normalized]
        if state.get("leakActive") is True:
            return MonitorState.LEAK_ACTIVE
        return MonitorState.NORMAL

    def _ensure_baseline(self) -> None:
        if self.anomaly_detector.baseline is not None:
            return

        history = self.firebase_service.get_history()
        learned = self.anomaly_detector.learn_baseline(history)
        if learned is not None:
            self.history_records_since_retrain = 0
            self._save_baseline(learned)

    def _monitor_once(self) -> None:
        if not self.connected:
            self._connect_and_bootstrap()

        water_data = self.firebase_service.get_water_data()
        current_last_updated = _normalize_last_updated(water_data.get("lastUpdated"))

        if current_last_updated is None or current_last_updated == self.previous_last_updated:
            _print_separator()
            print("Waiting for new sensor data...")
            _print_separator()
            print()
            time.sleep(MONITOR_INTERVAL_SECONDS)
            return

        self.history_records_since_retrain += 1
        self._maybe_retrain_baseline()
        if self.anomaly_detector.baseline is None:
            _print_separator()
            print("Waiting for new sensor data...")
            _print_separator()
            print()
            self.previous_last_updated = current_last_updated
            self._save_runtime_state()
            time.sleep(MONITOR_INTERVAL_SECONDS)
            return

        current_flow = _extract_current_flow(water_data)
        leak_active = self.monitor_state == MonitorState.LEAK_ACTIVE
        result = self.anomaly_detector.detect_leak(
            current_flow,
            leak_active=leak_active,
            hysteresis_lpm=LEAK_HYSTERESIS_LPM,
        )

        threshold = result.get("threshold")
        threshold_value = float(threshold) if threshold is not None else None
        entered_leak = bool(result.get("enteredLeak"))
        exited_leak = bool(result.get("exitedLeak"))
        new_state = MonitorState.LEAK_ACTIVE if result.get("state") == MonitorState.LEAK_ACTIVE.value else MonitorState.NORMAL
        status_text = "LEAK DETECTED" if new_state == MonitorState.LEAK_ACTIVE else "NORMAL"

        _print_separator()
        print(f"Current Flow : {_format_value(current_flow, 'L/min')}")
        print(f"Threshold : {_format_value(threshold_value, 'L/min')}")
        print(f"Status : {status_text}")

        if entered_leak:
            event_id = self.active_leak_event_id or current_last_updated or self._build_fallback_event_id()
            created = self.notification_service.create_alert(
                current_flow=current_flow,
                threshold=threshold_value if threshold_value is not None else current_flow,
                event_id=event_id,
                last_updated=current_last_updated,
            )
            if created:
                print("Firebase Alert Created")
                sent_count = self.notification_service.send_push_notification(
                    current_flow=current_flow,
                    threshold=threshold_value if threshold_value is not None else current_flow,
                    event_id=event_id,
                )
                if sent_count > 0:
                    print("Push Notification Sent")
            self.active_leak_event_id = event_id
            self.monitor_state = MonitorState.LEAK_ACTIVE
        elif exited_leak:
            self.monitor_state = MonitorState.NORMAL
            self.active_leak_event_id = None
        else:
            self.monitor_state = new_state
            if self.monitor_state == MonitorState.NORMAL:
                self.active_leak_event_id = None

        _print_separator()
        print()

        self.previous_last_updated = current_last_updated
        self._save_runtime_state()
        time.sleep(MONITOR_INTERVAL_SECONDS)

    def _maybe_retrain_baseline(self) -> None:
        if not self.anomaly_detector.should_retrain(self.history_records_since_retrain):
            return

        history = self.firebase_service.get_history()
        learned = self.anomaly_detector.learn_baseline(history)
        if learned is None:
            return

        self.history_records_since_retrain = 0
        self._save_baseline(learned)

    def _save_baseline(self, baseline: StatisticalBaseline) -> None:
        payload = {
            "baseline": baseline.to_dict(),
            "lastBaselineLearnedAt": baseline.learned_at,
            "lastBaselineHistoryCount": baseline.history_record_count,
            "historyRecordsSinceRetrain": 0,
        }
        self.firebase_service.save_context_engine_state(payload)
        self.anomaly_detector.record_retrain_cycle()
        self._save_runtime_state()

    def _save_runtime_state(self) -> None:
        payload = {
            "monitorState": self.monitor_state.value,
            "leakActive": self.monitor_state == MonitorState.LEAK_ACTIVE,
            "activeLeakEventId": self.active_leak_event_id,
            "lastProcessedWaterUpdated": self.previous_last_updated,
            "historyRecordsSinceRetrain": self.history_records_since_retrain,
            "baseline": self.anomaly_detector.baseline.to_dict()
            if self.anomaly_detector.baseline is not None
            else None,
        }
        self.firebase_service.save_context_engine_state(payload)

    def _build_fallback_event_id(self) -> str:
        now = datetime.now(timezone.utc)
        return now.strftime("%Y%m%d%H%M%S%f")


def main() -> None:
    """Start the context engine application."""
    app = ContextEngineApp()

    try:
        app.run()
    except FileNotFoundError:
        print("Error: serviceAccountKey.json was not found in the project root.")
    except KeyboardInterrupt:
        print("Stopping Context Engine...")
    except Exception as exc:
        print(f"Error: unable to connect to Firebase or read data: {exc}")


if __name__ == "__main__":
    main()
```

## context_engine_python/generate_sample_history.py
```python
"""Generate realistic sample water usage history and upload it to Firebase."""

from __future__ import annotations

import random
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Iterable

try:
    import firebase_admin
    from firebase_admin import credentials, db
except ImportError as exc:  # pragma: no cover - runtime dependency check
    raise SystemExit(
        "Missing dependency: firebase-admin. Install it before running this script."
    ) from exc


DATABASE_URL = "https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app"
RECORD_COUNT = 1000
INTERVAL_SECONDS = 10

CATEGORY_SPECS: list[tuple[str, float, tuple[float, float], bool]] = [
    ("night", 0.10, (0.0, 0.2), False),
    ("normal", 0.40, (0.8, 2.5), False),
    ("morning", 0.25, (2.5, 5.5), False),
    ("evening", 0.15, (2.5, 5.0), False),
    ("high_usage", 0.05, (5.5, 7.5), False),
    ("leak", 0.05, (8.0, 12.0), True),
]


def resolve_service_account_file() -> Path:
    """Find the Firebase service account file without touching other projects."""
    script_dir = Path(__file__).resolve().parent
    candidates = [
        script_dir / "context_engine_python" / "serviceAccountKey.json",
        script_dir / "serviceAccountKey.json",
    ]

    for candidate in candidates:
        if candidate.exists():
            return candidate

    raise FileNotFoundError(
        "Could not find serviceAccountKey.json in the repo root or context_engine_python/."
    )


def make_timestamp_key(timestamp: datetime) -> str:
    """Create a Firebase-safe key for the record timestamp."""
    return timestamp.strftime("%Y-%m-%dT%H-%M-%SZ")


def category_counts(total_records: int) -> dict[str, int]:
    """Convert category percentages into exact record counts."""
    counts: dict[str, int] = {}
    allocated = 0

    for index, (name, percentage, _, _) in enumerate(CATEGORY_SPECS):
        if index == len(CATEGORY_SPECS) - 1:
            count = total_records - allocated
        else:
            count = round(total_records * percentage)
            allocated += count
        counts[name] = count

    return counts


def build_category_sequence(rng: random.Random, total_records: int) -> list[str]:
    """Build a shuffled list that preserves the requested distribution exactly."""
    counts = category_counts(total_records)
    categories: list[str] = []

    for name, count in counts.items():
        categories.extend([name] * count)

    rng.shuffle(categories)
    return categories


def generate_history_records(
    rng: random.Random,
) -> tuple[list[tuple[str, dict[str, object]]], dict[str, int], list[float]]:
    """Build the 1,000 history records requested by the user."""
    now = datetime.now(timezone.utc).replace(microsecond=0)
    start_time = now - timedelta(seconds=(RECORD_COUNT - 1) * INTERVAL_SECONDS)
    categories = build_category_sequence(rng, RECORD_COUNT)

    records: list[tuple[str, dict[str, object]]] = []
    counts = {name: 0 for name, _, _, _ in CATEGORY_SPECS}
    flow_values: list[float] = []
    total_usage = round(rng.uniform(2500.0, 8000.0), 2)
    daily_usage = 0.0
    current_day = None

    flow_ranges = {name: flow_range for name, _, flow_range, _ in CATEGORY_SPECS}

    for index in range(RECORD_COUNT):
        timestamp = start_time + timedelta(seconds=index * INTERVAL_SECONDS)
        if current_day != timestamp.date():
            current_day = timestamp.date()
            daily_usage = 0.0

        timestamp_key = make_timestamp_key(timestamp)
        category = categories[index]
        low, high = flow_ranges[category]
        flow_rate = round(rng.uniform(low, high), 2)

        counts[category] += 1
        flow_values.append(flow_rate)

        usage_increment = flow_rate * (INTERVAL_SECONDS / 60.0)
        total_usage = round(total_usage + usage_increment, 2)
        daily_usage = round(daily_usage + usage_increment, 2)

        records.append(
            (
                timestamp_key,
                {
                    "flowRate": flow_rate,
                    "totalUsage": total_usage,
                    "dailyUsage": daily_usage,
                    "leakDetected": category == "leak",
                    "lastUpdated": timestamp_key,
                },
            )
        )

    return records, counts, flow_values


def upload_history(records: Iterable[tuple[str, dict[str, object]]]) -> int:
    """Upload the generated records to `/history`."""
    service_account_file = resolve_service_account_file()

    if not firebase_admin._apps:
        cred = credentials.Certificate(str(service_account_file))
        firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})

    history_payload = {key: value for key, value in records}
    db.reference("history").set(history_payload)
    return len(history_payload)


def main() -> None:
    rng = random.Random()

    records, counts, flow_values = generate_history_records(rng)
    uploaded_records = upload_history(records)

    print(f"Total records: {len(records)}")
    print(f"Normal records: {counts['normal']}")
    print(f"Night records: {counts['night']}")
    print(f"Morning records: {counts['morning']}")
    print(f"Evening records: {counts['evening']}")
    print(f"High usage records: {counts['high_usage']}")
    print(f"Leak records: {counts['leak']}")
    print(f"Uploaded records: {uploaded_records}")
    print(f"Minimum flow: {min(flow_values):.2f}")
    print(f"Maximum flow: {max(flow_values):.2f}")
    print(f"Average flow: {sum(flow_values) / len(flow_values):.2f}")
    print("Finished")


if __name__ == "__main__":
    main()
```

## context_engine_python/requirements.txt
```text
firebase-admin
numpy
pandas
scipy
watchdog
```

## context_engine_python/serviceAccountKey.json.example
```
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "your-private-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nYOUR_PRIVATE_KEY\\n-----END PRIVATE KEY-----\\n",
  "client_email": "firebase-adminsdk@example.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-example"
}
```

