import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

/// Windows 系统托盘服务
class TrayService {
  static final TrayService instance = TrayService._();
  TrayService._();

  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();
  bool _initialized = false;
  int _pendingCount = 0;

  /// 初始化系统托盘
  Future<void> initialize() async {
    if (!Platform.isWindows || _initialized) return;

    try {
      // 初始化窗口管理器
      await windowManager.ensureInitialized();

      // 创建托盘图标
      await _systemTray.initSystemTray(
        title: '抓虾',
        iconPath: 'assets/icons/tray_icon.ico',
        toolTip: '抓虾 - 待办事项',
      );

      // 创建右键菜单
      await _updateMenu();

      // 点击事件处理
      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventRightClick) {
          _systemTray.popUpContextMenu();
        } else if (eventName == kSystemTrayEventClick) {
          _showWindow();
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint('系统托盘初始化失败: $e');
    }
  }

  /// 更新托盘菜单（显示待办数量）
  Future<void> updateTrayMenu(int pendingCount) async {
    if (!_initialized || !Platform.isWindows) return;
    _pendingCount = pendingCount;
    await _updateMenu();
  }

  Future<void> _updateMenu() async {
    final items = <MenuItemBase>[
      MenuItemLabel(
        label: '待办事项: $_pendingCount 项未完成',
        enabled: false,
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: '打开应用',
        onClicked: (menuItem) => _showWindow(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: '退出',
        onClicked: (menuItem) => exit(0),
      ),
    ];

    await _menu.buildFrom(items);
    await _systemTray.setToolTip('抓虾 - $_pendingCount 项待办');
    await _systemTray.setContextMenu(_menu);
  }

  /// 显示窗口
  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  /// 销毁托盘
  Future<void> destroy() async {
    if (_initialized) {
      await _systemTray.destroy();
      _initialized = false;
    }
  }
}
