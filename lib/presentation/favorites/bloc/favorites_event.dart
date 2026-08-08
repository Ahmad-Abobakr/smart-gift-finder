import '../../../domain/entities/product.dart';

abstract class FavoritesEvent {
  const FavoritesEvent();
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class AddFavorite extends FavoritesEvent {
  const AddFavorite(this.product);

  final Product product;
}

class RemoveFavorite extends FavoritesEvent {
  const RemoveFavorite(this.productId);

  final int productId;
}