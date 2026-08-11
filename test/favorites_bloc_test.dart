import 'package:flutter_test/flutter_test.dart';
import 'package:smart_gift_finder/data/data_sources/local/local_data_source.dart';
import 'package:smart_gift_finder/data/data_sources/remote/firebase_data_source.dart';
import 'package:smart_gift_finder/data/models/product_model.dart';
import 'package:smart_gift_finder/domain/entities/product.dart';
import 'package:smart_gift_finder/presentation/favorites/bloc/favorites_bloc.dart';
import 'package:smart_gift_finder/presentation/favorites/bloc/favorites_event.dart';
import 'package:smart_gift_finder/presentation/favorites/bloc/favorites_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake implementations — no Firebase, no SharedPreferences needed
// ─────────────────────────────────────────────────────────────────────────────

class FakeLocalDataSource extends Fake implements LocalDataSource {
  List<ProductModel> _favorites = [];

  @override
  List<ProductModel> getFavorites() => List.unmodifiable(_favorites);

  @override
  Future<void> saveFavorites(List favorites) async {
    _favorites = List<ProductModel>.from(favorites);
  }

  @override
  Future<void> clearFavorites() async => _favorites = [];
}

class FakeFirebaseDataSource extends Fake implements FirebaseDataSource {
  final List<ProductModel> _storedFavorites = [];
  bool _shouldThrow = false;

  void configureToThrow() => _shouldThrow = true;

  @override
  Future<List<ProductModel>> getFavorites() async {
    if (_shouldThrow) throw Exception('Firebase unavailable');
    return List.unmodifiable(_storedFavorites);
  }

  @override
  Future<void> saveFavorite(ProductModel product) async {
    if (_shouldThrow) throw Exception('Firebase unavailable');
    if (!_storedFavorites.any((p) => p.id == product.id)) {
      _storedFavorites.add(product);
    }
  }

  @override
  Future<void> removeFavorite(int productId) async {
    if (_shouldThrow) throw Exception('Firebase unavailable');
    _storedFavorites.removeWhere((p) => p.id == productId);
  }
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
// FavoritesBloc Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late FakeLocalDataSource fakeLocal;
  late FakeFirebaseDataSource fakeFirebase;
  late FavoritesBloc bloc;

  setUp(() {
    fakeLocal = FakeLocalDataSource();
    fakeFirebase = FakeFirebaseDataSource();
    bloc = FavoritesBloc(
      localDataSource: fakeLocal,
      firebaseDataSource: fakeFirebase,
    );
  });

  tearDown(() => bloc.close());

  group('FavoritesBloc', () {
    test('initial state should be FavoritesInitial', () {
      expect(bloc.state, isA<FavoritesInitial>());
    });

    // ─────────────────────────────────────────────
    // LoadFavorites
    // ─────────────────────────────────────────────

    group('LoadFavorites', () {
      test('should emit [Loading, Loaded(empty)] when local and remote are empty', () async {
        final states = <FavoritesState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadFavorites());

        await Future.delayed(const Duration(milliseconds: 100));
        await sub.cancel();

        expect(states[0], isA<FavoritesLoading>());
        final loaded = states.last as FavoritesLoaded;
        expect(loaded.favorites, isEmpty);
      });

      test('should emit loaded state with local favorites immediately', () async {
        // Prime local storage with product 1
        await fakeLocal.saveFavorites([ProductModel.fromEntity(tProduct1)]);

        final states = <FavoritesState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadFavorites());

        await Future.delayed(const Duration(milliseconds: 100));
        await sub.cancel();

        expect(states, isNotEmpty);

        // At some point a loaded state should contain product 1
        final loadedStates = states.whereType<FavoritesLoaded>().toList();
        expect(loadedStates, isNotEmpty);
        expect(loadedStates.first.favorites.any((p) => p.id == 1), isTrue);
      });

      test('should still emit local data when Firebase throws', () async {
        await fakeLocal.saveFavorites([ProductModel.fromEntity(tProduct1)]);
        fakeFirebase.configureToThrow();

        final states = <FavoritesState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadFavorites());

        await Future.delayed(const Duration(milliseconds: 100));
        await sub.cancel();

        final loadedStates = states.whereType<FavoritesLoaded>().toList();
        expect(loadedStates, isNotEmpty);
        expect(loadedStates.first.favorites.any((p) => p.id == 1), isTrue);
      });
    });

    // ─────────────────────────────────────────────
    // AddFavorite
    // ─────────────────────────────────────────────

    group('AddFavorite', () {
      test('should emit FavoritesLoaded with added product', () async {
        bloc.add(const AddFavorite(tProduct1));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.state, isA<FavoritesLoaded>());
        final loaded = bloc.state as FavoritesLoaded;
        expect(loaded.favorites.any((p) => p.id == tProduct1.id), isTrue);
      });

      test('should add multiple products', () async {
        bloc.add(const AddFavorite(tProduct1));
        await Future.delayed(const Duration(milliseconds: 30));
        bloc.add(const AddFavorite(tProduct2));
        await Future.delayed(const Duration(milliseconds: 50));

        final loaded = bloc.state as FavoritesLoaded;
        expect(loaded.favorites.length, equals(2));
        expect(loaded.favorites.any((p) => p.id == tProduct1.id), isTrue);
        expect(loaded.favorites.any((p) => p.id == tProduct2.id), isTrue);
      });

      test('should NOT duplicate a product already in favorites', () async {
        bloc.add(const AddFavorite(tProduct1));
        await Future.delayed(const Duration(milliseconds: 30));

        bloc.add(const AddFavorite(tProduct1)); // duplicate
        await Future.delayed(const Duration(milliseconds: 30));

        final loaded = bloc.state as FavoritesLoaded;
        expect(
          loaded.favorites.where((p) => p.id == tProduct1.id).length,
          equals(1),
        );
      });

      test('should persist favorites to local storage after add', () async {
        bloc.add(const AddFavorite(tProduct1));
        await Future.delayed(const Duration(milliseconds: 50));

        final saved = fakeLocal.getFavorites();
        expect(saved.any((p) => p.id == tProduct1.id), isTrue);
      });

      test('should emit FavoritesLoaded even when Firebase throws', () async {
        fakeFirebase.configureToThrow();

        bloc.add(const AddFavorite(tProduct1));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.state, isA<FavoritesLoaded>());
        final loaded = bloc.state as FavoritesLoaded;
        expect(loaded.favorites.any((p) => p.id == tProduct1.id), isTrue);
      });
    });

    // ─────────────────────────────────────────────
    // RemoveFavorite
    // ─────────────────────────────────────────────

    group('RemoveFavorite', () {
      test('should remove the correct product from favorites', () async {
        bloc.add(const AddFavorite(tProduct1));
        bloc.add(const AddFavorite(tProduct2));
        await Future.delayed(const Duration(milliseconds: 50));

        bloc.add(const RemoveFavorite(tProduct1.id));
        await Future.delayed(const Duration(milliseconds: 50));

        final loaded = bloc.state as FavoritesLoaded;
        expect(loaded.favorites.any((p) => p.id == tProduct1.id), isFalse);
        expect(loaded.favorites.any((p) => p.id == tProduct2.id), isTrue);
      });

      test('should result in empty list after removing the only product', () async {
        bloc.add(const AddFavorite(tProduct1));
        await Future.delayed(const Duration(milliseconds: 30));

        bloc.add(const RemoveFavorite(tProduct1.id));
        await Future.delayed(const Duration(milliseconds: 50));

        final loaded = bloc.state as FavoritesLoaded;
        expect(loaded.favorites, isEmpty);
      });

      test('removing a non-existent product should have no effect', () async {
        bloc.add(const AddFavorite(tProduct1));
        await Future.delayed(const Duration(milliseconds: 30));

        bloc.add(const RemoveFavorite(9999)); // doesn't exist
        await Future.delayed(const Duration(milliseconds: 30));

        final loaded = bloc.state as FavoritesLoaded;
        expect(loaded.favorites.length, equals(1));
      });

      test('should persist updated list to local storage after removal', () async {
        bloc.add(const AddFavorite(tProduct1));
        bloc.add(const AddFavorite(tProduct2));
        await Future.delayed(const Duration(milliseconds: 50));

        bloc.add(const RemoveFavorite(tProduct1.id));
        await Future.delayed(const Duration(milliseconds: 50));

        final saved = fakeLocal.getFavorites();
        expect(saved.any((p) => p.id == tProduct1.id), isFalse);
        expect(saved.any((p) => p.id == tProduct2.id), isTrue);
      });

      test('should emit FavoritesLoaded even when Firebase throws during remove', () async {
        bloc.add(const AddFavorite(tProduct1));
        await Future.delayed(const Duration(milliseconds: 30));

        fakeFirebase.configureToThrow();

        bloc.add(const RemoveFavorite(tProduct1.id));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.state, isA<FavoritesLoaded>());
        final loaded = bloc.state as FavoritesLoaded;
        expect(loaded.favorites.any((p) => p.id == tProduct1.id), isFalse);
      });
    });
  });
}
