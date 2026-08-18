import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import '../models/todo.dart';
import 'notification_service.dart';

/// Android 日历事件同步服务
class CalendarService {
  static final CalendarService instance = CalendarService._();
  CalendarService._();

  final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();
  bool _hasPermission = false;

  /// 请求日历权限
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _calendarPlugin.hasPermissions();
      if (result.isSuccess && result.data == true) {
        _hasPermission = true;
        return true;
      }

      final permResult = await _calendarPlugin.requestPermissions();
      _hasPermission = permResult.isSuccess && permResult.data == true;
      return _hasPermission;
    } catch (e) {
      debugPrint('日历权限请求失败: $e');
      return false;
    }
  }

  /// 创建日历事件
  Future<String?> createCalendarEvent(Todo todo) async {
    if (!Platform.isAndroid || !_hasPermission) return null;

    try {
      // 获取默认日历
      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) return null;

      final calendars = calendarsResult.data!;
      if (calendars.isEmpty) return null;

      // 使用第一个可写日历
      Calendar? defaultCalendar;
      for (final cal in calendars) {
        if (cal.isDefault ?? false) {
          defaultCalendar = cal;
          break;
        }
      }
      defaultCalendar ??= calendars.first;

      // 检查精确闹钟权限，决定是否可以设置提醒
      final hasExactAlarm = await NotificationService.instance.canScheduleExactAlarms();
      final reminders = hasExactAlarm ? [Reminder(minutes: 15)] : <Reminder>[];

      // 创建事件
      final event = Event(
        defaultCalendar.id,
        title: todo.title,
        description: todo.description,
        start: TZDateTime.from(todo.dateTime, local),
        end: TZDateTime.from(
          todo.dateTime.add(const Duration(hours: 1)),
          local,
        ),
        reminders: reminders,
      );

      final result = await _calendarPlugin.createOrUpdateEvent(event);
      if (result != null && result.isSuccess && result.data != null) {
        return result.data!.toString();
      }
    } catch (e) {
      debugPrint('创建日历事件失败: $e');
    }
    return null;
  }

  /// 更新日历事件
  Future<void> updateCalendarEvent(Todo todo) async {
    if (!Platform.isAndroid || !_hasPermission) return;
    if (todo.calendarEventId == null) return;

    try {
      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) return;

      final calendars = calendarsResult.data!;
      if (calendars.isEmpty) return;

      Calendar? defaultCalendar;
      for (final cal in calendars) {
        if (cal.isDefault ?? false) {
          defaultCalendar = cal;
          break;
        }
      }
      defaultCalendar ??= calendars.first;

      final hasExactAlarm = await NotificationService.instance.canScheduleExactAlarms();
      final reminders = hasExactAlarm ? [Reminder(minutes: 15)] : <Reminder>[];

      final event = Event(
        defaultCalendar.id,
        eventId: todo.calendarEventId,
        title: todo.title,
        description: todo.description,
        start: TZDateTime.from(todo.dateTime, local),
        end: TZDateTime.from(
          todo.dateTime.add(const Duration(hours: 1)),
          local,
        ),
        reminders: reminders,
      );

      await _calendarPlugin.createOrUpdateEvent(event);
    } catch (e) {
      debugPrint('更新日历事件失败: $e');
    }
  }

  /// 删除日历事件
  Future<void> deleteCalendarEvent(String eventId) async {
    if (!Platform.isAndroid || !_hasPermission) return;

    try {
      await _calendarPlugin.deleteEvent('', eventId);
    } catch (e) {
      debugPrint('删除日历事件失败: $e');
    }
  }
}
