import '../database/tables.dart';

class Product {
  final int? id;
  final String name;
  final double price;
  final String? description;
  final String? image;
  final int? categoryId;
  final String? createdAt;

  const Product({
    this.id,
    required this.name,
    required this.price,
    this.description,
    this.image,
    this.categoryId,
    this.createdAt,
  });

  /// Chuyen Map -> Object Product.
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: _toInt(map[ProductTable.id]),
      name: map[ProductTable.name]?.toString() ?? '',
      price: _toDouble(map[ProductTable.price]),
      description: map[ProductTable.description]?.toString(),
      image: map[ProductTable.image]?.toString(),
      categoryId: _toInt(map[ProductTable.categoryId]),
      createdAt: map[ProductTable.createdAt]?.toString(),
    );
  }

  /// Chuyen Object Product -> Map de insert/update SQLite.
  Map<String, dynamic> toMap() {
    return {
      ProductTable.id: id,
      ProductTable.name: name,
      ProductTable.price: price,
      ProductTable.description: description,
      ProductTable.image: image,
      ProductTable.categoryId: categoryId,
      ProductTable.createdAt: createdAt,
    };
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
