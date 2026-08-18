import 'package:uuid/uuid.dart';

/// 待办事项数据模型
class Todo {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final bool isReminder;
  final bool isCompleted;
  final String? calendarEventId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.isReminder = false,
    this.isCompleted = false,
    this.calendarEventId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建新的 Todo（自动生成 ID 和时间戳）
  factory Todo.create({
    required String title,
    String? description,
    DateTime? dateTime,
    bool isReminder = false,
  }) {
    final now = DateTime.now();
    return Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      dateTime: dateTime ?? now,
      isReminder: isReminder,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从数据库 Map 创建 Todo
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dateTime: DateTime.parse(map['date_time'] as String),
      isReminder: (map['is_reminder'] as int) == 1,
      isCompleted: (map['is_completed'] as int) == 1,
      calendarEventId: map['calendar_event_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'is_reminder': isReminder ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
      'calendar_event_id': calendarEventId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isReminder,
    bool? isCompleted,
    String? calendarEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isReminder: isReminder ?? this.isReminder,
      isCompleted: isCompleted ?? this.isCompleted,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
