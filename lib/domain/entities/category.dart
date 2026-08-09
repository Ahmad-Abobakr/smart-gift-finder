import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String slug;
  final String name;
  final int? itemCount;

  const Category({
    required this.slug,
    required this.name,
    this.itemCount,
  });

  @override
  List<Object?> get props => [slug, name, itemCount];
}
