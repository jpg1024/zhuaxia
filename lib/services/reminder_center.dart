import 'package:flutter/foundation.dart';

/// 单条提醒
class ReminderItem {
  final String id;
  final String title;
  final String message;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.message,
  });
}

/// Windows 提醒弹窗队列中心：
/// 弹窗不自动消失，直到用户手动关闭。
class ReminderCenter {
  ReminderCenter._();

  static final ReminderCenter instance = ReminderCenter._();

  final ValueNotifier<List<ReminderItem>> _items = ValueNotifier(const []);

  /// 当前提醒列表（监听以驱动 UI）
  ValueListenable<List<ReminderItem>> get items => _items;

  /// 添加提醒
  void add(ReminderItem item) {
    _items.value = [..._items.value, item];
  }

  /// 关闭指定提醒
  void dismiss(String id) {
    _items.value = _items.value.where((e) => e.id != id).toList();
  }
}
