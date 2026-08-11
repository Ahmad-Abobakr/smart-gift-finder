import 'package:flutter_test/flutter_test.dart';
import 'package:smart_gift_finder/data/data_sources/local/local_data_source.dart';
import 'package:smart_gift_finder/data/data_sources/remote/firebase_data_source.dart';
import 'package:smart_gift_finder/data/models/product_model.dart';
import 'package:smart_gift_finder/domain/entities/product.dart';
import 'package:smart_gift_finder/presentation/cart/bloc/cart_bloc.dart';
import 'package:smart_gift_finder/presentation/cart/bloc/cart_event.dart';
import 'package:smart_gift_finder/presentation/cart/bloc/cart_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake implementations — no Firebase, no SharedPreferences needed
// ─────────────────────────────────────────────────────────────────────────────

class FakeLocalDataSource extends Fake implements LocalDataSource {
  Map<ProductModel, int> _cart = {};

  @override
  Map<ProductModel, int> getCart() => Map.unmodifiable(_cart);

  @override
  Future<void> saveCart(Map<ProductModel, int> cartItems) async {
    _cart = Map<ProductModel, int>.from(cartItems);
  }

  @override
  Future<void> clearCart() async => _cart = {};

  // Favorites methods — unused in CartBloc but required by interface
  @override
  List<ProductModel> getFavorites() => [];

  @override
  Future<void> saveFavorites(List favorites) async {}

  @override
  Future<void> clearFavorites() async {}
}

class FakeFirebaseDataSource extends Fake implements FirebaseDataSource {
  final Map<ProductModel, int> _cart = {};
  bool _shouldThrow = false;

  void configureToThrow() => _shouldThrow = true;

  @override
  Future<Map<ProductModel, int>> getCart() async {
    if (_shouldThrow) throw Exception('Firebase unavailable');
    return Map.unmodifiable(_cart);
  }

  @override
  Future<void> saveCartItem(ProductModel product, int quantity) async {
    if (_shouldThrow) throw Exception('Firebase unavailable');
    _cart[product] = quantity;
  }

  @override
  Future<void> removeCartItem(int productId) async {
    if (_shouldThrow) throw Exception('Firebase unavailable');
    _cart.removeWhere((p, _) => p.id == productId);
  }

  @override
  Future<void> clearCart() async {
    if (_shouldThrow) throw Exception('Firebase unavailable');
    _cart.clear();
  }

  // Unused favorites methods
  @override
  Future<List<ProductModel>> getFavorites() async => [];

  @override
  Future<void> saveFavorite(ProductModel product) async {}

  @override
  Future<void> removeFavorite(int productId) async {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Test data
// ─────────────────────────────────────────────────────────────────────────────

const tProduct1 = Product(
  id: 1,
  title: 'iPhone 15',
  description: 'A great phone',
  price: 999.99,
  rating: 4.5,
  thumbnail: '',
  images: [],
  category: 'smartphones',
  stock: 50,
  brand: 'Apple',
  tags: [],
);

const tProduct2 = Product(
  id: 2,
  title: 'Samsung Watch',
  description: 'A smart watch',
  price: 299.99,
  rating: 4.2,
  thumbnail: '',
  images: [],
  category: 'accessories',
  stock: 30,
  brand: 'Samsung',
  tags: [],
);

// ─────────────────────────────────────────────────────────────────────────────
// CartBloc Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late FakeLocalDataSource fakeLocal;
  late FakeFirebaseDataSource fakeFirebase;
  late CartBloc bloc;

  setUp(() {
    fakeLocal = FakeLocalDataSource();
    fakeFirebase = FakeFirebaseDataSource();
    bloc = CartBloc(
      localDataSource: fakeLocal,
      firebaseDataSource: fakeFirebase,
    );
  });

  tearDown(() => bloc.close());

  group('CartBloc', () {
    test('initial state should be CartInitial', () {
      expect(bloc.state, isA<CartInitial>());
    });

    // ─────────────────────────────────────────────
    // LoadCart
    // ─────────────────────────────────────────────

    group('LoadCart', () {
      test('should emit [Loading, Loaded(empty)] when cart is empty', () async {
        final states = <CartState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadCart());

        await Future.delayed(const Duration(milliseconds: 100));
        await sub.cancel();

        expect(states[0], isA<CartLoading>());
        final loaded = states.last as CartLoaded;
        expect(loaded.cartItems, isEmpty);
      });

      test('should emit loaded state with local cart immediately', () async {
        await fakeLocal.saveCart({ProductModel.fromEntity(tProduct1): 2});

        final states = <CartState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadCart());

        await Future.delayed(const Duration(milliseconds: 100));
        await sub.cancel();

        final loadedStates = states.whereType<CartLoaded>().toList();
        expect(loadedStates, isNotEmpty);
        final cartKeys = loadedStates.first.cartItems.keys.map((p) => p.id).toList();
        expect(cartKeys, contains(tProduct1.id));
      });

      test('should still emit local data when Firebase throws', () async {
        await fakeLocal.saveCart({ProductModel.fromEntity(tProduct1): 1});
        fakeFirebase.configureToThrow();

        final states = <CartState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadCart());

        await Future.delayed(const Duration(milliseconds: 100));
        await sub.cancel();

        final loadedStates = states.whereType<CartLoaded>().toList();
        expect(loadedStates, isNotEmpty);
        final cartKeys = loadedStates.first.cartItems.keys.map((p) => p.id).toList();
        expect(cartKeys, contains(tProduct1.id));
      });
    });

    // ─────────────────────────────────────────────
    // AddToCart
    // ─────────────────────────────────────────────

    group('AddToCart', () {
      test('should add product with quantity 1', () async {
        bloc.add(const AddToCart(tProduct1));
        await Future.delayed(const Duration(milliseconds: 50));

        final loaded = bloc.state as CartLoaded;
        final entry = loaded.cartItems.entries.firstWhere((e) => e.key.id == tProduct1.id);
        expect(entry.value, equals(1));
      });

      test('should increment quantity when same product is added twice', () async {
        bloc.add(const AddToCart(tProduct1));
        await Future.delayed(const Duration(milliseconds: 30));
        bloc.add(const AddToCart(tProduct1));
        await Future.delayed(const Duration(milliseconds: 50));

        final loaded = bloc.state as CartLoaded;
        final entry = loaded.cartItems.entries.firstWhere((e) => e.key.id == tProduct1.id);
        expect(entry.value, equals(2));
      });

  test('should add different products independently', () async {
    bloc.add(const AddToCart(tProduct1));
    await Future.delayed(const Duration(milliseconds: 30));

    bloc.add(const AddToCart(tProduct2));
    await Future.delayed(const Duration(milliseconds: 50));

    final loaded = bloc.state as CartLoaded;
    expect(loaded.cartItems.length, equals(2));
  });

  test('should persist cart to local storage', () async {
    bloc.add(const AddToCart(tProduct1));
    await Future.delayed(const Duration(milliseconds: 50));

    final saved = fakeLocal.getCart();

    expect(
      saved.keys.any((key) => key.id == tProduct1.id),
      isTrue,
      reason: 'should contain product',
    );
  });

  test('should emit CartLoaded even when Firebase throws', () async {
    fakeFirebase.configureToThrow();

    bloc.add(const AddToCart(tProduct1));
    await Future.delayed(const Duration(milliseconds: 50));

    expect(bloc.state, isA<CartLoaded>());
  });
});

// ─────────────────────────────────────────────
// RemoveFromCart
// ─────────────────────────────────────────────

group('RemoveFromCart', () {
  test('should remove the correct product', () async {
    bloc.add(const AddToCart(tProduct1));
    bloc.add(const AddToCart(tProduct2));
    await Future.delayed(const Duration(milliseconds: 50));

    bloc.add(RemoveFromCart(tProduct1.id));
    await Future.delayed(const Duration(milliseconds: 50));

    final loaded = bloc.state as CartLoaded;

    expect(
      loaded.cartItems.keys.any((p) => p.id == tProduct1.id),
      isFalse,
    );

    expect(
      loaded.cartItems.keys.any((p) => p.id == tProduct2.id),
      isTrue,
    );
  });

  test('removing non-existent product should have no effect', () async {
    bloc.add(const AddToCart(tProduct1));
    await Future.delayed(const Duration(milliseconds: 30));

    bloc.add(const RemoveFromCart(9999));
    await Future.delayed(const Duration(milliseconds: 30));

    final loaded = bloc.state as CartLoaded;
    expect(loaded.cartItems.length, equals(1));
  });
});

// ─────────────────────────────────────────────
// IncreaseQuantity
// ─────────────────────────────────────────────

group('IncreaseQuantity', () {
  test('should increase quantity by 1', () async {
    bloc.add(const AddToCart(tProduct1));
    await Future.delayed(const Duration(milliseconds: 30));

    bloc.add(IncreaseQuantity(tProduct1.id));
    await Future.delayed(const Duration(milliseconds: 50));

    final loaded = bloc.state as CartLoaded;

    final qty = loaded.cartItems.entries
        .firstWhere((e) => e.key.id == tProduct1.id)
        .value;

    expect(qty, equals(2));
  });

  test('increasing non-existent product should have no effect', () async {
    bloc.add(const AddToCart(tProduct1));
    await Future.delayed(const Duration(milliseconds: 30));

    bloc.add(const IncreaseQuantity(9999));
    await Future.delayed(const Duration(milliseconds: 30));

    expect(bloc.state, isA<CartLoaded>());
  });
});

// ─────────────────────────────────────────────
// DecreaseQuantity
// ─────────────────────────────────────────────

group('DecreaseQuantity', () {
  test('should decrease quantity by 1 when quantity > 1', () async {
    bloc.add(const AddToCart(tProduct1));
    bloc.add(const AddToCart(tProduct1));
    await Future.delayed(const Duration(milliseconds: 50));

    bloc.add(DecreaseQuantity(tProduct1.id));
    await Future.delayed(const Duration(milliseconds: 50));

    final loaded = bloc.state as CartLoaded;

    final qty = loaded.cartItems.entries
        .firstWhere((e) => e.key.id == tProduct1.id)
        .value;

    expect(qty, equals(1));
  });

  test(
    'should remove product when quantity reaches 1 and decrease is triggered',
    () async {
      bloc.add(const AddToCart(tProduct1));
      await Future.delayed(const Duration(milliseconds: 30));

      bloc.add(DecreaseQuantity(tProduct1.id));
      await Future.delayed(const Duration(milliseconds: 50));

      final loaded = bloc.state as CartLoaded;

      expect(
        loaded.cartItems.keys.any((p) => p.id == tProduct1.id),
        isFalse,
      );
    },
  );

  test(
    'should emit CartLoaded even when Firebase throws during decrease',
    () async {
      bloc.add(const AddToCart(tProduct1));
      bloc.add(const AddToCart(tProduct1));
      await Future.delayed(const Duration(milliseconds: 50));

      fakeFirebase.configureToThrow();

      bloc.add(DecreaseQuantity(tProduct1.id));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<CartLoaded>());
    },
  );
});

// ─────────────────────────────────────────────
// ClearCart
// ─────────────────────────────────────────────

group('ClearCart', () {
  test('should emit CartLoaded with empty map', () async {
    bloc.add(const AddToCart(tProduct1));
    bloc.add(const AddToCart(tProduct2));
    await Future.delayed(const Duration(milliseconds: 50));

    bloc.add(const ClearCart());
    await Future.delayed(const Duration(milliseconds: 50));

    final loaded = bloc.state as CartLoaded;
    expect(loaded.cartItems, isEmpty);
  });

  test('should clear local storage', () async {
    bloc.add(const AddToCart(tProduct1));
    await Future.delayed(const Duration(milliseconds: 30));

    bloc.add(const ClearCart());
    await Future.delayed(const Duration(milliseconds: 50));

    final saved = fakeLocal.getCart();
    expect(saved, isEmpty);
  });

  test(
    'should emit CartLoaded even when Firebase throws during clear',
    () async {
      bloc.add(const AddToCart(tProduct1));
      await Future.delayed(const Duration(milliseconds: 30));

      fakeFirebase.configureToThrow();

      bloc.add(const ClearCart());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<CartLoaded>());

      final loaded = bloc.state as CartLoaded;
      expect(loaded.cartItems, isEmpty);
    },
  );

    test('clearing an already empty cart should emit CartLoaded with empty map', () async {
    bloc.add(const ClearCart());
    await Future.delayed(const Duration(milliseconds: 50));

    expect(bloc.state, isA<CartLoaded>());
    final loaded = bloc.state as CartLoaded;
    expect(loaded.cartItems, isEmpty);
  });
}); // ClearCart group

}); // CartBloc group

} // main