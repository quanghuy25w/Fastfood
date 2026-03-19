import 'address_model.dart';
import 'cart_item_model.dart';
import 'order_item_model.dart';

class Order {
  const Order({
    this.id,
    this.userId = 0,
    this.items = const [],
    this.orderItems = const [],
    required this.totalAmount,
    required this.address,
    required this.createdAt,
  });

  final int? id;
  final int userId;
  final List<CartItem> items;
  final List<OrderItem> orderItems;
  final double totalAmount;
  final Address address;
  final String createdAt;

  Order copyWith({
    int? id,
    int? userId,
    List<CartItem>? items,
    List<OrderItem>? orderItems,
    double? totalAmount,
    Address? address,
    String? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      orderItems: orderItems ?? this.orderItems,
      totalAmount: totalAmount ?? this.totalAmount,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
