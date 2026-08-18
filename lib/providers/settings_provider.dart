import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

/// 设置状态
class SettingsState {
  final ThemeMode themeMode;
  final String? backgroundImagePath;
  final bool notificationEnabled;
  final bool calendarSyncEnabled;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.backgroundImagePath,
    this.notificationEnabled = true,
    this.calendarSyncEnabled = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? backgroundImagePath,
    bool clearBackgroundImage = false,
    bool? notificationEnabled,
    bool? calendarSyncEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      backgroundImagePath: clearBackgroundImage
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      calendarSyncEnabled: calendarSyncEnabled ?? this.calendarSyncEnabled,
    );
  }
}

/// 设置状态管理
class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;
  SharedPreferences? _prefs;

  SettingsNotifier(this.ref) : super(const SettingsState()) {
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    final themeModeIndex = _prefs!.getInt(AppConstants.keyThemeMode) ?? 0;
    final bgPath = _prefs!.getString(AppConstants.keyBackgroundImagePath);
    final notifEnabled = _prefs!.getBool(AppConstants.keyNotificationEnabled) ?? true;
    final calEnabled = _prefs!.getBool(AppConstants.keyCalendarSyncEnabled) ?? false;

    state = SettingsState(
      themeMode: ThemeMode.values[themeModeIndex.clamp(0, 2)],
      backgroundImagePath: bgPath,
      notificationEnabled: notifEnabled,
      calendarSyncEnabled: calEnabled,
    );
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs?.setInt(AppConstants.keyThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  /// 设置背景图路径
  Future<void> setBackgroundImage(String? path) async {
    if (path == null) {
      await _prefs?.remove(AppConstants.keyBackgroundImagePath);
      state = state.copyWith(clearBackgroundImage: true);
    } else {
      await _prefs?.setString(AppConstants.keyBackgroundImagePath, path);
      state = state.copyWith(backgroundImagePath: path);
    }
  }

  /// 设置通知开关
  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyNotificationEnabled, enabled);
    state = state.copyWith(notificationEnabled: enabled);
  }

  /// 设置日历同步开关
  Future<void> setCalendarSyncEnabled(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyCalendarSyncEnabled, enabled);
    state = state.copyWith(calendarSyncEnabled: enabled);
  }
}

/// 设置 Provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
