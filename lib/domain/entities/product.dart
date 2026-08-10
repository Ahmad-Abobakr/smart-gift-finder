import 'package:equatable/equatable.dart';

class Product extends Equatable {
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

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        rating,
        thumbnail,
        images,
        category,
        stock,
        brand,
        tags,
      ];
}
