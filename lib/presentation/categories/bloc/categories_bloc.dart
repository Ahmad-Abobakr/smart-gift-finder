import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/remote/api_data_source.dart';

import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc
    extends Bloc<CategoriesEvent, CategoriesState> {
  final ApiDataSource apiDataSource;

  CategoriesBloc(this.apiDataSource)
      : super(CategoriesInitial()) {
    on<LoadCategories>(_loadCategories);
    on<SelectCategory>(_selectCategory);
  }

  Future<void> _loadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());

    try {
      final categoryModels = await apiDataSource.getCategories();
      final categories =
          categoryModels.map((c) => c.slug).toList();

      emit(
        CategoriesLoaded(
          categories: categories,
          products: [],
        ),
      );
    } catch (e) {
      emit(
        CategoriesError(e.toString()),
      );
    }
  }

  Future<void> _selectCategory(
    SelectCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      final productModels =
          await apiDataSource.getProductsByCategory(
        event.category,
      );

      final products = productModels
          .map((product) => product.toEntity())
          .toList();

      final currentState = state;

      List<String> categories = [];

      if (currentState is CategoriesLoaded) {
        categories = currentState.categories;
      }

      emit(
        CategoriesLoaded(
          categories: categories,
          products: products,
          selectedCategory: event.category,
        ),
      );
    } catch (e) {
      emit(
        CategoriesError(e.toString()),
      );
    }
  }
}