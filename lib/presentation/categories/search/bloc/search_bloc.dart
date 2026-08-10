import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/data_sources/remote/api_data_source.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc
    extends Bloc<SearchEvent, SearchState> {
  final ApiDataSource apiDataSource;

  SearchBloc(this.apiDataSource)
      : super(SearchInitial()) {
    on<SearchRequested>(_searchProducts);
  }

  Future<void> _searchProducts(
    SearchRequested event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final productModels =
          await apiDataSource.searchProducts(query);

      final products = productModels
          .map((model) => model.toEntity())
          .toList();

      emit(
        SearchLoaded(
          products,
        ),
      );
    } catch (e) {
      emit(
        SearchError(
          e.toString(),
        ),
      );
    }
  }
}