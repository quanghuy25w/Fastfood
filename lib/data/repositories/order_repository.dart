import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  // Ket noi SQLite de thao tac bang orders/order_items.
  final DatabaseHelper _dbHelper = DatabaseHelper();

  static const String _tableOrders = 'orders';
  static const String _tableOrderItems = 'order_items';

  static const String _orderId = 'id';
  static const String _orderUserId = 'user_id';
  static const String _orderTotalAmount = 'total_amount';
  static const String _orderAddressId = 'address_id';
  static const String _orderAddressLabel = 'address_label';
  static const String _orderAddressFullAddress = 'address_full_address';
  static const String _orderCreatedAt = 'created_at';

  static const String _itemId = 'id';
  static const String _itemOrderId = 'order_id';
  static const String _itemProductId = 'product_id';
  static const String _itemName = 'name';
  static const String _itemPrice = 'price';
  static const String _itemQuantity = 'quantity';

  // CRUD don hang va cac item.
  // Phuc vu OrderProvider va man hinh lich su/chi tiet.
  // Transaction dam bao du lieu nhat quan.
  Future<List<Order>> getAllOrders(int userId) async {
    try {
      final db = await _dbHelper.database;
      await _ensureTables(db);

      final rows = await db.query(
        _tableOrders,
        where: '$_orderUserId = ?',
        whereArgs: [userId],
        orderBy: '$_orderId DESC',
      );

      return rows.map((row) => _mapOrderRow(row)).toList();
    } catch (e) {
      throw Exception('Get all orders failed: $e');
    }
  }

  Future<Order?> getOrderById(int orderId) async {
    try {
      final db = await _dbHelper.database;
      await _ensureTables(db);

      final orderRows = await db.query(
        _tableOrders,
        where: '$_orderId = ?',
        whereArgs: [orderId],
        limit: 1,
      );

      if (orderRows.isEmpty) {
        return null;
      }

      final itemRows = await db.query(
        _tableOrderItems,
        where: '$_itemOrderId = ?',
        whereArgs: [orderId],
        orderBy: '$_itemId ASC',
      );

      final orderItems = itemRows.map(OrderItem.fromMap).toList();
      return _mapOrderRow(orderRows.first, orderItems: orderItems);
    } catch (e) {
      throw Exception('Get order by id failed: $e');
    }
  }

  Future<void> insertOrder(Order order, List<OrderItem> items) async {
    try {
      final db = await _dbHelper.database;
      await _ensureTables(db);

      await db.transaction((txn) async {
        final orderId = await txn.insert(_tableOrders, {
          _orderUserId: order.userId,
          _orderTotalAmount: order.totalAmount,
          _orderAddressId: order.address.id,
          _orderAddressLabel: order.address.label,
          _orderAddressFullAddress: order.address.fullAddress,
          _orderCreatedAt: order.createdAt,
        });

        for (final item in items) {
          await txn.insert(_tableOrderItems, {
            _itemOrderId: orderId,
            _itemProductId: item.productId,
            _itemName: item.name,
            _itemPrice: item.price,
            _itemQuantity: item.quantity,
          });
        }
      });
    } catch (e) {
      throw Exception('Insert order failed: $e');
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      if (order.id == null) {
        throw Exception('Order id is required for update');
      }

      final db = await _dbHelper.database;
      await _ensureTables(db);

      await db.update(
        _tableOrders,
        {
          _orderUserId: order.userId,
          _orderTotalAmount: order.totalAmount,
          _orderAddressId: order.address.id,
          _orderAddressLabel: order.address.label,
          _orderAddressFullAddress: order.address.fullAddress,
          _orderCreatedAt: order.createdAt,
        },
        where: '$_orderId = ?',
        whereArgs: [order.id],
      );
    } catch (e) {
      throw Exception('Update order failed: $e');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      final db = await _dbHelper.database;
      await _ensureTables(db);

      await db.transaction((txn) async {
        await txn.delete(
          _tableOrderItems,
          where: '$_itemOrderId = ?',
          whereArgs: [orderId],
        );

        await txn.delete(
          _tableOrders,
          where: '$_orderId = ?',
          whereArgs: [orderId],
        );
      });
    } catch (e) {
      throw Exception('Delete order failed: $e');
    }
  }

  Future<void> _ensureTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableOrders (
        $_orderId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_orderUserId INTEGER NOT NULL,
        $_orderTotalAmount REAL NOT NULL,
        $_orderAddressId INTEGER,
        $_orderAddressLabel TEXT,
        $_orderAddressFullAddress TEXT,
        $_orderCreatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableOrderItems (
        $_itemId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_itemOrderId INTEGER NOT NULL,
        $_itemProductId INTEGER NOT NULL,
        $_itemName TEXT NOT NULL,
        $_itemPrice REAL NOT NULL,
        $_itemQuantity INTEGER NOT NULL,
        FOREIGN KEY($_itemOrderId) REFERENCES $_tableOrders($_orderId)
      )
    ''');
  }

  Order _mapOrderRow(
    Map<String, dynamic> row, {
    List<OrderItem> orderItems = const [],
  }) {
    final typedItems = List<OrderItem>.from(orderItems);

    final cartItems = typedItems
        .map(
          (item) => CartItem(
            id: item.id,
            productId: item.productId,
            name: item.name,
            price: item.price,
            quantity: item.quantity,
          ),
        )
        .toList();

    return Order(
      id: _toInt(row[_orderId]),
      userId: _toInt(row[_orderUserId]) ?? 0,
      totalAmount: _toDouble(row[_orderTotalAmount]),
      address: Address(
        id: _toInt(row[_orderAddressId]) ?? 0,
        label: row[_orderAddressLabel]?.toString() ?? '',
        fullAddress: row[_orderAddressFullAddress]?.toString() ?? '',
      ),
      createdAt: row[_orderCreatedAt]?.toString() ?? '',
      items: cartItems,
      orderItems: typedItems,
    );
  }

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}
