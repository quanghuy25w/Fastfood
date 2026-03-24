import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'database_service.dart';

class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.totalProducts,
    required this.totalOrders,
    required this.revenue,
  });

  final int totalProducts;
  final int totalOrders;
  final double revenue;
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final Random _random = Random();

  Future<User?> getUserById(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    final m = rows.first;
    return User(
      id: m['id'] as int,
      email: m['email'] as String,
      name: m['name'] as String,
      role: (m['role'] as String?) ?? 'user',
      address: (m['address'] as String?) ?? '',
    );
  }
  

  Future<User?> login(String email, String password) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final m = rows.first;
    return User(
      id: m['id'] as int,
      email: m['email'] as String,
      name: m['name'] as String,
      role: (m['role'] as String?) ?? 'user',
      address: (m['address'] as String?) ?? '',
    );
  }

  Future<User> register({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    final db = await DatabaseService.instance.database;
    final id = await db.insert('users', {
      'email': email.trim().toLowerCase(),
      'password': password,
      'name': name.trim(),
      'role': role,
      'address': '',
      'created_at': DateTime.now().toIso8601String(),
    });
    return User(
      id: id,
      email: email.trim().toLowerCase(),
      name: name.trim(),
      role: role,
    );
  }

  Future<void> updateUserAddress(int userId, String addressJson) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'users',
      {'address': addressJson},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'products',
      where: 'is_active = 1',
      orderBy: 'id DESC',
    );
    return rows.map(_productFromMap).toList();
  }

  Future<List<String>> getCategories() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'categories',
      columns: ['name'],
      orderBy: 'name ASC',
    );

    final categories = rows
        .map<String>((row) => row['name'] as String)
        .toList();

    return categories;
  }

  Future<List<Product>> getAdminProducts() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('products', orderBy: 'id DESC');
    return rows.map(_productFromMap).toList();
  }

  Future<int> createProduct({
    required String name,
    required String description,
    required String imageUrl,
    required double price,
    String category = 'Khác',
    bool isFeatured = false,
  }) async {
    final db = await DatabaseService.instance.database;
    return db.insert('products', {
      'name': name.trim(),
      'description': description.trim(),
      'image_url': imageUrl.trim(),
      'category': category.trim().isEmpty ? 'Khác' : category.trim(),
      'price': price,
      'is_featured': isFeatured ? 1 : 0,
      'is_favorite': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String description,
    required String imageUrl,
    required double price,
    required String category,
    bool? isFeatured,
    bool? isFavorite,
    bool? isActive,
  }) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'products',
      {
        'name': name.trim(),
        'description': description.trim(),
        'image_url': imageUrl.trim(),
        'category': category.trim().isEmpty ? 'Khác' : category.trim(),
        'price': price,
        if (isFeatured != null) 'is_featured': isFeatured ? 1 : 0,
        if (isFavorite != null) 'is_favorite': isFavorite ? 1 : 0,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<AdminDashboardSummary> getAdminDashboardSummary() async {
    final db = await DatabaseService.instance.database;
    final products = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;
    final orders = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM orders'),
        ) ??
        0;
    final revenueRow = await db.rawQuery(
      "SELECT COALESCE(SUM(total_amount), 0) AS revenue FROM orders WHERE payment_status = 'paid'",
    );
    final revenue = (revenueRow.first['revenue'] as num?)?.toDouble() ?? 0;
    return AdminDashboardSummary(
      totalProducts: products,
      totalOrders: orders,
      revenue: revenue,
    );
  }

  Future<List<Product>> getFeaturedProducts() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'products',
      where: 'is_featured = 1 AND is_active = 1',
      orderBy: 'id DESC',
    );
    return rows.map(_productFromMap).toList();
  }

  Future<List<OrderItem>> getCartOrderItems(int userId) async {
    final db = await DatabaseService.instance.database;
    final cartId = await _ensureCart(userId);
    final rows = await db.rawQuery('''
      SELECT ci.quantity AS quantity,
             p.id AS id, p.name AS name, p.description AS description,
             p.image_url AS image_url, p.category AS category, p.price AS price,
             p.is_featured AS is_featured, p.is_favorite AS is_favorite
      FROM cart_items ci
      INNER JOIN products p ON p.id = ci.product_id
      WHERE ci.cart_id = ? AND p.is_active = 1
    ''', [cartId]);
    return rows
        .map(
          (r) => OrderItem(
            product: Product(
              id: r['id'] as int,
              name: r['name'] as String,
              description: r['description'] as String,
              imageUrl: r['image_url'] as String,
              category: r['category'] as String,
              price: (r['price'] as num).toDouble(),
              isFeatured: (r['is_featured'] as int) == 1,
              isFavorite: (r['is_favorite'] as int? ?? 0) == 1,
            ),
            quantity: r['quantity'] as int,
          ),
        )
        .toList();
  }

  Future<void> addToCart({
    required int userId,
    required Product product,
    int quantity = 1,
  }) async {
    final db = await DatabaseService.instance.database;
    final cartId = await _ensureCart(userId);
    final existing = await db.query(
      'cart_items',
      where: 'cart_id = ? AND product_id = ?',
      whereArgs: [cartId, product.id],
      limit: 1,
    );
    final safeQty = quantity < 1 ? 1 : quantity;
    if (existing.isEmpty) {
      await db.insert('cart_items', {
        'cart_id': cartId,
        'product_id': product.id,
        'quantity': safeQty,
      });
    } else {
      await db.update(
        'cart_items',
        {'quantity': (existing.first['quantity'] as int) + safeQty},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<void> updateCartQuantity({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final db = await DatabaseService.instance.database;
    final cartId = await _ensureCart(userId);
    if (quantity <= 0) {
      await db.delete(
        'cart_items',
        where: 'cart_id = ? AND product_id = ?',
        whereArgs: [cartId, productId],
      );
      return;
    }
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'cart_id = ? AND product_id = ?',
      whereArgs: [cartId, productId],
    );
  }

  Future<void> removeCartItem({required int userId, required int productId}) async {
    final db = await DatabaseService.instance.database;
    final cartId = await _ensureCart(userId);
    await db.delete(
      'cart_items',
      where: 'cart_id = ? AND product_id = ?',
      whereArgs: [cartId, productId],
    );
  }

  Future<void> clearCart(int userId) async {
    final db = await DatabaseService.instance.database;
    final cartId = await _ensureCart(userId);
    await db.delete('cart_items', where: 'cart_id = ?', whereArgs: [cartId]);
  }

  Future<int> _ensureCart(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'cart',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['id'] as int;
    return db.insert('cart', {
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Order> placeOrder({
    required int userId,
    required List<OrderItem> items,
    required String address,
    required String paymentMethod,
    String storeNote = '',
  }) async {
    final db = await DatabaseService.instance.database;
    if (items.isEmpty) throw Exception('Giỏ hàng trống');
    final cleanAddress = address.trim();
    if (cleanAddress.isEmpty) throw Exception('Địa chỉ giao hàng không hợp lệ');
    if (paymentMethod.isEmpty) throw Exception('Chưa chọn phương thức thanh toán');
    final cleanNote = storeNote.trim();

    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    final order = await db.transaction((txn) async {
      String paymentStatus = 'pending';
      if (paymentMethod != 'COD') {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        final success = _random.nextInt(100) >= 20;
        if (!success) {
          throw Exception('Thanh toán thất bại. Vui lòng thử lại.');
        }
        paymentStatus = 'paid';
      }

      final orderId = await txn.insert('orders', {
        'user_id': userId,
        'total_amount': total,
        'status': paymentMethod == 'COD' ? 'pending' : 'confirmed',
        'payment_status': paymentStatus,
        'address': cleanAddress,
        'payment_method': paymentMethod,
        'store_note': cleanNote,
        'created_at': DateTime.now().toIso8601String(),
      });

      for (final item in items) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
        });
      }

      final cartRow = await txn.query(
        'cart',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (cartRow.isNotEmpty) {
        await txn.delete(
          'cart_items',
          where: 'cart_id = ?',
          whereArgs: [cartRow.first['id']],
        );
      }

      return Order(
        id: orderId,
        userId: userId,
        items: items,
        totalAmount: total,
        status: paymentMethod == 'COD' ? 'pending' : 'confirmed',
        paymentStatus: paymentStatus,
        address: cleanAddress,
        paymentMethod: paymentMethod,
        storeNote: cleanNote,
        createdAt: DateTime.now(),
      );
    });
    return order;
  }

  Future<List<Order>> getOrdersByUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final orders = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    final result = <Order>[];
    for (final o in orders) {
      final rows = await db.rawQuery('''
        SELECT
          oi.quantity,
          oi.price,
          oi.product_name,
          COALESCE(p.id, oi.product_id) AS product_id,
          COALESCE(p.name, oi.product_name) AS product_name_fallback,
          COALESCE(p.description, '') AS description,
          COALESCE(p.image_url, 'https://picsum.photos/seed/deleted/400/300') AS image_url,
          COALESCE(p.category, 'Đã xóa') AS category
        FROM order_items oi
        LEFT JOIN products p ON p.id = oi.product_id
        WHERE oi.order_id = ?
      ''', [o['id']]);

      final items = rows
          .map(
            (r) => OrderItem(
              product: Product(
                id: r['product_id'] as int,
                name: (r['product_name_fallback'] as String).isEmpty
                    ? r['product_name'] as String
                    : r['product_name_fallback'] as String,
                description: r['description'] as String,
                imageUrl: r['image_url'] as String,
                category: r['category'] as String,
                price: (r['price'] as num).toDouble(),
                isFeatured: false,
              ),
              quantity: r['quantity'] as int,
            ),
          )
          .toList();

      result.add(
        Order(
          id: o['id'] as int,
          userId: o['user_id'] as int,
          items: items,
          totalAmount: (o['total_amount'] as num).toDouble(),
          status: o['status'] as String,
          paymentStatus: o['payment_status'] as String,
          address: o['address'] as String,
          paymentMethod: o['payment_method'] as String,
          storeNote: (o['store_note'] as String?)?.trim() ?? '',
          createdAt: DateTime.parse(o['created_at'] as String),
        ),
      );
    }
    return result;
  }

  Product _productFromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      isFeatured: (map['is_featured'] as int) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }
}
