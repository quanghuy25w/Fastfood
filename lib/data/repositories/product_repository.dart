import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/product_model.dart';

class ProductRepository {
  // Ket noi SQLite de thao tac bang products.
  final DatabaseHelper _dbHelper = DatabaseHelper();

  static const String _tableProducts = 'products';
  static const String _colId = 'id';

  // CRUD san pham phuc vu ProductProvider.
  // Tra ve du lieu typed Product.
  Future<List<Product>> getAllProducts() async {
    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableProducts,
        orderBy: '$_colId DESC',
      );

      return maps.map(Product.fromMap).toList();
    } catch (e) {
      throw Exception('Get all products failed: $e');
    }
  }

  Future<Product?> getProductById(int id) async {
    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableProducts,
        where: '$_colId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return Product.fromMap(maps.first);
    } catch (e) {
      throw Exception('Get product by id failed: $e');
    }
  }

  Future<void> insertProduct(Product product) async {
    try {
      final Database db = await _dbHelper.database;
      final map = product.toMap()..remove(_colId);

      await db.insert(
        _tableProducts,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Insert product failed: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw Exception('Product id is required for update');
      }

      final Database db = await _dbHelper.database;
      final map = product.toMap()..remove(_colId);
      final affectedRows = await db.update(
        _tableProducts,
        map,
        where: '$_colId = ?',
        whereArgs: [product.id],
      );

      if (affectedRows == 0) {
        throw Exception('Product not found');
      }
    } catch (e) {
      throw Exception('Update product failed: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final Database db = await _dbHelper.database;
      await db.delete(
        _tableProducts,
        where: '$_colId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Delete product failed: $e');
    }
  }
}
