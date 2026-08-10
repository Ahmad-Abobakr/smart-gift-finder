import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_gift_finder/data/data_sources/local/local_data_source.dart';
import 'package:smart_gift_finder/data/data_sources/remote/firebase_data_source.dart';
import 'package:smart_gift_finder/data/models/product_model.dart';
import 'package:smart_gift_finder/domain/entities/product.dart';
import 'package:smart_gift_finder/presentation/cart/bloc/cart_bloc.dart';
import 'package:smart_gift_finder/presentation/cart/bloc/cart_event.dart';
import 'package:smart_gift_finder/presentation/cart/bloc/cart_state.dart';

class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockFirebaseDataSource extends Mock implements FirebaseDataSource {}

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

  const tProduct2 = Product(
    id: 2,
    title: 'Samsung Galaxy Watch',
    description: 'A smart watch',
    price: 299.99,
    rating: 4.2,
    thumbnail: 'https://example.com/thumb2.jpg',
    images: ['https://example.com/img2.jpg'],
    category: 'accessories',
    stock: 30,
    brand: 'Samsung',
    tags: ['watch', 'wearable'],
  );

  const tProductModel = ProductModel(
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

  const tProductModel2 = ProductModel(
    id: 2,
    title: 'Samsung Galaxy Watch',
    description: 'A smart watch',
    price: 299.99,
    rating: 4.2,
    thumbnail: 'https://example.com/thumb2.jpg',
    images: ['https://example.com/img2.jpg'],
    category: 'accessories',
    stock: 30,
    brand: 'Samsung',
    tags: ['watch', 'wearable'],
  );

  setUpAll(() {
    registerFallbackValue(tProductModel);
    registerFallbackValue(const <ProductModel, int>{});
  });

  late MockLocalDataSource localDataSource;
  late MockFirebaseDataSource firebaseDataSource;
  late CartBloc cartBloc;

  setUp(() {
    localDataSource = MockLocalDataSource();
    firebaseDataSource = MockFirebaseDataSource();
    cartBloc = CartBloc(
      localDataSource: localDataSource,
      firebaseDataSource: firebaseDataSource,
    );
  });

  tearDown(() {
    cartBloc.close();
  });

  Future<List<CartState>> runEvent(CartEvent event) async {
    final states = <CartState>[];
    final subscription = cartBloc.stream.listen(states.add);
    cartBloc.add(event);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await subscription.cancel();
    return states;
  }

  void stubLocalCart(Map<ProductModel, int> cart) {
    when(() => localDataSource.getCart()).thenReturn(cart);
    when(() => localDataSource.saveCart(any())).thenAnswer((_) async {});
  }

  void stubRemoteUnavailable() {
    when(() => firebaseDataSource.getCart())
        .thenThrow(Exception('Firebase unavailable'));
  }

  void stubRemoteCart(Map<ProductModel, int> cart) {
    when(() => firebaseDataSource.getCart()).thenAnswer((_) async => cart);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Initial state
  // ──────────────────────────────────────────────────────────────────────────

  group('initial state', () {
    test('should be CartInitial', () {
      expect(cartBloc.state, isA<CartInitial>());
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // LoadCart
  // ──────────────────────────────────────────────────────────────────────────

  group('LoadCart', () {
    test('should emit loading then loaded with empty cart', () async {
      stubLocalCart({});
      stubRemoteUnavailable();

      final states = await runEvent(const LoadCart());

      expect(states, hasLength(2));
      expect(states[0], isA<CartLoading>());
      expect((states[1] as CartLoaded).cartItems, isEmpty);
    });

    test('should load cart from the local data source', () async {
      stubLocalCart({tProductModel: 2});
      stubRemoteUnavailable();

      final states = await runEvent(const LoadCart());

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct: 2});
    });

    test('should not overwrite the local cart when Firebase is unavailable',
        () async {
      stubLocalCart({tProductModel: 2});
      stubRemoteUnavailable();

      await runEvent(const LoadCart());

      verifyNever(() => localDataSource.saveCart(any()));
    });

    test('should load the remote cart and persist it locally', () async {
      stubLocalCart({tProductModel: 1});
      stubRemoteCart({tProductModel2: 3});

      final states = await runEvent(const LoadCart());

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct2: 3});
      verify(() => localDataSource.saveCart({tProductModel2: 3})).called(1);
    });

    test('should emit CartError when the local data source fails',
        () async {
      when(() => localDataSource.getCart())
          .thenThrow(Exception('Corrupted data'));

      final states = await runEvent(const LoadCart());

      expect(states.first, isA<CartLoading>());
      expect(states.last, isA<CartError>());
      expect((states.last as CartError).message, contains('Corrupted data'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // AddToCart
  // ──────────────────────────────────────────────────────────────────────────

  group('AddToCart', () {
    test('should add a new product with quantity 1', () async {
      stubLocalCart({});
      stubRemoteUnavailable();
      when(() => firebaseDataSource.saveCartItem(any(), any()))
          .thenAnswer((_) async {});

      final states = await runEvent(const AddToCart(tProduct));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct: 1});
      verify(() => localDataSource.saveCart({tProductModel: 1})).called(1);
      verify(() => firebaseDataSource.saveCartItem(tProductModel, 1))
          .called(1);
    });

    test('should increment the quantity when the same product is added again',
        () async {
      stubLocalCart({tProductModel: 1});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => firebaseDataSource.saveCartItem(any(), any()))
          .thenAnswer((_) async {});

      final states = await runEvent(const AddToCart(tProduct));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct: 2});
      verify(() => localDataSource.saveCart({tProductModel: 2})).called(1);
    });

    test('should still emit loaded when Firebase sync fails', () async {
      stubLocalCart({});
      stubRemoteUnavailable();
      when(() => firebaseDataSource.saveCartItem(any(), any()))
          .thenThrow(Exception('offline'));

      final states = await runEvent(const AddToCart(tProduct));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct: 1});
    });

    test('should emit CartError when the local persistence fails', () async {
      stubLocalCart({});
      stubRemoteUnavailable();
      when(() => localDataSource.saveCart(any()))
          .thenThrow(Exception('disk full'));

      final states = await runEvent(const AddToCart(tProduct));

      expect(states.last, isA<CartError>());
      expect((states.last as CartError).message, contains('disk full'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // RemoveFromCart
  // ──────────────────────────────────────────────────────────────────────────

  group('RemoveFromCart', () {
    test('should remove an existing product', () async {
      stubLocalCart({tProductModel: 2, tProductModel2: 1});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => firebaseDataSource.removeCartItem(any()))
          .thenAnswer((_) async {});

      final states = await runEvent(const RemoveFromCart(1));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct2: 1});
      verify(() => localDataSource.saveCart({tProductModel2: 1})).called(1);
      verify(() => firebaseDataSource.removeCartItem(1)).called(1);
    });

    test('should keep the cart unchanged for an unknown product id',
        () async {
      stubLocalCart({tProductModel: 2});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => firebaseDataSource.removeCartItem(any()))
          .thenAnswer((_) async {});

      final states = await runEvent(const RemoveFromCart(999));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct: 2});
    });

    test('should still remove locally when Firebase sync fails', () async {
      stubLocalCart({tProductModel: 2});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => firebaseDataSource.removeCartItem(any()))
          .thenThrow(Exception('offline'));

      final states = await runEvent(const RemoveFromCart(1));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // IncreaseQuantity
  // ──────────────────────────────────────────────────────────────────────────

  group('IncreaseQuantity', () {
    test('should increase the quantity of an existing product', () async {
      stubLocalCart({tProductModel: 1});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => firebaseDataSource.saveCartItem(any(), any()))
          .thenAnswer((_) async {});

      final states = await runEvent(const IncreaseQuantity(1));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct: 2});
      verify(() => localDataSource.saveCart({tProductModel: 2})).called(1);
      verify(() => firebaseDataSource.saveCartItem(tProductModel, 2))
          .called(1);
    });

    test('should not emit any state for an unknown product id', () async {
      stubLocalCart({tProductModel: 1});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());

      final states = <CartState>[];
      final subscription = cartBloc.stream.listen(states.add);
      cartBloc.add(const IncreaseQuantity(999));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(states, isEmpty);
    });

    test('should emit CartError when the local persistence fails', () async {
      stubLocalCart({tProductModel: 1});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => localDataSource.saveCart(any()))
          .thenThrow(Exception('disk full'));

      final states = await runEvent(const IncreaseQuantity(1));

      expect(states.last, isA<CartError>());
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // DecreaseQuantity
  // ──────────────────────────────────────────────────────────────────────────

  group('DecreaseQuantity', () {
    test('should decrease the quantity when it is above 1', () async {
      stubLocalCart({tProductModel: 2});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => firebaseDataSource.saveCartItem(any(), any()))
          .thenAnswer((_) async {});

      final states = await runEvent(const DecreaseQuantity(1));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, {tProduct: 1});
      verify(() => localDataSource.saveCart({tProductModel: 1})).called(1);
      verify(() => firebaseDataSource.saveCartItem(tProductModel, 1))
          .called(1);
    });

    test('should remove the product when the quantity reaches 1', () async {
      stubLocalCart({tProductModel: 1});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => firebaseDataSource.removeCartItem(any()))
          .thenAnswer((_) async {});

      final states = await runEvent(const DecreaseQuantity(1));

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, isEmpty);
      verify(() => localDataSource.saveCart({})).called(1);
      verify(() => firebaseDataSource.removeCartItem(1)).called(1);
    });

    test('should not emit any state for an unknown product id', () async {
      stubLocalCart({tProductModel: 1});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());

      final states = <CartState>[];
      final subscription = cartBloc.stream.listen(states.add);
      cartBloc.add(const DecreaseQuantity(999));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(states, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // ClearCart
  // ──────────────────────────────────────────────────────────────────────────

  group('ClearCart', () {
    test('should clear the cart and emit empty loaded state', () async {
      stubLocalCart({tProductModel: 2});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => localDataSource.clearCart()).thenAnswer((_) async {});
      when(() => firebaseDataSource.clearCart()).thenAnswer((_) async {});

      final states = await runEvent(const ClearCart());

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, isEmpty);
      verify(() => localDataSource.clearCart()).called(1);
      verify(() => firebaseDataSource.clearCart()).called(1);
    });

    test('should still emit empty state when Firebase sync fails', () async {
      stubLocalCart({tProductModel: 2});
      stubRemoteUnavailable();
      await runEvent(const LoadCart());
      when(() => localDataSource.clearCart()).thenAnswer((_) async {});
      when(() => firebaseDataSource.clearCart())
          .thenThrow(Exception('offline'));

      final states = await runEvent(const ClearCart());

      final loaded = states.last as CartLoaded;
      expect(loaded.cartItems, isEmpty);
    });

    test('should emit CartError when the local clearing fails', () async {
      when(() => localDataSource.clearCart())
          .thenThrow(Exception('disk full'));

      final states = await runEvent(const ClearCart());

      expect(states.last, isA<CartError>());
      expect((states.last as CartError).message, contains('disk full'));
    });
  });
}
