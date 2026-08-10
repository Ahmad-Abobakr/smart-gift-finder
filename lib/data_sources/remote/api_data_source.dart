import 'package:dio/dio.dart';

import '../../data/models/product_model.dart';

class ApiDataSource {
  final Dio dio;

  ApiDataSource({
    Dio? dio,
  }) : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://dummyjson.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final response = await dio.get('/products/categories');

      final data = response.data;

      if (data is List) {
        return data.map((category) {
          if (category is String) {
            return category;
          }

          if (category is Map) {
            return category['slug']?.toString() ??
                category['name']?.toString() ??
                '';
          }

          return '';
        }).where((category) => category.isNotEmpty).toList();
      }

      throw Exception('Invalid categories response');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load categories: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Failed to load categories: $e',
      );
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(
    String category,
  ) async {
    try {
      final response = await dio.get(
        '/products/category/$category',
      );

      final data = response.data;

      if (data is Map && data['products'] is List) {
        return (data['products'] as List)
            .map(
              (json) => ProductModel.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }

      throw Exception('Invalid products response');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load category products: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Failed to load category products: $e',
      );
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(
    String query,
  ) async {
    try {
      final response = await dio.get(
        '/products/search',
        queryParameters: {
          'q': query,
        },
      );

      final data = response.data;

      if (data is Map && data['products'] is List) {
        return (data['products'] as List)
            .map(
              (json) => ProductModel.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }

      throw Exception('Invalid search response');
    } on DioException catch (e) {
      throw Exception(
        'Failed to search products: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Failed to search products: $e',
      );
    }
  }

  // Get one product by ID
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await dio.get(
        '/products/$id',
      );

      if (response.data is Map) {
        return ProductModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      throw Exception('Invalid product response');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load product: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Failed to load product: $e',
      );
    }
  }
}