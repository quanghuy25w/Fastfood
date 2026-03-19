import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'migrations.dart';
import 'tables.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static const String _databaseName = 'fastfood.db';
  static const int _databaseVersion = 4;

  static bool _factoryInitialized = false;

  Database? _database;

  /// Returns the single database instance (lazy initialization).
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  /// Initializes and opens the local SQLite database on device storage.
  Future<Database> initDatabase() async {
    _ensureDatabaseFactoryInitialized();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await Migration.upgrade(db, oldVersion, newVersion);
      },
    );
  }

  /// Configures database factory for web before using global sqflite APIs.
  void _ensureDatabaseFactoryInitialized() {
    if (_factoryInitialized) {
      return;
    }

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    _factoryInitialized = true;
  }

  /// Creates app tables when the database is first created.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${CategoryTable.tableName} (
        ${CategoryTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoryTable.name} TEXT NOT NULL,
        ${CategoryTable.image} TEXT NOT NULL,
        ${CategoryTable.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ProductTable.tableName} (
        ${ProductTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ProductTable.name} TEXT NOT NULL,
        ${ProductTable.price} REAL NOT NULL,
        ${ProductTable.description} TEXT,
        ${ProductTable.image} TEXT,
        ${ProductTable.categoryId} INTEGER,
        ${ProductTable.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
}
