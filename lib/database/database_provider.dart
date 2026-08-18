import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';

/// 数据库 Provider
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
