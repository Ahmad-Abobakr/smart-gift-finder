class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.images,
    required this.category,
    required this.stock,
    required this.brand,
    required this.tags,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String thumbnail;
  final List<String> images;
  final String category;
  final int stock;
  final String brand;
  final List<String> tags;

  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    double? rating,
    String? thumbnail,
    List<String>? images,
    String? category,
    int? stock,
    String? brand,
    List<String>? tags,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
      tags: tags ?? this.tags,
    );
  }
}
