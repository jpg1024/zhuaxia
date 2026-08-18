import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

/// 空状态插画组件
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;

  const EmptyStateWidget({
    super.key,
    this.message = '暂无内容',
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 动画图标组
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.circle,
                size: 100,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              Icon(
                Icons.task_alt_rounded,
                size: 56,
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.4)
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ],
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 200.milliseconds).fadeIn().slideY(begin: 0.2),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage!,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.3),
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 400.milliseconds).fadeIn(),
          ],
        ],
      ),
    );
  }
}
