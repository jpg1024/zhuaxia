import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/todo.dart';
import '../core/extensions.dart';

/// 本地通知服务
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化时区数据
    tz_data.initializeTimeZones();

    if (Platform.isAndroid) {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(initSettings);
    }

    _initialized = true;
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

    final id = todo.id.hashCode;

    if (Platform.isAndroid) {
      const androidDetails = AndroidNotificationDetails(
        'todo_reminders',
        '待办提醒',
        channelDescription: '待办事项定时提醒通知',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      // 检查精确闹钟权限，根据权限选择合适的调度模式
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
    }
  }

  /// 取消通知
  Future<void> cancelTodoReminder(String todoId) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(todoId.hashCode);
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
