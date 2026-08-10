import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import '../data_sources/remote/api_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiDataSource apiDataSource;

  ProductRepositoryImpl({required this.apiDataSource});

  @override
  Future<List<Product>> getProducts({int skip = 0, int limit = 20}) async {
    final models = await apiDataSource.getProducts(skip: skip, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    final models = await apiDataSource.getCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final models = await apiDataSource.searchProducts(query);
    return models.map((m) => m.toEntity()).toList();
  }
}
