import 'package:dio/dio.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

/// المصدر الوحيد اللي بيتكلم مع DummyJSON API فعليًا
class ApiDataSource {
  final Dio _dio;

  ApiDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://dummyjson.com',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  /// فئات DummyJSON اللي بتصلح "هدية" فعليًا (عطور، مجوهرات، ساعات، إلخ)
  /// أي فئة مش موجودة هنا (بقالة، أثاث، أدوات مطبخ...) بتتستبعد تلقائيًا
  static const Set<String> _giftFriendlyCategories = {
    'fragrances',
    'skin-care',
    'skincare',
    'beauty',
    'jewellery',
    'womens-jewellery',
    'mens-watches',
    'womens-watches',
    'sunglasses',
    'womens-bags',
    'womens-shoes',
    'mens-shoes',
    'mens-shirts',
    'tops',
    'womens-dresses',
    'mobile-accessories',
    'sports-accessories',
    'smartphones',
    'laptops',
    'tablets',
    'headphones',
  };

  bool _isGiftFriendly(String category) =>
      _giftFriendlyCategories.contains(category.toLowerCase());

  /// جلب المنتجات المناسبة كهدايا فقط (مستبعد منها البقالة والأثاث ولوازم المطبخ)
  /// بنجيب دفعة أكبر من DummyJSON عشان بعد الفلترة يفضل عندنا عدد كافي
  Future<List<ProductModel>> getProducts({int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {'skip': skip, 'limit': 100},
      );
      final List<dynamic> data = response.data['products'] as List<dynamic>;
      final all = data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .where((p) => _isGiftFriendly(p.category))
          .toList();
      return all.take(limit).toList();
    } on DioException catch (e) {
      throw Exception('فشل تحميل المنتجات: ${e.message}');
    }
  }

  /// جلب قائمة الفئات المناسبة كهدايا فقط
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/products/categories');
      final List<dynamic> data = response.data as List<dynamic>;
      final all = data.map((e) {
        if (e is Map<String, dynamic>) {
          return CategoryModel.fromJson(e);
        }
        // بعض إصدارات الـ API القديمة كانت بترجع List<String> مباشرة
        return CategoryModel(slug: e.toString(), name: e.toString());
      }).toList();
      return all.where((c) => _isGiftFriendly(c.slug)).toList();
    } on DioException catch (e) {
      throw Exception('فشل تحميل الفئات: ${e.message}');
    }
  }

  /// البحث عن منتجات باسم/كلمة معينة (مقصور على الفئات المناسبة كهدايا)
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        '/products/search',
        queryParameters: {'q': query},
      );
      final List<dynamic> data = response.data['products'] as List<dynamic>;
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .where((p) => _isGiftFriendly(p.category))
          .toList();
    } on DioException catch (e) {
      throw Exception('فشل البحث: ${e.message}');
    }
  }
}
