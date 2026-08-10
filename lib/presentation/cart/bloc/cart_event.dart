import '../../../domain/entities/product.dart';

abstract class CartEvent {
  const CartEvent();
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class AddToCart extends CartEvent {
  const AddToCart(this.product);

  final Product product;
}

class RemoveFromCart extends CartEvent {
  const RemoveFromCart(this.productId);

  final int productId;
}

class IncreaseQuantity extends CartEvent {
  const IncreaseQuantity(this.productId);

  final int productId;
}

class DecreaseQuantity extends CartEvent {
  const DecreaseQuantity(this.productId);

  final int productId;
}

class ClearCart extends CartEvent {
  const ClearCart();
}