import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  // Kết nối SQLite để thao tác bảng users.
  final DatabaseHelper _dbHelper = DatabaseHelper();

  static const String _tableUsers = 'users';
  static const String _colId = 'id';
  static const String _colEmail = 'email';
  static const String _colName = 'name';
  static const String _colPassword = 'password';

  // Phuc vu AuthProvider login/register.
  Future<User?> login(String email, String password) async {
    try {
      final user = await getUserByEmail(email);
      if (user == null) {
        return null;
      }

      if ((user.password ?? '') != password) {
        return null;
      }

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> register(User user) async {
    try {
      final normalizedEmail = user.email.trim().toLowerCase();
      if (normalizedEmail.isEmpty) {
        throw Exception('Email không hợp lệ');
      }

      if ((user.password ?? '').isEmpty) {
        throw Exception('Mật khẩu không hợp lệ');
      }

      final existingUser = await getUserByEmail(normalizedEmail);
      if (existingUser != null) {
        throw Exception('Email đã tồn tại');
      }

      final db = await _dbHelper.database;
      await _ensureUsersTable(db);

      final map = user.copyWith(email: normalizedEmail).toMap()..remove(_colId);
      await db.insert(
        _tableUsers,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Email đã tồn tại');
      }
      throw Exception('Register failed: $e');
    } catch (e) {
      rethrow;
    }
  }

  // Tra ve du lieu typed User.
  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await _dbHelper.database;
      await _ensureUsersTable(db);

      final normalizedEmail = email.trim().toLowerCase();
      final result = await db.query(
        _tableUsers,
        where: 'LOWER($_colEmail) = ?',
        whereArgs: [normalizedEmail],
        limit: 1,
      );

      if (result.isEmpty) {
        return null;
      }

      return User.fromMap(result.first);
    } catch (e) {
      throw Exception('Get user by email failed: $e');
    }
  }

  Future<User?> getUserById(int id) async {
    try {
      final db = await _dbHelper.database;
      await _ensureUsersTable(db);

      final result = await db.query(
        _tableUsers,
        where: '$_colId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isEmpty) {
        return null;
      }

      return User.fromMap(result.first);
    } catch (e) {
      throw Exception('Get user by id failed: $e');
    }
  }

  Future<void> _ensureUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableUsers (
        $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_colEmail TEXT NOT NULL UNIQUE,
        $_colName TEXT,
        $_colPassword TEXT NOT NULL,
        role TEXT DEFAULT 'user'
      )
    ''');
  }
}
