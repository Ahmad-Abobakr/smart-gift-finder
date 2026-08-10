import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Product> products;
  final List<Category> categories;
  final bool isSearching;

  const HomeLoaded({
    required this.products,
    required this.categories,
    this.isSearching = false,
  });

  HomeLoaded copyWith({
    List<Product>? products,
    List<Category>? categories,
    bool? isSearching,
  }) {
    return HomeLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [products, categories, isSearching];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
