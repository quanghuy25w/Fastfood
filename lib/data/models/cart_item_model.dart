class CartItem {
  const CartItem({
    this.id,
    this.userId,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  final int? id;
  final int? userId;
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  /// Tinh toan tong tien cua tung item trong gio.
  double get subtotal => price * quantity;

  /// Chuyen Map SQLite -> CartItem typed object.
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: _toInt(map['id']),
      userId: _toInt(map['user_id']),
      productId: _toInt(map['product_id']) ?? 0,
      name: map['name']?.toString() ?? '',
      price: _toDouble(map['price']),
      quantity: _toInt(map['quantity']) ?? 1,
      image: map['image']?.toString(),
    );
  }

  /// Chuyen CartItem -> Map de insert/update SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }

  CartItem copyWith({
    int? id,
    int? userId,
    int? productId,
    String? name,
    double? price,
    int? quantity,
    String? image,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
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
