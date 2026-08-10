import '../../../domain/entities/product.dart';

abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<String> categories;
  final List<Product> products;
  final String? selectedCategory;

  CategoriesLoaded({
    required this.categories,
    required this.products,
    this.selectedCategory,
  });
}

class CategoriesError extends CategoriesState {
  final String message;

  CategoriesError(this.message);
}