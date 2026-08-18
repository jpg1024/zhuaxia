import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions.dart';
import '../database/database_provider.dart';
import '../models/todo.dart';

/// Todo 列表状态管理
class TodoNotifier extends StateNotifier<List<Todo>> {
  final Ref ref;

  TodoNotifier(this.ref) : super([]) {
    loadTodos();
  }

  /// 从数据库加载所有待办
  Future<void> loadTodos() async {
    final db = ref.read(databaseProvider);
    final todos = await db.getAllTodos();
    state = todos;
    _syncWidgetData();
  }

  /// 添加待办
  Future<void> addTodo(Todo todo) async {
    final db = ref.read(databaseProvider);
    await db.insertTodo(todo);
    state = [...state, todo]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    _syncWidgetData();
  }

  /// 更新待办
  Future<void> updateTodo(Todo todo) async {
    final db = ref.read(databaseProvider);
    final updated = todo.copyWith(updatedAt: DateTime.now());
    await db.updateTodo(updated);
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
    _syncWidgetData();
  }

  /// 删除待办
  Future<void> deleteTodo(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteTodo(id);
    state = state.where((t) => t.id != id).toList();
    _syncWidgetData();
  }

  /// 切换完成状态
  Future<void> toggleComplete(String id) async {
    final todo = state.firstWhere((t) => t.id == id);
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    final db = ref.read(databaseProvider);
    await db.updateTodo(updated);
    state = state.map((t) => t.id == id ? updated : t).toList();
    _syncWidgetData();
  }

  /// 同步待办数量到 Widget（SharedPreferences + MethodChannel）
  void _syncWidgetData() {
    if (!Platform.isAndroid) return;
    final count = pendingCount;
    // 写入 SharedPreferences，供原生 Widget 读取
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('widget_pending_count', count);
    });
    // 通过 MethodChannel 通知原生 Widget 刷新
    try {
      const channel = MethodChannel('com.zhuaxia/widget');
      channel.invokeMethod('updateWidget', {'pendingCount': count});
    } catch (_) {}
  }

  /// 获取未完成的待办数量
  int get pendingCount => state.where((t) => !t.isCompleted).length;

  /// 按日期分组
  Map<String, List<Todo>> get groupedTodos {
    final sorted = List<Todo>.from(state)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final Map<String, List<Todo>> groups = {};
    for (final todo in sorted) {
      final key = todo.dateTime.dateGroupLabel;
      groups.putIfAbsent(key, () => []).add(todo);
    }
    return groups;
  }
}

/// Todo Provider
final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier(ref);
});

/// 待办数量 Provider
final pendingCountProvider = Provider<int>((ref) {
  return ref.watch(todoProvider.notifier).pendingCount;
});
