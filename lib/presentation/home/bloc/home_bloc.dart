import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ProductRepository productRepository;

  // نحتفظ بالفئات محليًا عشان نرجعها لما المستخدم يمسح نص البحث
  List<Category> _cachedCategories = [];

  HomeBloc({required this.productRepository}) : super(const HomeLoading()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final List<Product> products =
          await productRepository.getProducts(skip: 0, limit: 20);
      final List<Category> categories = await productRepository.getCategories();
      _cachedCategories = categories;

      emit(HomeLoaded(products: products, categories: categories));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
      SearchProducts event, Emitter<HomeState> emit) async {
    if (event.query.trim().isEmpty) {
      // لو المستخدم مسح البحث، ارجع للمنتجات الأساسية
      add(const LoadHomeData());
      return;
    }
    emit(const HomeLoading());
    try {
      final results = await productRepository.searchProducts(event.query);
      emit(HomeLoaded(
        products: results,
        categories: _cachedCategories,
        isSearching: true,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
