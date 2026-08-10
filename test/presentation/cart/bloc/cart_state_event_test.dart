import 'package:flutter_test/flutter_test.dart';
import 'package:smart_gift_finder/domain/entities/product.dart';
import 'package:smart_gift_finder/presentation/cart/bloc/cart_event.dart';
import 'package:smart_gift_finder/presentation/cart/bloc/cart_state.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  const tProduct = Product(
    id: 1,
    title: 'iPhone 15',
    description: 'A great phone',
    price: 999.99,
    rating: 4.5,
    thumbnail: 'https://example.com/thumb1.jpg',
    images: ['https://example.com/img1.jpg'],
    category: 'smartphones',
    stock: 50,
    brand: 'Apple',
    tags: ['phone'],
  );

  // ──────────────────────────────────────────────────────────────────────────
  // CartState
  // ──────────────────────────────────────────────────────────────────────────

  group('CartState', () {
    test('CartInitial should be a CartState', () {
      expect(const CartInitial(), isA<CartState>());
    });

    test('CartLoading should be a CartState', () {
      expect(const CartLoading(), isA<CartState>());
    });

    test('CartLoaded should store the provided cart items', () {
      final state = CartLoaded({tProduct: 2});

      expect(state.cartItems, {tProduct: 2});
    });

    test('CartLoaded should support an empty cart', () {
      const state = CartLoaded({});

      expect(state.cartItems, isEmpty);
    });

    test('CartError should store the provided message', () {
      const state = CartError('Something went wrong');

      expect(state.message, 'Something went wrong');
    });

    test('state classes should be distinct types', () {
      expect(const CartLoading(), isNot(isA<CartLoaded>()));
      expect(const CartLoading(), isNot(isA<CartError>()));
      expect(const CartError('x'), isNot(isA<CartLoaded>()));
      expect(const CartLoaded({}), isNot(isA<CartError>()));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // CartEvent
  // ──────────────────────────────────────────────────────────────────────────

  group('CartEvent', () {
    test('AddToCart should carry the product', () {
      const event = AddToCart(tProduct);

      expect(event.product, tProduct);
    });

    test('RemoveFromCart should carry the product id', () {
      const event = RemoveFromCart(7);

      expect(event.productId, 7);
    });

    test('IncreaseQuantity should carry the product id', () {
      const event = IncreaseQuantity(7);

      expect(event.productId, 7);
    });

    test('DecreaseQuantity should carry the product id', () {
      const event = DecreaseQuantity(7);

      expect(event.productId, 7);
    });

    test('LoadCart and ClearCart should be constructible', () {
      expect(const LoadCart(), isA<CartEvent>());
      expect(const ClearCart(), isA<CartEvent>());
    });
  });
}
