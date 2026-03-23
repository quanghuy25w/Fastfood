import 'product.dart';

class Order {
  final int id;
  final int userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String address;
  final String paymentMethod;
  
  final String storeNote;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.address,
    required this.paymentMethod,
    this.storeNote = '',
    required this.createdAt,
  });
}

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });
}
