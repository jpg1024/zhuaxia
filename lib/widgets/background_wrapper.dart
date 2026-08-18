import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// 背景图包装器（双端通用）
class BackgroundWrapper extends ConsumerWidget {
  final Widget child;

  const BackgroundWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景图层
        _buildBackground(settings.backgroundImagePath, isDark),
        // 渐变遮罩层
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.6),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.4),
                    ],
            ),
          ),
        ),
        // 内容层
        child,
      ],
    );
  }

  Widget _buildBackground(String? customPath, bool isDark) {
    // 自定义背景图
    if (customPath != null && customPath.isNotEmpty) {
      final file = File(customPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildDefaultBackground(isDark),
        );
      }
    }

    return _buildDefaultBackground(isDark);
  }

  Widget _buildDefaultBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ]
              : [
                  const Color(0xFFE8EAF6),
                  const Color(0xFFC5CAE9),
                  const Color(0xFF9FA8DA),
                ],
        ),
      ),
    );
  }
}
