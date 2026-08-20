import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:window_manager/window_manager.dart';
import '../core/theme/app_colors.dart';
import '../core/constants.dart';
import '../providers/todo_provider.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/animated_todo_list.dart';
import '../widgets/reminder_overlay.dart';
import '../widgets/window_controls.dart';

/// 主页 - 待办列表
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // 顶部左侧 logo（图片本身已为圆角，双端统一显示）
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 长按标题可拖动窗口（Windows 无边框窗口）
              GestureDetector(
                onLongPress: () {
                  if (Platform.isWindows) {
                    windowManager.startDragging();
                  }
                },
                child: Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // 待办计数徽章
            if (pendingCount > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            // 设置按钮
            IconButton(
              icon: Icon(
                Icons.settings_rounded,
                color: isDark ? AppColors.textLight : AppColors.textDark,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            WindowControls(isDark: isDark),
          ],
        ),
        body: Stack(
          children: [
            const AnimatedTodoList(),
            // 右下角提醒弹窗（避开 FAB，悬浮在其上方）
            Positioned(
              right: 16,
              bottom: 88,
              child: const ReminderOverlay(),
            ),
          ],
        ),
        floatingActionButton: _buildFab(context),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/add_edit');
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: AppColors.fabGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2.seconds);
  }
}
