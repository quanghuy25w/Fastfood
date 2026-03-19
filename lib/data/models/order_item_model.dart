class OrderItem {
  const OrderItem({
    this.id,
    this.orderId,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final int? id;
  final int? orderId;
  final int productId;
  final String name;
  final double price;
  final int quantity;

  double get subtotal => price * quantity;

  /// Chuyen Map SQLite -> OrderItem typed object.
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: _toInt(map['id']),
      orderId: _toInt(map['order_id']),
      productId: _toInt(map['product_id']) ?? 0,
      name: map['name']?.toString() ?? '',
      price: _toDouble(map['price']),
      quantity: _toInt(map['quantity']) ?? 1,
    );
  }

  /// Chuyen OrderItem -> Map de insert/update SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? name,
    double? price,
    int? quantity,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
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
