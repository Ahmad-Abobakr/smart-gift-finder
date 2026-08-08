import '../../../domain/entities/product.dart';

abstract class CartState {
  const CartState();
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  const CartLoaded(this.cartItems);

  final Map<Product, int> cartItems;
}

class CartError extends CartState {
  const CartError(this.message);

  final String message;
}