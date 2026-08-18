import 'package:flutter/material.dart';

/// 应用统一色彩系统
class AppColors {
  AppColors._();

  // 主色调 - 柔和蓝紫渐变
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D1);

  // 渐变色
  static const Color gradientStart = Color(0xFF6C63FF);
  static const Color gradientEnd = Color(0xFFE91E63);

  // 语义色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // 浅色模式文字
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textDarkSecondary = Color(0xFF6B7280);

  // 深色模式文字
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textLightSecondary = Color(0xFF9CA3AF);

  // 玻璃效果背景
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x20FFFFFF);

  // 卡片边框
  static const Color borderLight = Color(0x30FFFFFF);
  static const Color borderDark = Color(0x15FFFFFF);

  // 渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fabGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
