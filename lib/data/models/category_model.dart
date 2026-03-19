import '../database/tables.dart';

/// Model dai dien cho danh muc san pham (Category).
///
/// Dung de phan loai va loc san pham trong app FastFood.
/// Mapping voi bang categories trong SQLite.
/// Ho tro hien thi UI va filter logic trong ProductProvider.
class Category {
  final int? id;
  final String name;
  final String image;
  final DateTime? createdAt;

  const Category({
    this.id,
    required this.name,
    required this.image,
    this.createdAt,
  });

  /// Chuyen Map tu SQLite thanh object Category.
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: _toInt(map[CategoryTable.id]),
      name: map[CategoryTable.name]?.toString() ?? '',
      image: map[CategoryTable.image]?.toString() ?? '',
      createdAt: _toDateTime(map[CategoryTable.createdAt]),
    );
  }

  /// Chuyen object Category thanh Map de insert/update SQLite.
  ///
  /// Neu [createdAt] la null, truong created_at se bi bo qua de DB
  /// co the ap dung DEFAULT CURRENT_TIMESTAMP.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      CategoryTable.id: id,
      CategoryTable.name: name,
      CategoryTable.image: image,
    };

    if (createdAt != null) {
      map[CategoryTable.createdAt] = createdAt!.toIso8601String();
    }

    return map;
  }

  /// Tao ban sao Category, thuong dung khi cap nhat du lieu trong UI/provider.
  Category copyWith({
    int? id,
    String? name,
    String? image,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
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

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.tryParse(value.toString());
  }
}
