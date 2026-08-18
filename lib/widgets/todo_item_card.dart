import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../core/extensions.dart';
import '../core/theme/app_colors.dart';
import '../providers/todo_provider.dart';
import 'glass_card.dart';

/// 单个待办卡片
class TodoItemCard extends ConsumerWidget {
  final Todo todo;
  final int index;

  const TodoItemCard({
    super.key,
    required this.todo,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = todo.isCompleted;
    final isExpired = todo.dateTime.isPast && !isCompleted;

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 300)),
        SlideEffect(
          begin: Offset(0, 0.1),
          end: Offset.zero,
          duration: Duration(milliseconds: 300),
        ),
      ],
      delay: Duration(milliseconds: index * 50),
      child: Dismissible(
        key: Key(todo.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirm(context);
        },
        onDismissed: (_) {
          ref.read(todoProvider.notifier).deleteTodo(todo.id);
        },
        child: GlassCard(
          isDark: isDark,
          onTap: () => _onTap(context, ref),
          onLongPress: () => _onLongPress(context, ref),
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 左侧彩色时间线条
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    gradient: isCompleted
                        ? LinearGradient(
                            colors: [Colors.grey.shade400, Colors.grey.shade300],
                          )
                        : isExpired
                            ? const LinearGradient(
                                colors: [AppColors.error, AppColors.warning],
                              )
                            : AppColors.primaryGradient,
                  ),
                ),
                // 完成勾选
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(todoProvider.notifier).toggleComplete(todo.id);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.success
                              : isDark
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.15)
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.success,
                            )
                          : null,
                    ),
                  ),
                ),
                // 内容区域
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? (isCompleted
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppColors.textLight)
                                : (isCompleted
                                    ? AppColors.textDarkSecondary
                                    : AppColors.textDark),
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // 时间和提醒状态
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: isExpired
                                  ? AppColors.error
                                  : isDark
                                      ? AppColors.textLightSecondary
                                      : AppColors.textDarkSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              todo.dateTime.formattedShort,
                              style: TextStyle(
                                fontSize: 13,
                                color: isExpired
                                    ? AppColors.error
                                    : isDark
                                        ? AppColors.textLightSecondary
                                        : AppColors.textDarkSecondary,
                                fontWeight: isExpired
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (todo.isReminder) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.notifications_active_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '已提醒',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // 描述
                        if (todo.description != null &&
                            todo.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            todo.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textLightSecondary.withValues(alpha: 0.7)
                                  : AppColors.textDarkSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pushNamed(
      '/add_edit',
      arguments: todo,
    );
  }

  void _onLongPress(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                todo.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline,
                color: AppColors.success,
              ),
              title: Text(todo.isCompleted ? '标记为未完成' : '标记为已完成'),
              onTap: () {
                ref.read(todoProvider.notifier).toggleComplete(todo.id);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(ctx);
                _onTap(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('删除', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                final confirmed = await _showDeleteConfirm(context);
                if (confirmed && context.mounted) {
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    ref.read(todoProvider.notifier).deleteTodo(todo.id);
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确认删除'),
        content: const Text('确定要删除这条待办事项吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
