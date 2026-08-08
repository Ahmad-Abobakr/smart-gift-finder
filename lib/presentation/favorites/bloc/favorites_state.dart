import '../../../domain/entities/product.dart';

abstract class FavoritesState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(this.favorites);

  final List<Product> favorites;
}

class FavoritesError extends FavoritesState {
  const FavoritesError(this.message);

  final String message;
}