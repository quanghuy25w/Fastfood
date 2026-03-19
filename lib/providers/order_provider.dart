import 'package:flutter/material.dart';

import '../data/models/order_item_model.dart';
import '../data/models/order_model.dart';
import '../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? OrderRepository();

  final OrderRepository _orderRepository;

  // UI tu dong rebuild khi orders thay doi.
  List<Order> orders = [];

  // Xu ly loading va error.
  bool isLoading = false;
  String? errorMessage;

  int _activeUserId = 0;

  /// Load danh sach Order tu DB.
  Future<void> fetchOrders([int? userId]) async {
    if (userId != null) {
      _activeUserId = userId;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orders = await _orderRepository.getAllOrders(_activeUserId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Them Order khi Checkout.
  Future<void> addOrder(Order order) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final userId = order.userId == 0 ? _activeUserId : order.userId;
      final orderItems = order.orderItems.isNotEmpty
          ? order.orderItems
          : order.items
              .map(
                (item) => OrderItem(
                  productId: item.productId,
                  name: item.name,
                  price: item.price,
                  quantity: item.quantity,
                ),
              )
              .toList();

      await _orderRepository.insertOrder(
        order.copyWith(userId: userId),
        orderItems,
      );

      await fetchOrders(userId);
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<Order?> getOrderById(int id) async {
    try {
      return await _orderRepository.getOrderById(id);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _orderRepository.updateOrder(order);
      await fetchOrders(order.userId);
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _orderRepository.deleteOrder(id);
      await fetchOrders();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
