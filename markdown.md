# Prompt for Copilot/Codex

Copy and paste this prompt directly into VS Code Copilot/Codex.

---

Update the existing Flutter project to enable **automatic alert generation** based on water monitoring context rules.

### Important Requirements

* Do NOT modify the UI design of `alerts_screen.dart`.
* Do NOT modify the Arduino code.
* Do NOT change Firebase database structure except adding new alert records under `/alerts`.
* Do NOT run `flutter analyze`, `flutter test`, or any terminal commands.
* Only update the specified files.

---

## File 1: `lib/services/firebase_service.dart`

Inside the existing `FirebaseService` class, add this new method below `watchAlerts()`:

```dart
Future<void> createAlert({
  required String title,
  required String message,
  required String severity,
}) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  await _alertsRef.child(timestamp.toString()).set({
    'title': title,
    'message': message,
    'severity': severity,
    'timestamp': timestamp,
    'read': false,
  });
}
```

Do not modify any existing methods.

---

## File 2: `lib/screens/dashboard_screen.dart`

### Add import:

```dart
import '../services/firebase_service.dart';
```

Keep all existing imports.

---

### Add these state variables inside `_DashboardScreenState`:

```dart
final FirebaseService _firebaseService = FirebaseService();

bool _previousLeakDetected = false;
bool _previousNightUsage = false;

int lastUpdated = 0;
```

Place them below:

```dart
bool leakDetected = false;
```

---

### Update the Firebase listener inside `initState()`.

Find:

```dart
setState(() {
  flowRate = (water['flowRate'] ?? 0).toDouble();
  totalUsage = (water['totalUsage'] ?? 0).toDouble();
  dailyUsage = (water['dailyUsage'] ?? 0).toDouble();
  leakDetected = water['leakDetected'] ?? false;
});
```

Replace it with:

```dart
setState(() {
  flowRate = (water['flowRate'] ?? 0).toDouble();
  totalUsage = (water['totalUsage'] ?? 0).toDouble();
  dailyUsage = (water['dailyUsage'] ?? 0).toDouble();
  leakDetected = water['leakDetected'] ?? false;
  lastUpdated = water['lastUpdated'] ?? 0;
});
```

Immediately after `setState()`, add:

```dart
_generateAlerts();
```

---

### Add this new method inside `_DashboardScreenState`:

```dart
Future<void> _generateAlerts() async {
  if (leakDetected && !_previousLeakDetected) {
    await _firebaseService.createAlert(
      title: 'Possible leak',
      message: 'Continuous flow detected.',
      severity: 'critical',
    );
  }

  _previousLeakDetected = leakDetected;

  if (lastUpdated <= 0) {
    return;
  }

  final dateTime = DateTime.fromMillisecondsSinceEpoch(
    lastUpdated * 1000,
  );

  final isNightUsage =
      dateTime.hour >= 0 &&
      dateTime.hour <= 5 &&
      flowRate > 1.0;

  if (isNightUsage && !_previousNightUsage) {
    await _firebaseService.createAlert(
      title: 'Night-time usage',
      message: 'Water usage detected during sleeping hours.',
      severity: 'warning',
    );
  }

  _previousNightUsage = isNightUsage;
}
```

Place this method before `dispose()`.

---

### Update `currentData` creation inside `build()`.

Find:

```dart
final currentData = WaterData(
  flowRate: flowRate,
  totalUsage: totalUsage,
  dailyUsage: dailyUsage,
  leakDetected: leakDetected,
  lastUpdated: 0,
);
```

Replace with:

```dart
final currentData = WaterData(
  flowRate: flowRate,
  totalUsage: totalUsage,
  dailyUsage: dailyUsage,
  leakDetected: leakDetected,
  lastUpdated: lastUpdated,
);
```

---

## Expected Behavior

* When `/water/leakDetected` changes from `false` to `true`, create a critical alert.
* When water flow is greater than `1.0 L/min` between `00:00` and `05:59`, create a warning alert.
* Prevent duplicate alerts by only creating alerts when the state changes.
* Existing `AlertsScreen` should update automatically because it already listens to `/alerts`.

Do not make any other changes outside these requirements.
