import 'package:flutter/material.dart';

import '../data/models/cart_item_model.dart';
import '../data/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartRepository? repository})
      : _repository = repository ?? CartRepository();

  // Manage cart state and sync with SQLite repository.
  final CartRepository _repository;

  List<CartItem> _items = [];
  int? _activeUserId;
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get items => _items;
  int? get activeUserId => _activeUserId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculate total amount from all cart items.
  double get totalPrice => _items.fold(0, (total, item) => total + item.subtotal);

  Future<void> loadCart(int userId) async {
    await _runTask(
      task: () async {
        _activeUserId = userId;
        _items = await _repository.getAllCartItems(userId);
      },
      errorPrefix: 'Load cart failed',
    );
  }

  Future<void> addToCart(CartItem item) async {
    final userId = item.userId ?? _activeUserId;
    if (userId == null) {
      _errorMessage = 'userId is required to add cart item';
      notifyListeners();
      return;
    }

    await _runTask(
      task: () async {
        final index = _items.indexWhere((element) => element.productId == item.productId);

        if (index != -1) {
          final current = _items[index];
          final updated = current.copyWith(
            userId: userId,
            quantity: current.quantity + item.quantity,
          );

          if (current.id == null) {
            await _repository.insertCartItem(updated);
          } else {
            await _repository.updateCartItem(updated);
          }
        } else {
          await _repository.insertCartItem(item.copyWith(userId: userId));
        }

        await _reloadCart(userId);
      },
      errorPrefix: 'Add to cart failed',
    );
  }

  Future<void> updateCartItem(CartItem item) async {
    final userId = item.userId ?? _activeUserId;
    if (userId == null) {
      _errorMessage = 'userId is required to update cart item';
      notifyListeners();
      return;
    }

    await _runTask(
      task: () async {
        await _repository.updateCartItem(item.copyWith(userId: userId));
        await _reloadCart(userId);
      },
      errorPrefix: 'Update cart item failed',
    );
  }

  Future<void> removeCartItem(int id) async {
    final userId = _activeUserId ?? _findUserIdByItemId(id);
    if (userId == null) {
      _errorMessage = 'userId is required to remove cart item';
      notifyListeners();
      return;
    }

    await _runTask(
      task: () async {
        await _repository.deleteCartItem(id);
        await _reloadCart(userId);
      },
      errorPrefix: 'Remove cart item failed',
    );
  }

  Future<void> clearCart(int userId) async {
    await _runTask(
      task: () async {
        await _repository.clearCart(userId);
        _activeUserId = userId;
        _items = [];
      },
      errorPrefix: 'Clear cart failed',
    );
  }

  // Compatibility helpers for current UI flows.
  Future<void> addItem(CartItem item) => addToCart(item);

  Future<void> increaseQuantity(int productId) async {
    final index = _items.indexWhere((element) => element.productId == productId);
    if (index == -1) {
      return;
    }

    final current = _items[index];
    await updateCartItem(current.copyWith(quantity: current.quantity + 1));
  }

  Future<void> decreaseQuantity(int productId) async {
    final index = _items.indexWhere((element) => element.productId == productId);
    if (index == -1) {
      return;
    }

    final current = _items[index];
    if (current.quantity <= 1) {
      if (current.id != null) {
        await removeCartItem(current.id!);
      } else {
        _items.removeAt(index);
        notifyListeners();
      }
      return;
    }

    await updateCartItem(current.copyWith(quantity: current.quantity - 1));
  }

  Future<void> removeItem(int productId) async {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index == -1) {
      return;
    }

    final current = _items[index];
    if (current.id != null) {
      await removeCartItem(current.id!);
    } else {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> _runTask({
    required Future<void> Function() task,
    required String errorPrefix,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await task();
    } catch (e) {
      _errorMessage = '$errorPrefix: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _reloadCart(int userId) async {
    _activeUserId = userId;
    _items = await _repository.getAllCartItems(userId);
  }

  int? _findUserIdByItemId(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return null;
    }

    return _items[index].userId;
  }
}
