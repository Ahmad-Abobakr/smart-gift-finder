import '../../domain/entities/category.dart';

class CategoryModel {
  final String slug;
  final String name;
  final String? url;

  CategoryModel({required this.slug, required this.name, this.url});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString(),
    );
  }

  Category toEntity({int? itemCount}) {
    return Category(
      slug: slug,
      name: name,
      itemCount: itemCount,
    );
  }
}
