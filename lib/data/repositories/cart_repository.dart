import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  // Ket noi SQLite de thao tac bang cart_items.
  final DatabaseHelper _dbHelper = DatabaseHelper();

  static const String _tableCartItems = 'cart_items';
  static const String _colId = 'id';
  static const String _colUserId = 'user_id';
  static const String _colProductId = 'product_id';
  static const String _colName = 'name';
  static const String _colPrice = 'price';
  static const String _colQuantity = 'quantity';
  static const String _colImage = 'image';

  // CRUD gio hang phuc vu CartProvider.
  // Tra ve du lieu typed CartItem.
  Future<List<CartItem>> getAllCartItems(int userId) async {
    try {
      final db = await _dbHelper.database;
      await _ensureCartTable(db);

      final maps = await db.query(
        _tableCartItems,
        where: '$_colUserId = ?',
        whereArgs: [userId],
        orderBy: '$_colId DESC',
      );

      return maps.map(CartItem.fromMap).toList();
    } catch (e) {
      throw Exception('Get cart items failed: $e');
    }
  }

  Future<void> insertCartItem(CartItem item) async {
    try {
      final db = await _dbHelper.database;
      await _ensureCartTable(db);

      final map = item.toMap()..remove(_colId);
      await db.insert(
        _tableCartItems,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Insert cart item failed: $e');
    }
  }

  Future<void> updateCartItem(CartItem item) async {
    try {
      if (item.id == null) {
        throw Exception('Cart item id is required for update');
      }

      final db = await _dbHelper.database;
      await _ensureCartTable(db);

      final map = item.toMap()..remove(_colId);
      await db.update(
        _tableCartItems,
        map,
        where: '$_colId = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      throw Exception('Update cart item failed: $e');
    }
  }

  Future<void> deleteCartItem(int id) async {
    try {
      final db = await _dbHelper.database;
      await _ensureCartTable(db);

      await db.delete(
        _tableCartItems,
        where: '$_colId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Delete cart item failed: $e');
    }
  }

  Future<void> clearCart(int userId) async {
    try {
      final db = await _dbHelper.database;
      await _ensureCartTable(db);

      await db.delete(
        _tableCartItems,
        where: '$_colUserId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Clear cart failed: $e');
    }
  }

  Future<void> _ensureCartTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableCartItems (
        $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_colUserId INTEGER NOT NULL,
        $_colProductId INTEGER NOT NULL,
        $_colName TEXT NOT NULL,
        $_colPrice REAL NOT NULL,
        $_colQuantity INTEGER NOT NULL,
        $_colImage TEXT
      )
    ''');
  }
}
