import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<OrderItem> _items = [];
  int? _userId;

  List<OrderItem> get orderItems => List.unmodifiable(_items);
  int get totalCount => _items.fold<int>(0, (s, e) => s + e.quantity);

  Future<void> load(int userId) async {
    _userId = userId;
    _items = await ApiService.instance.getCartOrderItems(userId);
    notifyListeners();
  }

  void clearMemory() {
    _userId = null;
    _items = [];
    notifyListeners();
  }

  Future<void> addProduct(Product product, {int quantity = 1}) async {
    if (_userId == null) return;
    await ApiService.instance.addToCart(
      userId: _userId!,
      product: product,
      quantity: quantity,
    );
    await load(_userId!);
  }

  Future<void> setQuantity(int productId, int quantity) async {
    if (_userId == null) return;
    await ApiService.instance.updateCartQuantity(
      userId: _userId!,
      productId: productId,
      quantity: quantity,
    );
    await load(_userId!);
  }

  Future<void> removeLine(int productId) async {
    if (_userId == null) return;
    await ApiService.instance.removeCartItem(userId: _userId!, productId: productId);
    await load(_userId!);
  }
}
