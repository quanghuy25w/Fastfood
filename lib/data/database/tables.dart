class ProductTable {
  ProductTable._();

  static const String tableName = 'products';

  static const String id = 'id';
  static const String name = 'name';
  static const String price = 'price';
  static const String description = 'description';
  static const String image = 'image';

  static const String categoryId = 'category_id';
  static const String createdAt = 'created_at';
}

class CategoryTable {
  CategoryTable._();

  static const String tableName = 'categories';

  static const String id = 'id';
  static const String name = 'name';
  static const String image = 'image';
  static const String createdAt = 'created_at';
}
