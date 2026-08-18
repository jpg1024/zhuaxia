/// 全局常量定义
class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = '抓虾';
  static const String appVersion = '1.0.0';

  // 数据库
  static const String databaseName = 'zhuaxia_todos.db';
  static const int databaseVersion = 1;
  static const String todosTable = 'todos';

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyBackgroundImagePath = 'background_image_path';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keyCalendarSyncEnabled = 'calendar_sync_enabled';

  // 动画时长
  static const Duration animDurationFast = Duration(milliseconds: 200);
  static const Duration animDurationNormal = Duration(milliseconds: 350);
  static const Duration animDurationSlow = Duration(milliseconds: 500);

  // 圆角
  static const double radiusCard = 20.0;
  static const double radiusButton = 12.0;
  static const double radiusSmall = 8.0;
}
