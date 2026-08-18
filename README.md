# 抓虾 Todo

一款基于 Flutter 开发的现代化待办事项应用，支持 Android 和 Windows 双平台。

## 功能特性

- **待办管理** — 添加、编辑、删除、标记完成，支持按日期分组展示
- **自定义背景** — Android / Windows 双端支持自定义背景图，浅色/深色主题切换
- **日历同步** — Android 端待办可同步到系统日历，支持日历提醒
- **定时通知** — 精确到秒的定时提醒，支持 Android 精确闹钟权限
- **桌面小组件** — Android 桌面 Widget 实时显示待办数量
- **系统托盘** — Windows 端系统托盘图标，显示待办统计
- **Material 3** — Glassmorphism 毛玻璃风格 UI，流畅动画效果

## 技术栈

| 模块 | 技术方案 |
|------|---------|
| 框架 | Flutter 3.44 |
| 状态管理 | Riverpod |
| 本地存储 | SQLite (sqflite / sqflite_common_ffi) |
| 通知 | flutter_local_notifications |
| 日历集成 | device_calendar |
| 系统托盘 | system_tray + window_manager |
| 动画 | flutter_animate |

## 项目结构

```
lib/
├── main.dart                    # 入口，平台初始化
├── app.dart                     # MaterialApp、路由、主题
├── core/
│   ├── theme/                   # Material 3 主题 & 色彩系统
│   ├── constants.dart           # 全局常量
│   └── extensions.dart          # DateTime/String 扩展
├── models/
│   └── todo.dart                # Todo 数据模型
├── database/
│   └── database_helper.dart     # SQLite CRUD（双端适配）
├── providers/
│   ├── todo_provider.dart       # 待办列表状态管理
│   └── settings_provider.dart   # 主题/背景图偏好
├── services/
│   ├── notification_service.dart  # 本地定时通知
│   ├── calendar_service.dart      # Android 日历同步
│   └── tray_service.dart          # Windows 系统托盘
├── screens/
│   ├── home_screen.dart           # 主页待办列表
│   ├── add_edit_todo_screen.dart  # 添加/编辑待办
│   └── settings_screen.dart       # 设置页
└── widgets/
    ├── glass_card.dart            # 毛玻璃卡片
    ├── background_wrapper.dart    # 背景图包装器
    ├── animated_todo_list.dart    # 动画待办列表
    └── ...                        # 其他 UI 组件
```

## 环境要求

- Flutter SDK >= 3.12
- Android: minSdk 33 (Android 13+)
- Windows: 需要 Visual Studio C++ 工作负载
- JDK 17 推荐

## 快速开始

```bash
# 克隆项目
git clone https://github.com/your-username/zhuaxia.git
cd zhuaxia

# 安装依赖
flutter pub get

# 运行（Android）
flutter run -d android

# 运行（Windows）
flutter run -d windows

# 构建 APK
flutter build apk --release

# 构建 Windows
flutter build windows --release
```

## 平台特性

### Android
- 桌面小组件（App Widget）显示待办数量
- 系统日历事件同步
- 精确闹钟定时提醒
- 通知权限运行时请求

### Windows
- 系统托盘图标 + 右键菜单
- 自定义背景图支持
- 窗口最小化到托盘

## 许可证

MIT License
