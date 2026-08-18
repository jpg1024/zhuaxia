import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/tray_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Windows 平台初始化
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(420, 750),
      minimumSize: Size(360, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // 初始化通知服务
  await NotificationService.instance.initialize();

  // Android: 进入app时请求通知权限
  if (Platform.isAndroid) {
    await NotificationService.instance.requestPermission();
  }

  // 初始化系统托盘（仅 Windows）
  if (Platform.isWindows) {
    await TrayService.instance.initialize();
  }

  runApp(
    const ProviderScope(
      child: ZhuaxiaApp(),
    ),
  );
}
