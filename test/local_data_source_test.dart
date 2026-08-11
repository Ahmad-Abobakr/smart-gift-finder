import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_gift_finder/data/data_sources/local/local_data_source.dart';
import 'package:smart_gift_finder/data/models/product_model.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  const tProduct1 = ProductModel(
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

  const tProduct2 = ProductModel(
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

  late LocalDataSource localDataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<LocalDataSource> buildDataSource() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalDataSource(prefs);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LocalDataSource – Favorites
  // ──────────────────────────────────────────────────────────────────────────

  group('LocalDataSource – Favorites', () {
    test('getFavorites should return empty list when nothing is saved', () async {
      localDataSource = await buildDataSource();

      final result = localDataSource.getFavorites();

      expect(result, isEmpty);
    });

    test('saveFavorites then getFavorites should persist and restore the list', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveFavorites([tProduct1, tProduct2]);

      final result = localDataSource.getFavorites();

      expect(result.length, equals(2));
      expect(result[0].id, equals(tProduct1.id));
      expect(result[0].title, equals(tProduct1.title));
      expect(result[1].id, equals(tProduct2.id));
      expect(result[1].title, equals(tProduct2.title));
    });

    test('saveFavorites with a single product should persist correctly', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveFavorites([tProduct1]);

      final result = localDataSource.getFavorites();

      expect(result.length, equals(1));
      expect(result.first.id, equals(1));
      expect(result.first.price, equals(999.99));
      expect(result.first.brand, equals('Apple'));
    });

    test('saveFavorites with empty list should clear persisted favorites', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveFavorites([tProduct1]);
      await localDataSource.saveFavorites([]);

      final result = localDataSource.getFavorites();

      expect(result, isEmpty);
    });

    test('clearFavorites should remove persisted favorites', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveFavorites([tProduct1, tProduct2]);
      await localDataSource.clearFavorites();

      final result = localDataSource.getFavorites();

      expect(result, isEmpty);
    });

    test('overwriting favorites should replace the old list', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveFavorites([tProduct1]);
      await localDataSource.saveFavorites([tProduct2]);

      final result = localDataSource.getFavorites();

      expect(result.length, equals(1));
      expect(result.first.id, equals(tProduct2.id));
    });

    test('getFavorites should correctly restore all product fields', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveFavorites([tProduct1]);

      final result = localDataSource.getFavorites();
      final restored = result.first;

      expect(restored.id, equals(tProduct1.id));
      expect(restored.title, equals(tProduct1.title));
      expect(restored.description, equals(tProduct1.description));
      expect(restored.price, equals(tProduct1.price));
      expect(restored.rating, equals(tProduct1.rating));
      expect(restored.thumbnail, equals(tProduct1.thumbnail));
      expect(restored.images, equals(tProduct1.images));
      expect(restored.category, equals(tProduct1.category));
      expect(restored.stock, equals(tProduct1.stock));
      expect(restored.brand, equals(tProduct1.brand));
      expect(restored.tags, equals(tProduct1.tags));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // LocalDataSource – Cart
  // ──────────────────────────────────────────────────────────────────────────

  group('LocalDataSource – Cart', () {
    test('getCart should return empty map when nothing is saved', () async {
      localDataSource = await buildDataSource();

      final result = localDataSource.getCart();

      expect(result, isEmpty);
    });

    test('saveCart then getCart should persist and restore the cart', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveCart({
        tProduct1: 2,
        tProduct2: 1,
      });

      final result = localDataSource.getCart();

      expect(result.length, equals(2));
      expect(result[tProduct1], equals(2));
      expect(result[tProduct2], equals(1));
    });

    test('saveCart with quantity of 3 should restore quantity correctly', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveCart({tProduct1: 3});

      final result = localDataSource.getCart();

      expect(result.length, equals(1));
      expect(result.values.first, equals(3));
    });

    test('clearCart should remove persisted cart', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveCart({tProduct1: 2});
      await localDataSource.clearCart();

      final result = localDataSource.getCart();

      expect(result, isEmpty);
    });

    test('overwriting cart should replace old entries', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveCart({tProduct1: 5});
      await localDataSource.saveCart({tProduct2: 1});

      final result = localDataSource.getCart();

      expect(result.length, equals(1));
      expect(result.keys.first.id, equals(tProduct2.id));
      expect(result.values.first, equals(1));
    });

    test('getCart should correctly restore product fields', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveCart({tProduct1: 2});

      final result = localDataSource.getCart();
      final product = result.keys.first;

      expect(product.id, equals(tProduct1.id));
      expect(product.title, equals(tProduct1.title));
      expect(product.price, equals(tProduct1.price));
      expect(product.brand, equals(tProduct1.brand));
      expect(product.category, equals(tProduct1.category));
      expect(product.stock, equals(tProduct1.stock));
    });

    test('getCart should handle corrupted JSON gracefully', () async {
      // Manually inject bad JSON
      SharedPreferences.setMockInitialValues({'cart': 'NOT_VALID_JSON'});
      final prefs = await SharedPreferences.getInstance();
      localDataSource = LocalDataSource(prefs);

      expect(
        () => localDataSource.getCart(),
        throwsA(isA<FormatException>()),
      );
    });

    test('saveCart with empty map should result in empty getCart', () async {
      localDataSource = await buildDataSource();

      await localDataSource.saveCart({tProduct1: 1});
      await localDataSource.saveCart({});

      final result = localDataSource.getCart();

      expect(result, isEmpty);
    });
  });
}
