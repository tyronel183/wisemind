import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../navigation/app_navigator.dart';


/// Сервис для локальных уведомлений
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyStateReminderId = 1;

  Future<void> init() async {
    // 1. Инициализация таймзоны
    tz.initializeTimeZones();
    try {
      final dynamic timeZone = await FlutterTimezone.getLocalTimezone();

      // flutter_timezone в новых версиях возвращает объект TimezoneInfo,
      // чьё toString() выглядит как "TimezoneInfo(Asia/Yerevan, (locale: en_US, name: Armenia Standard Time))".
      // Нам нужно вытащить именно идентификатор "Asia/Yerevan".
      String timeZoneName;
      if (timeZone is String) {
        timeZoneName = timeZone;
      } else {
        final tzString = timeZone.toString();
        final start = tzString.indexOf('(');
        final end = tzString.indexOf(',', start + 1);
        if (start != -1 && end != -1) {
          timeZoneName = tzString.substring(start + 1, end);
        } else {
          timeZoneName = 'UTC';
        }
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Failed to init timezone for notifications: $e');
    }

    // 2. Базовые настройки иконок и т.п.
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTapNotification,
    );

    // 3. Запрос разрешений (Android 13+ и iOS)
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImpl?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Планируем ежедневное напоминание "Карта дня" на локальное время [time]
  Future<void> scheduleDailyStateReminder(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);

    var firstTrigger = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Если на сегодня время уже прошло — переносим на завтра
    if (firstTrigger.isBefore(now)) {
      firstTrigger = firstTrigger.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_state_channel',
      'Ежедневные напоминания о карте дня',
      channelDescription: 'Напоминания заполнить карту дня в Wisemind',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _dailyStateReminderId,
      'Как прошёл ваш день?',
      'Нажмите, чтобы заполнить карту дня 🧠',
      firstTrigger,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // важное: повторять каждый день в то же время
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_state',
    );
  }

  /// Отмена ежедневного напоминания (если сделаешь тумблер в настройках)
  Future<void> cancelDailyStateReminder() async {
    await _plugin.cancel(_dailyStateReminderId);
  }

  void _onTapNotification(NotificationResponse response) {
    if (response.payload == 'daily_state') {
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  /// Тестовое уведомление, чтобы проверить, что всё работает
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Тестовые уведомления',
      channelDescription: 'Канал для теста локальных уведомлений',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      999, // произвольный id
      'Тестовое уведомление',
      'Если ты видишь это, локальные уведомления работают ✅',
      details,
      payload: 'test_notification',
    );
  }

  /// Включение/выключение ежедневного напоминания о "Карте дня"
  /// [enabled] - если true, планируем напоминание на [time],
  /// если false — отменяем его.
  Future<void> setDailyStateReminderEnabled({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    if (enabled) {
      await scheduleDailyStateReminder(time);
    } else {
      await cancelDailyStateReminder();
    }
  }
}