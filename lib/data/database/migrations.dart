import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

class Migration {
  Migration._();

  /// Upgrades schema step-by-step without dropping old tables or user data.
  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      // Version 2: add category_id to classify products.
      if (oldVersion < 2 && newVersion >= 2) {
        final hasCategoryId = await _hasColumn(
          db,
          ProductTable.tableName,
          ProductTable.categoryId,
        );

        if (!hasCategoryId) {
          await db.execute(
            'ALTER TABLE ${ProductTable.tableName} '
            'ADD COLUMN ${ProductTable.categoryId} INTEGER;',
          );
          _log('Migration V2 done: added products.category_id');
        }
      }

      // Version 3: add created_at to store product creation time.
      if (oldVersion < 3 && newVersion >= 3) {
        final hasCreatedAt = await _hasColumn(
          db,
          ProductTable.tableName,
          ProductTable.createdAt,
        );

        if (!hasCreatedAt) {
          await db.execute(
            'ALTER TABLE ${ProductTable.tableName} '
            'ADD COLUMN ${ProductTable.createdAt} '
            'TEXT DEFAULT CURRENT_TIMESTAMP;',
          );
          _log('Migration V3 done: added products.created_at');
        }
      }

      // Version 4: create categories table for product classification.
      if (oldVersion < 4 && newVersion >= 4) {
        final hasCategoriesTable = await _hasTable(db, CategoryTable.tableName);

        if (!hasCategoriesTable) {
          await db.execute('''
            CREATE TABLE ${CategoryTable.tableName} (
              ${CategoryTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${CategoryTable.name} TEXT NOT NULL,
              ${CategoryTable.image} TEXT NOT NULL,
              ${CategoryTable.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP
            )
          ''');
          _log('Migration V4 done: created categories table');
        }
      }

      // Version 5: add role column to users table for admin management.
      if (oldVersion < 5 && newVersion >= 5) {
        const usersTable = 'users';
        final hasRoleColumn = await _hasColumn(db, usersTable, 'role');

        if (!hasRoleColumn) {
          await db.execute(
            'ALTER TABLE $usersTable '
            'ADD COLUMN role TEXT DEFAULT \'user\';',
          );
          _log('Migration V5 done: added users.role');
        }
      }

      // Future versions (V6, V7...) can extend other tables.
    } catch (e) {
      _log('Migration error: $e');
      rethrow;
    }
  }

  static Future<bool> _hasColumn(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    return columns.any((column) => column['name'] == columnName);
  }

  static Future<bool> _hasTable(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [tableName],
    );

    return result.isNotEmpty;
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
