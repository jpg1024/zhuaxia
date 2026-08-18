import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/theme/app_colors.dart';
import '../core/constants.dart';
import '../providers/settings_provider.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_card.dart';

/// 设置页面
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isPickingImage = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '设置',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题设置
              _buildSectionTitle('主题', isDark),
              const SizedBox(height: 8),
              _buildThemeSelector(isDark)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.1),

              const SizedBox(height: 24),

              // 背景图设置
              _buildSectionTitle('背景图', isDark),
              const SizedBox(height: 8),
              _buildBackgroundImageSection(isDark)
                  .animate(delay: 100.milliseconds)
                  .fadeIn()
                  .slideY(begin: 0.1),

              const SizedBox(height: 24),

              // 通知设置
              _buildSectionTitle('通知', isDark),
              const SizedBox(height: 8),
              _buildNotificationSettings(isDark)
                  .animate(delay: 200.milliseconds)
                  .fadeIn()
                  .slideY(begin: 0.1),

              if (Platform.isAndroid) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('日历', isDark),
                const SizedBox(height: 8),
                _buildCalendarSettings(isDark)
                    .animate(delay: 300.milliseconds)
                    .fadeIn()
                    .slideY(begin: 0.1),
              ],

              const SizedBox(height: 40),

              // 应用信息
              Center(
                child: Column(
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v${AppConstants.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 400.milliseconds).fadeIn(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.black.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(bool isDark) {
    final currentMode = ref.watch(settingsProvider).themeMode;

    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildThemeOption(
            icon: Icons.light_mode_rounded,
            title: '浅色模式',
            value: ThemeMode.light,
            current: currentMode,
            isDark: isDark,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            icon: Icons.dark_mode_rounded,
            title: '深色模式',
            value: ThemeMode.dark,
            current: currentMode,
            isDark: isDark,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            icon: Icons.settings_suggest_rounded,
            title: '跟随系统',
            value: ThemeMode.system,
            current: currentMode,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required ThemeMode value,
    required ThemeMode current,
    required bool isDark,
  }) {
    final isSelected = value == current;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : null,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.textLight : AppColors.textDark),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
          : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setThemeMode(value);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      dense: true,
    );
  }

  Widget _buildBackgroundImageSection(bool isDark) {
    final bgPath = ref.watch(settingsProvider).backgroundImagePath;

    return GlassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 背景图预览
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: bgPath != null && File(bgPath).existsSync()
                  ? DecorationImage(
                      image: FileImage(File(bgPath)),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: bgPath == null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1A1A2E), const Color(0xFF0F3460)]
                          : [const Color(0xFFE8EAF6), const Color(0xFF9FA8DA)],
                    )
                  : null,
            ),
            child: bgPath == null
                ? Center(
                    child: Text(
                      '默认背景',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.3),
                        fontSize: 14,
                      ),
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 12),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPickingImage ? null : _pickBackgroundImage,
                  icon: const Icon(Icons.image_rounded, size: 18),
                  label: const Text('选择图片'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (bgPath != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetBackgroundImage,
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text('恢复默认'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 恢复默认背景：删除磁盘文件并清除路径
  Future<void> _resetBackgroundImage() async {
    final bgPath = ref.read(settingsProvider).backgroundImagePath;
    // 删除磁盘上的背景图文件
    if (bgPath != null) {
      try {
        final file = File(bgPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
        // 清除 FileImage 缓存，避免后续选择同名文件时显示旧图
        FileImage(file).evict();
      } catch (_) {
        // 忽略文件删除失败
      }
    }
    ref.read(settingsProvider.notifier).setBackgroundImage(null);
  }

  Widget _buildNotificationSettings(bool isDark) {
    final notifEnabled = ref.watch(settingsProvider).notificationEnabled;

    return GlassCard(
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '通知提醒',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Text(
                      '开启后将在设定时间发送通知',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textLightSecondary
                            : AppColors.textDarkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: notifEnabled,
                onChanged: (v) {
                  ref.read(settingsProvider.notifier).setNotificationEnabled(v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSettings(bool isDark) {
    final calEnabled = ref.watch(settingsProvider).calendarSyncEnabled;

    return GlassCard(
      isDark: isDark,
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '日历同步',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
                Text(
                  '待办事项同步到系统日历',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textLightSecondary
                        : AppColors.textDarkSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: calEnabled,
            onChanged: (v) {
              ref.read(settingsProvider.notifier).setCalendarSyncEnabled(v);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickBackgroundImage() async {
    setState(() => _isPickingImage = true);

    try {
      String? selectedPath;

      if (Platform.isAndroid) {
        // Android: 使用 image_picker 从相册选
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (image != null) {
          selectedPath = image.path;
        }
      } else if (Platform.isWindows) {
        // Windows: 使用 file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
          allowMultiple: false,
        );
        if (result != null && result.files.isNotEmpty) {
          selectedPath = result.files.first.path;
        }
      }

      if (selectedPath != null && mounted) {
        // 复制到应用文档目录持久化，使用时间戳文件名避免缓存
        final appDir = await getApplicationDocumentsDirectory();
        final ext = p.extension(selectedPath);
        final uniqueName = 'bg_${DateTime.now().microsecondsSinceEpoch}$ext';
        final destPath = p.join(appDir.path, uniqueName);

        // 删除旧的背景图文件（如果存在）
        final oldPath = ref.read(settingsProvider).backgroundImagePath;
        if (oldPath != null) {
          try {
            final oldFile = File(oldPath);
            if (oldFile.existsSync()) oldFile.deleteSync();
            FileImage(oldFile).evict();
          } catch (_) {}
        }

        await File(selectedPath).copy(destPath);
        ref.read(settingsProvider.notifier).setBackgroundImage(destPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }
}
