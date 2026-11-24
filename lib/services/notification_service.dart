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

