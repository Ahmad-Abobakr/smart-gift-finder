import 'package:flutter_test/flutter_test.dart';
import 'package:smart_gift_finder/data/models/product_model.dart';
import 'package:smart_gift_finder/domain/entities/product.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  const tProductJson = {
    'id': 1,
    'title': 'iPhone 15',
    'description': 'A great phone',
    'price': 999.99,
    'rating': 4.5,
    'thumbnail': 'https://example.com/thumb.jpg',
    'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
    'category': 'smartphones',
    'stock': 50,
    'brand': 'Apple',
    'tags': ['phone', 'apple'],
  };

  const tProductModel = ProductModel(
    id: 1,
    title: 'iPhone 15',
    description: 'A great phone',
    price: 999.99,
    rating: 4.5,
    thumbnail: 'https://example.com/thumb.jpg',
    images: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
    category: 'smartphones',
    stock: 50,
    brand: 'Apple',
    tags: ['phone', 'apple'],
  );

  const tProduct = Product(
    id: 1,
    title: 'iPhone 15',
    description: 'A great phone',
    price: 999.99,
    rating: 4.5,
    thumbnail: 'https://example.com/thumb.jpg',
    images: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
    category: 'smartphones',
    stock: 50,
    brand: 'Apple',
    tags: ['phone', 'apple'],
  );

  // ──────────────────────────────────────────────────────────────────────────
  // ProductModel Tests
  // ──────────────────────────────────────────────────────────────────────────

  group('ProductModel', () {
    group('fromJson', () {
      test('should parse all fields correctly', () {
        final result = ProductModel.fromJson(tProductJson);

        expect(result.id, equals(1));
        expect(result.title, equals('iPhone 15'));
        expect(result.description, equals('A great phone'));
        expect(result.price, equals(999.99));
        expect(result.rating, equals(4.5));
        expect(result.thumbnail, equals('https://example.com/thumb.jpg'));
        expect(result.images,
            equals(['https://example.com/img1.jpg', 'https://example.com/img2.jpg']));
        expect(result.category, equals('smartphones'));
        expect(result.stock, equals(50));
        expect(result.brand, equals('Apple'));
        expect(result.tags, equals(['phone', 'apple']));
      });

      test('should use defaults when fields are null', () {
        final result = ProductModel.fromJson({});

        expect(result.id, equals(0));
        expect(result.title, equals(''));
        expect(result.description, equals(''));
        expect(result.price, equals(0.0));
        expect(result.rating, equals(0.0));
        expect(result.thumbnail, equals(''));
        expect(result.images, isEmpty);
        expect(result.category, equals(''));
        expect(result.stock, equals(0));
        expect(result.brand, equals(''));
        expect(result.tags, isEmpty);
      });

      test('should handle integer price as double', () {
        final json = {...tProductJson, 'price': 500, 'rating': 4};
        final result = ProductModel.fromJson(json);

        expect(result.price, equals(500.0));
        expect(result.rating, equals(4.0));
        expect(result.price, isA<double>());
        expect(result.rating, isA<double>());
      });
    });

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final result = tProductModel.toJson();

        expect(result['id'], equals(1));
        expect(result['title'], equals('iPhone 15'));
        expect(result['description'], equals('A great phone'));
        expect(result['price'], equals(999.99));
        expect(result['rating'], equals(4.5));
        expect(result['thumbnail'], equals('https://example.com/thumb.jpg'));
        expect(result['images'],
            equals(['https://example.com/img1.jpg', 'https://example.com/img2.jpg']));
        expect(result['category'], equals('smartphones'));
        expect(result['stock'], equals(50));
        expect(result['brand'], equals('Apple'));
        expect(result['tags'], equals(['phone', 'apple']));
      });

      test('fromJson → toJson should be lossless round-trip', () {
        final model = ProductModel.fromJson(tProductJson);
        final json = model.toJson();
        final result = ProductModel.fromJson(json);

        expect(result, equals(model));
      });
    });

    group('toEntity', () {
      test('should convert ProductModel to Product entity correctly', () {
        final result = tProductModel.toEntity();

        expect(result.id, equals(tProductModel.id));
        expect(result.title, equals(tProductModel.title));
        expect(result.description, equals(tProductModel.description));
        expect(result.price, equals(tProductModel.price));
        expect(result.rating, equals(tProductModel.rating));
        expect(result.thumbnail, equals(tProductModel.thumbnail));
        expect(result.images, equals(tProductModel.images));
        expect(result.category, equals(tProductModel.category));
        expect(result.stock, equals(tProductModel.stock));
        expect(result.brand, equals(tProductModel.brand));
        expect(result.tags, equals(tProductModel.tags));
      });

      test('should return a Product instance', () {
        final result = tProductModel.toEntity();
        expect(result, isA<Product>());
      });
    });

    group('fromEntity', () {
      test('should convert Product entity to ProductModel correctly', () {
        final result = ProductModel.fromEntity(tProduct);

        expect(result.id, equals(tProduct.id));
        expect(result.title, equals(tProduct.title));
        expect(result.price, equals(tProduct.price));
        expect(result.category, equals(tProduct.category));
      });

      test('fromEntity → toEntity should be lossless round-trip', () {
        final model = ProductModel.fromEntity(tProduct);
        final entity = model.toEntity();

        expect(entity, equals(tProduct));
      });
    });

    group('equality', () {
      test('two models with the same id should be equal', () {
        const model1 = ProductModel(
          id: 1,
          title: 'A',
          description: '',
          price: 0,
          rating: 0,
          thumbnail: '',
          images: [],
          category: '',
          stock: 0,
          brand: '',
          tags: [],
        );
        const model2 = ProductModel(
          id: 1,
          title: 'B',
          description: 'different',
          price: 999,
          rating: 5,
          thumbnail: 'x',
          images: [],
          category: 'cat',
          stock: 10,
          brand: 'Brand',
          tags: [],
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('two models with different ids should NOT be equal', () {
        const model1 = ProductModel(
          id: 1, title: '', description: '', price: 0, rating: 0,
          thumbnail: '', images: [], category: '', stock: 0, brand: '', tags: [],
        );
        const model2 = ProductModel(
          id: 2, title: '', description: '', price: 0, rating: 0,
          thumbnail: '', images: [], category: '', stock: 0, brand: '', tags: [],
        );

        expect(model1, isNot(equals(model2)));
      });
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Product Entity Tests
  // ──────────────────────────────────────────────────────────────────────────

  group('Product', () {
    group('copyWith', () {
      test('should create a copy with updated title', () {
        final updated = tProduct.copyWith(title: 'iPhone 16');

        expect(updated.title, equals('iPhone 16'));
        expect(updated.id, equals(tProduct.id));
        expect(updated.price, equals(tProduct.price));
      });

      test('should create a copy with updated price', () {
        final updated = tProduct.copyWith(price: 1299.0);

        expect(updated.price, equals(1299.0));
        expect(updated.title, equals(tProduct.title));
      });

      test('should keep original values when no args are provided', () {
        final copy = tProduct.copyWith();

        expect(copy.id, equals(tProduct.id));
        expect(copy.title, equals(tProduct.title));
        expect(copy.description, equals(tProduct.description));
        expect(copy.price, equals(tProduct.price));
        expect(copy.rating, equals(tProduct.rating));
        expect(copy.category, equals(tProduct.category));
        expect(copy.stock, equals(tProduct.stock));
        expect(copy.brand, equals(tProduct.brand));
      });

      test('should update multiple fields at once', () {
        final updated = tProduct.copyWith(
          title: 'Samsung S25',
          brand: 'Samsung',
          price: 899.0,
          stock: 100,
        );

        expect(updated.title, equals('Samsung S25'));
        expect(updated.brand, equals('Samsung'));
        expect(updated.price, equals(899.0));
        expect(updated.stock, equals(100));
        expect(updated.id, equals(tProduct.id));
      });
    });

    group('equality', () {
      test('products with the same id should be equal', () {
        const product1 = Product(
          id: 1, title: 'A', description: '', price: 0, rating: 0,
          thumbnail: '', images: [], category: '', stock: 0, brand: '', tags: [],
        );
        const product2 = Product(
          id: 1, title: 'Completely Different', description: 'nope', price: 999, rating: 5,
          thumbnail: 'x', images: [], category: 'cat', stock: 5, brand: 'B', tags: [],
        );

        expect(product1, equals(product2));
        expect(product1.hashCode, equals(product2.hashCode));
      });

      test('products with different ids should NOT be equal', () {
        const product1 = Product(
          id: 1, title: '', description: '', price: 0, rating: 0,
          thumbnail: '', images: [], category: '', stock: 0, brand: '', tags: [],
        );
        const product2 = Product(
          id: 2, title: '', description: '', price: 0, rating: 0,
          thumbnail: '', images: [], category: '', stock: 0, brand: '', tags: [],
        );

        expect(product1, isNot(equals(product2)));
      });

      test('hashCode should be based on id', () {
        const product = Product(
          id: 42, title: '', description: '', price: 0, rating: 0,
          thumbnail: '', images: [], category: '', stock: 0, brand: '', tags: [],
        );

        expect(product.hashCode, equals(42.hashCode));
      });
    });
  });
}
