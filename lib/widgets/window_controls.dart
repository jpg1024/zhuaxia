import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../core/theme/app_colors.dart';

/// Windows 窗口控制按钮组（最小化、最大化、关闭）
class WindowControls extends StatelessWidget {
  final bool isDark;

  const WindowControls({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) return const SizedBox.shrink();

    final fgColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowButton(
          icon: Icons.remove,
          tooltip: '最小化',
          color: fgColor,
          onTap: () => windowManager.minimize(),
        ),
        _WindowButton(
          icon: Icons.crop_square_outlined,
          tooltip: '最大化',
          color: fgColor,
          onTap: () async {
            final isMaximized = await windowManager.isMaximized();
            if (isMaximized) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
        ),
        _WindowButton(
          icon: Icons.close,
          tooltip: '关闭',
          color: AppColors.error,
          onTap: () => windowManager.close(),
          isClose: true,
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hoverBg = widget.isClose
        ? AppColors.error
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06));

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 40,
            height: 36,
            decoration: BoxDecoration(
              color: _hovering ? hoverBg : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovering && widget.isClose ? Colors.white : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

/// 使 AppBar 区域可拖动窗口（Windows）
mixin WindowDraggableMixin on State {
  void startWindowDrag(DragStartDetails details) {
    if (Platform.isWindows) {
      windowManager.startDragging();
    }
  }
}
