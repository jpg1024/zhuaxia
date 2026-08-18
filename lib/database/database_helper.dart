import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';
import '../models/todo.dart';

/// SQLite 数据库帮助类
class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    // Windows 平台使用 FFI
    if (!kIsWeb && Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbDir.path, AppConstants.databaseName);

    return openDatabase(
      dbPath,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.todosTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date_time TEXT NOT NULL,
        is_reminder INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        calendar_event_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 创建索引
    await db.execute(
      'CREATE INDEX idx_date_time ON ${AppConstants.todosTable}(date_time DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_is_completed ON ${AppConstants.todosTable}(is_completed)',
    );
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级逻辑
  }

  /// 插入待办
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return db.insert(AppConstants.todosTable, todo.toMap());
  }

  /// 更新待办
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return db.update(
      AppConstants.todosTable,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  /// 删除待办
  Future<int> deleteTodo(String id) async {
    final db = await database;
    return db.delete(
      AppConstants.todosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取所有待办（按时间排序）
  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.todosTable,
      orderBy: 'date_time DESC',
    );
    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  /// 根据 ID 获取待办
  Future<Todo?> getTodoById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.todosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Todo.fromMap(maps.first);
  }

  /// 获取未完成的待办
  Future<List<Todo>> getUpcomingTodos() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      AppConstants.todosTable,
      where: 'is_completed = 0 AND date_time >= ?',
      whereArgs: [now],
      orderBy: 'date_time ASC',
    );
    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
