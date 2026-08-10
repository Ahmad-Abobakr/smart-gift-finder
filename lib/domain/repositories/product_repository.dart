import '../entities/product.dart';
import '../entities/category.dart';

/// واجهة مجردة (contract) — الـ presentation layer بيتكلم مع دي بس
/// وميعرفش حاجة عن DummyJSON ولا Dio ولا أي تفاصيل تانية
abstract class ProductRepository {
  Future<List<Product>> getProducts({int skip = 0, int limit = 20});
  Future<List<Category>> getCategories();
  Future<List<Product>> searchProducts(String query);
}
