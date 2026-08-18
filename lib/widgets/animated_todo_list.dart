import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import 'todo_item_card.dart';
import 'todo_date_header.dart';

/// 带动画的待办列表
class AnimatedTodoList extends ConsumerWidget {
  const AnimatedTodoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);

    if (todos.isEmpty) {
      return const _EmptyListPlaceholder();
    }

    // 按日期分组
    final grouped = ref.read(todoProvider.notifier).groupedTodos;

    return RefreshIndicator(
      onRefresh: () => ref.read(todoProvider.notifier).loadTodos(),
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: grouped.entries.fold<int>(0, (sum, e) => sum + 1 + e.value.length),
        itemBuilder: (context, index) {
          int currentIndex = 0;
          for (final entry in grouped.entries) {
            // 日期标题
            if (currentIndex == index) {
              return TodoDateHeader(
                label: entry.key,
                count: entry.value.length,
              );
            }
            currentIndex++;

            // 待办卡片
            if (index < currentIndex + entry.value.length) {
              final todoIndex = index - currentIndex;
              return TodoItemCard(
                todo: entry.value[todoIndex],
                index: todoIndex,
              );
            }
            currentIndex += entry.value.length;
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// 空列表占位
class _EmptyListPlaceholder extends StatelessWidget {
  const _EmptyListPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.15),
          )
              .animate()
              .scale(duration: 600.milliseconds, curve: Curves.elasticOut)
              .then()
              .shake(hz: 1, duration: 400.milliseconds),
          const SizedBox(height: 16),
          Text(
            '还没有待办事项',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ).animate(delay: 200.milliseconds).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            '点击下方 + 按钮添加你的第一个待办',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
            ),
          ).animate(delay: 400.milliseconds).fadeIn(),
        ],
      ),
    );
  }
}
