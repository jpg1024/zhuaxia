import 'package:intl/intl.dart';

/// DateTime 扩展方法
extension DateTimeExtension on DateTime {
  /// 格式化为 "yyyy年MM月dd日"
  String get formattedDate => DateFormat('yyyy年MM月dd日').format(this);

  /// 格式化为 "HH:mm"
  String get formattedTime => DateFormat('HH:mm').format(this);

  /// 格式化为 "yyyy-MM-dd HH:mm:ss"
  String get formattedFull => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  /// 格式化为 "MM月dd日 HH:mm"
  String get formattedShort => DateFormat('MM月dd日 HH:mm').format(this);

  /// 格式化为 "E MMMd" 如 "周一 8月16日"
  String get formattedWeekday => DateFormat('E MM月d日', 'zh_CN').format(this);

  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否为明天
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// 是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// 是否为过去时间
  bool get isPast => isBefore(DateTime.now());

  /// 是否为未来时间
  bool get isFuture => isAfter(DateTime.now());

  /// 获取日期分组标签
  String get dateGroupLabel {
    if (isToday) return '今天';
    if (isTomorrow) return '明天';
    if (isYesterday) return '昨天';
    return formattedWeekday;
  }

  /// 去除毫秒精度
  DateTime get withoutMilliseconds => DateTime(year, month, day, hour, minute, second);
}

/// String 扩展方法
extension StringExtension on String {
  /// 截断字符串
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}
