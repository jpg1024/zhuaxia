import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:windows_notification/windows_notification.dart';
import 'package:windows_notification/notification_message.dart';
import '../models/todo.dart';
import '../core/extensions.dart';

/// 本地通知服务
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Timer? _windowsCheckTimer;
  WindowsNotification? _winNotify;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    if (Platform.isAndroid) {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(initSettings);
    } else if (Platform.isWindows) {
      _initWindowsNotifications();
      _startWindowsScheduler();
    }

    _initialized = true;
  }

  /// 初始化 Windows 通知
  void _initWindowsNotifications() {
    try {
      _winNotify = WindowsNotification(applicationId: 'com.zhuaxia.zhuaxia');
    } catch (e) {
      debugPrint('Windows 通知初始化失败: $e');
    }
  }

  /// 请求通知权限（Android 13+）
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// 检查精确闹钟权限是否已授予
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;
    return await androidPlugin.canScheduleExactNotifications() ?? false;
  }

  /// 引导用户到系统设置页开启精确闹钟权限
  Future<void> requestExactAlarmsPermission() async {
    if (!Platform.isAndroid) return;
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// 安排定时通知
  Future<void> scheduleTodoReminder(Todo todo) async {
    if (!_initialized) await initialize();

    final scheduledDate = todo.dateTime;
    if (scheduledDate.isPast) return;

    if (Platform.isAndroid) {
      final id = todo.id.hashCode;
      const androidDetails = AndroidNotificationDetails(
        'todo_reminders',
        '待办提醒',
        channelDescription: '待办事项定时提醒通知',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      final exactAllowed = await canScheduleExactAlarms();
      final scheduleMode = exactAllowed
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      await _plugin.zonedSchedule(
        id,
        todo.title,
        '提醒: ${todo.dateTime.formattedShort}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: todo.id,
      );
    } else if (Platform.isWindows) {
      await _saveWindowsReminder(todo);
    }
  }

  /// 取消通知
  Future<void> cancelTodoReminder(String todoId) async {
    if (Platform.isAndroid) {
      await _plugin.cancel(todoId.hashCode);
    } else if (Platform.isWindows) {
      await _removeWindowsReminder(todoId);
    }
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    if (Platform.isWindows) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('win_reminders');
    }
  }

  // ==================== Windows 定时提醒机制 ====================

  /// 保存 Windows 提醒到 SharedPreferences
  Future<void> _saveWindowsReminder(Todo todo) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('win_reminders') ?? [];
    reminders.removeWhere((r) => r.startsWith('${todo.id}|'));
    reminders.add('${todo.id}|${todo.title}|${todo.dateTime.toIso8601String()}');
    await prefs.setStringList('win_reminders', reminders);
  }

  /// 移除 Windows 提醒
  Future<void> _removeWindowsReminder(String todoId) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('win_reminders') ?? [];
    reminders.removeWhere((r) => r.startsWith('$todoId|'));
    await prefs.setStringList('win_reminders', reminders);
  }

  /// 启动 Windows 定时检查器（每 30 秒检查一次）
  void _startWindowsScheduler() {
    _windowsCheckTimer?.cancel();
    _windowsCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkWindowsReminders();
    });
  }

  /// 检查并触发到期的 Windows 提醒
  Future<void> _checkWindowsReminders() async {
    if (!Platform.isWindows) return;

    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('win_reminders') ?? [];
    if (reminders.isEmpty) return;

    final now = DateTime.now();
    final triggered = <String>[];

    for (final reminder in reminders) {
      final parts = reminder.split('|');
      if (parts.length < 3) continue;

      final title = parts[1];
      final dateTime = DateTime.tryParse(parts[2]);
      if (dateTime == null) continue;

      // 到期判断：设定时间 <= 当前时间 且未超过 60 秒
      if (dateTime.isBefore(now) && now.difference(dateTime).inSeconds <= 60) {
        _showWindowsNotification(title, dateTime);
        triggered.add(reminder);
      }
      // 清理过期超过 5 分钟的旧提醒
      else if (now.difference(dateTime).inMinutes > 5) {
        triggered.add(reminder);
      }
    }

    if (triggered.isNotEmpty) {
      reminders.removeWhere((r) => triggered.contains(r));
      await prefs.setStringList('win_reminders', reminders);
    }
  }

  /// 显示 Windows 桌面 Toast 通知
  void _showWindowsNotification(String title, DateTime dateTime) {
    if (_winNotify == null) return;
    try {
      final message = NotificationMessage.fromPluginTemplate(
        DateTime.now().millisecondsSinceEpoch.toString(),
        '抓虾 - $title',
        '提醒时间: ${dateTime.formattedShort}',
      );
      _winNotify!.showNotificationPluginTemplate(message);
    } catch (e) {
      debugPrint('Windows 通知发送失败: $e');
    }
  }

  /// 停止定时检查器
  void dispose() {
    _windowsCheckTimer?.cancel();
  }
}
