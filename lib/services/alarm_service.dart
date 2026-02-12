// Removed code fence markers

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/stop_model.dart';
import 'stop_service.dart';

/// AlarmService
/// ----------------------------
/// • Singleton
/// • Управляет остановками
/// • Симулирует движение
/// • Срабатывает ОДИН раз на предпоследней
class AlarmService extends ChangeNotifier {
  AlarmService._internal();
  static final AlarmService instance = AlarmService._internal();

  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();


  // ===== AUDIO =====
  final AudioPlayer _player = AudioPlayer();

  // ===== DATA =====
  late final List<StopModel> _stops;
  List<StopModel> get stops => _stops;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  StopModel? _target;
  StopModel? get target => _target;

  bool _enabled = false;
  bool get enabled => _enabled;

  bool _alarmTriggered = false; // 🔥 КЛЮЧЕВО

  Timer? _timer;

  // ===== INIT =====
  Future<void> init() async {
    // Load cached stops first for fast startup
    _stops = await StopService.readCachedStops();
    _currentIndex = 0;
    _alarmTriggered = false;
    await _initNotifications();

    // Refresh stops from network in background
    StopService.fetchAndCacheStops().then((fetched) {
      if (fetched.isNotEmpty) {
        _stops = fetched;
        notifyListeners();
      }
    }).catchError((_) {});
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _localNotifications.initialize(settings: settings, onDidReceiveNotificationResponse: (NotificationResponse r) {});
  }

  // ===== LIFECYCLE =====
  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  // ===== TARGET =====
  void setTarget(StopModel stop) {
    _target = stop;
    _alarmTriggered = false; // сброс при новом выборе
    notifyListeners();
  }

  StopModel? getPenultimateStop() {
    if (_target == null) return null;
    return StopService.getPreLastStop(_stops, _target!);
  }

  // ===== ENABLE =====
  void setEnabled(bool value) {
    _enabled = value;

    if (_enabled) {
      startSimulation();
    } else {
      stopSimulation();
    }

    notifyListeners();
  }

  // ===== SIMULATION =====
  void startSimulation({int stepSeconds = 3}) {
    stopSimulation();

    _timer = Timer.periodic(Duration(seconds: stepSeconds), (_) {
      _moveNext();
    });
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
  }

  void resetPosition() {
    _currentIndex = 0;
    _alarmTriggered = false;
    notifyListeners();
  }

  void _moveNext() {
    _currentIndex++;

    if (_currentIndex >= _stops.length) {
      _currentIndex = 0;
    }

    _checkAlarm();
    notifyListeners();
  }

  // ===== ALARM LOGIC =====
  Future<void> _checkAlarm() async {
    if (!_enabled) return;
    if (_alarmTriggered) return;
    if (_target == null) return;

    final penultimate = getPenultimateStop();
    if (penultimate == null) return;

    final penIndex = _stops.indexOf(penultimate);

    if (penIndex == _currentIndex) {
      _alarmTriggered = true;
      await _playAlarm();
    }
  }

  Future<void> _playAlarm() async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource('alarm.mp3'),
        volume: 1.0,
      );
      // show local notification
      final title = 'LastStop';
      final body = 'Приближаемся к остановке ${_target?.name ?? ''}';
      const androidDetails = AndroidNotificationDetails('laststop_channel', 'LastStop Alerts', importance: Importance.max, priority: Priority.high);
      const platform = NotificationDetails(android: androidDetails);
      await _localNotifications.show(id: 0, title: title, body: body, notificationDetails: platform);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Alarm error: $e');
      }
    }
  }
}
