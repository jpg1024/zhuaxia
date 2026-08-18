import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/extensions.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../services/notification_service.dart';
import '../services/calendar_service.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/custom_date_time_picker.dart';
import '../widgets/window_controls.dart';

/// 添加/编辑待办页面
class AddEditTodoScreen extends ConsumerStatefulWidget {
  const AddEditTodoScreen({super.key});

  @override
  ConsumerState<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends ConsumerState<AddEditTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 5));
  bool _isReminder = false;
  bool _isSaving = false;
  Todo? _editingTodo;

  bool get _isEditing => _editingTodo != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Todo) {
      _editingTodo = args;
      _titleController.text = args.title;
      _descriptionController.text = args.description ?? '';
      // 编辑模式：如果待办时间已过去，则默认设为当前 + 5分钟
      final minTime = DateTime.now().add(const Duration(minutes: 5));
      _selectedDateTime = args.dateTime.isBefore(minTime) ? minTime : args.dateTime;
      _isReminder = args.isReminder;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _isEditing ? '编辑待办' : '新增待办',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          actions: [
            WindowControls(isDark: isDark),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期时间选择器
              CustomDateTimePicker(
                selectedDateTime: _selectedDateTime,
                onChanged: (dt) => setState(() => _selectedDateTime = dt),
              ).animate().fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 20),

              // 标题输入框
              TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: '输入待办事项标题...',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                  ),
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                  ),
                ),
                maxLines: 1,
                textInputAction: TextInputAction.next,
              ).animate(delay: 100.milliseconds).fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 16),

              // 描述输入框
              TextField(
                controller: _descriptionController,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: '添加描述（选填）...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                  ),
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                    color: isDark
                        ? AppColors.textLightSecondary
                        : AppColors.textDarkSecondary,
                  ),
                ),
                maxLines: 4,
                minLines: 2,
                textInputAction: TextInputAction.done,
              ).animate(delay: 200.milliseconds).fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 20),

              // 提醒开关（仅 Android 显示）
              if (Platform.isAndroid)
                _buildReminderSwitch(isDark)
                    .animate(delay: 300.milliseconds)
                    .fadeIn()
                    .slideY(begin: 0.1),

              const SizedBox(height: 40),

              // 保存按钮
              _buildSaveButton(isDark)
                  .animate(delay: 400.milliseconds)
                  .fadeIn()
                  .slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSwitch(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '日历提醒',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
                Text(
                  '同步到系统日历',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textLightSecondary
                        : AppColors.textDarkSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isReminder,
            onChanged: (v) => setState(() => _isReminder = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveTodo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSaving ? null : _saveTodo,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.fabGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditing ? '保存修改' : '添加待办',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveTodo() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入待办事项标题'),
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 时间必须至少是当前时间 + 5分钟
    final minAllowed = DateTime.now().add(const Duration(minutes: 5));
    if (_selectedDateTime.isBefore(minAllowed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请选择当前时间 5 分钟之后的时间'),
          backgroundColor: AppColors.warning,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        // 更新
        final updated = _editingTodo!.copyWith(
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dateTime: _selectedDateTime,
          isReminder: _isReminder,
          updatedAt: DateTime.now(),
        );
        await ref.read(todoProvider.notifier).updateTodo(updated);

        // 更新通知
        await NotificationService.instance.cancelTodoReminder(_editingTodo!.id);
        await NotificationService.instance.scheduleTodoReminder(updated);

        // 更新日历事件
        if (Platform.isAndroid && _isReminder) {
          await CalendarService.instance.updateCalendarEvent(updated);
        }
      } else {
        // 新增
        final todo = Todo.create(
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dateTime: _selectedDateTime,
          isReminder: _isReminder,
        );

        // 处理日历同步
        String? calendarEventId;
        if (Platform.isAndroid && _isReminder) {
          try {
            await CalendarService.instance.requestPermission();
            calendarEventId = await CalendarService.instance.createCalendarEvent(todo);
          } catch (calErr) {
            debugPrint('日历同步失败: $calErr');
          }
        }

        final finalTodo = todo.copyWith(calendarEventId: calendarEventId);
        await ref.read(todoProvider.notifier).addTodo(finalTodo);

        // 安排通知
        await NotificationService.instance.scheduleTodoReminder(finalTodo);
      }

      // 保存成功后，检查精确闹钟权限并弹窗提醒用户授权
      if (Platform.isAndroid && _selectedDateTime.isFuture && mounted) {
        final exactAllowed = await NotificationService.instance.canScheduleExactAlarms();
        if (!exactAllowed && mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('开启精确闹钟'),
              content: const Text(
                '检测到系统未开启精确闹钟权限，提醒可能不会准时触发。\n\n'
                '建议前往系统设置开启此权限，以确保待办提醒准时送达。',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('稍后再说'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    NotificationService.instance.requestExactAlarmsPermission();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('去开启'),
                ),
              ],
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
