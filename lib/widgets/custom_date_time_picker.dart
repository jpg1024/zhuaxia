import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/extensions.dart';

/// 自定义日期时间选择器（滚轮风格）
/// - 日期滚轮：今天 / 明天 / 周五 / 周六 / 周日 + 后续月日
/// - 时 / 分滚轮，秒固定为 0
class CustomDateTimePicker extends StatelessWidget {
  final DateTime selectedDateTime;
  final ValueChanged<DateTime> onChanged;

  const CustomDateTimePicker({
    super.key,
    required this.selectedDateTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _pickDateTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // 顶部仅显示 "xx月xx日"
                    '${selectedDateTime.month}月${selectedDateTime.day}日',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDateTime.formattedTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textLightSecondary
                          : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DateTimeSheet(initial: selectedDateTime),
    );
    if (result == null) return;

    // 确保选择的时间至少是当前时间 + 5分钟
    final minAllowed = DateTime.now().add(const Duration(minutes: 5));
    onChanged(result.isBefore(minAllowed) ? minAllowed : result);
  }
}

/// 滚轮式日期时间选择弹窗
class _DateTimeSheet extends StatefulWidget {
  final DateTime initial;
  const _DateTimeSheet({required this.initial});

  @override
  State<_DateTimeSheet> createState() => _DateTimeSheetState();
}

class _DateTimeSheetState extends State<_DateTimeSheet> {
  static const List<String> _weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  // 90 天的日期序列
  static const int _dateCount = 90;

  late final List<DateTime> _dates;

  // 滚轮控制器
  late final FixedExtentScrollController _dateController;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  late int _dateIndex;
  late int _hour;
  late int _minute;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 生成日期列表：快捷日期 + 后续普通日期（去重、按时间排序）
    final shortcuts = _computeShortcuts(today);
    final dates = <DateTime>[...shortcuts];
    for (int i = 0; i < _dateCount; i++) {
      final d = today.add(Duration(days: i));
      final exists = dates.any((e) => _isSameDay(e, d));
      if (!exists) dates.add(d);
    }
    dates.sort();
    _dates = dates;

    // 初始位置：widget.initial 的日期
    int initIdx = dates.indexWhere(
      (d) => _isSameDay(d, DateTime(widget.initial.year, widget.initial.month, widget.initial.day)),
    );
    _dateIndex = initIdx < 0 ? 0 : initIdx;
    _hour = widget.initial.hour.clamp(0, 23);
    _minute = widget.initial.minute.clamp(0, 59);

    _dateController = FixedExtentScrollController(initialItem: _dateIndex);
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// 计算快捷日期：今天、明天、最近一次周五/周六/周日（按时间排序去重）
  List<DateTime> _computeShortcuts(DateTime today) {
    int daysTo(int targetWeekday) {
      int diff = targetWeekday - today.weekday;
      if (diff <= 0) diff += 7;
      return diff;
    }

    final set = <DateTime>{
      today,
      today.add(const Duration(days: 1)),
      today.add(Duration(days: daysTo(5))), // 周五
      today.add(Duration(days: daysTo(6))), // 周六
      today.add(Duration(days: daysTo(7))), // 周日
    };
    return set.toList()..sort();
  }

  /// 快捷偏移（1小时后 / 1天后 / 1周后 / 1个月后）
  /// 一律从「当前时间」开始计算
  void _applyOffset(Duration duration, {bool month = false}) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final target = month
        ? DateTime(base.year, base.month + 1, base.day, base.hour, base.minute)
        : base.add(duration);

    setState(() {
      final idx = _dates.indexWhere(
        (d) => _isSameDay(d, DateTime(target.year, target.month, target.day)),
      );
      if (idx >= 0) {
        _dateIndex = idx;
        _dateController.jumpToItem(idx);
      }
      _hour = target.hour;
      _minute = target.minute;
      _hourController.jumpToItem(_hour);
      _minuteController.jumpToItem(_minute);
    });
  }

  DateTime get _result => DateTime(
        _dates[_dateIndex].year,
        _dates[_dateIndex].month,
        _dates[_dateIndex].day,
        _hour,
        _minute,
        0, // 秒固定为 0
      );

  /// 日期项文字对：(主文字, 副文字)
  (String, String) _dateLabelPair(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final wd = _weekdayNames[d.weekday - 1];
    if (_isSameDay(d, today)) {
      return ('今天', '${d.month}月${d.day}日 $wd');
    }
    if (_isSameDay(d, today.add(const Duration(days: 1)))) {
      return ('明天', '${d.month}月${d.day}日 $wd');
    }
    return ('${d.month}月${d.day}日', wd);
  }

  /// 单列滚轮
  Widget _wheel<T>({
    required FixedExtentScrollController controller,
    required List<T> items,
    required String Function(T item) label,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder,
  }) {
    final fg = _isDark ? AppColors.textLight : AppColors.textDark;

    return SizedBox(
      width: 128,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 选中高亮条
          IgnorePointer(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: _isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 44,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                final isSelected = index == selectedIndex;
                if (itemBuilder != null) {
                  return itemBuilder(context, items[index], isSelected);
                }
                return Center(
                  child: Text(
                    label(items[index]),
                    style: TextStyle(
                      fontSize: isSelected ? 17 : 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : fg.withValues(alpha: 0.55),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fg = _isDark ? AppColors.textLight : AppColors.textDark;
    final subColor = _isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary;
    final bg = _isDark ? const Color(0xFF1E1E28) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部横条
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // 标题
          Text(
            '设置提醒时间',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: fg),
          ),
          const SizedBox(height: 4),

          // 三列滚轮
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _wheel(
                  controller: _dateController,
                  items: _dates,
                  label: (d) => _dateLabelPair(d).$1,
                  selectedIndex: _dateIndex,
                  onChanged: (i) => setState(() => _dateIndex = i),
                  itemBuilder: (context, d, isSelected) {
                    final (main, sub) = _dateLabelPair(d);
                    final fg = _isDark ? AppColors.textLight : AppColors.textDark;
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            main,
                            style: TextStyle(
                              fontSize: isSelected ? 17 : 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : fg.withValues(alpha: 0.55),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sub,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.75)
                                  : fg.withValues(alpha: 0.35),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _wheel(
                  controller: _hourController,
                  items: [for (var h = 0; h < 24; h++) h],
                  label: (h) => '$h时',
                  selectedIndex: _hour,
                  onChanged: (i) => setState(() => _hour = i),
                ),
                _wheel(
                  controller: _minuteController,
                  items: [for (var m = 0; m < 60; m++) m],
                  label: (m) => '${m.toString().padLeft(2, '0')}分',
                  selectedIndex: _minute,
                  onChanged: (i) => setState(() => _minute = i),
                ),
              ],
            ),
          ),

          // 快捷偏移按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QuickButton(label: '1小时后', onTap: () => _applyOffset(const Duration(hours: 1))),
              const SizedBox(width: 8),
              _QuickButton(label: '1天后', onTap: () => _applyOffset(const Duration(days: 1))),
              const SizedBox(width: 8),
              _QuickButton(label: '1周后', onTap: () => _applyOffset(const Duration(days: 7))),
              const SizedBox(width: 8),
              _QuickButton(label: '1个月后', onTap: () => _applyOffset(const Duration(), month: true)),
            ],
          ),
          const SizedBox(height: 16),

          // 取消 / 设置
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: subColor,
                    side: BorderSide(
                      color: _isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('取消', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_result),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('设置', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 快捷偏移按钮
class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.textLight : AppColors.textDark;

    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
          ),
        ),
      ),
    );
  }
}
