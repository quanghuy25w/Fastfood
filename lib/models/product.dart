class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double price;
  final bool isFeatured;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    this.isFeatured = false,
    this.isFavorite = false,
  });
}
