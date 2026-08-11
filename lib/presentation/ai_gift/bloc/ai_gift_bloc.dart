import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/remote/ai_gift_data_source.dart';
import '../../../data/data_sources/remote/api_data_source.dart';
import '../../../domain/entities/product.dart';
import 'ai_gift_event.dart';
import 'ai_gift_state.dart';

class AIGiftBloc extends Bloc<AIGiftEvent, AIGiftState> {
  final AIGiftDataSource _aiDataSource;
  final ApiDataSource _apiDataSource;

  AIGiftBloc({
    required this._aiDataSource,
    required this._apiDataSource,
  }) : super(const AIGiftInitial()) {
    on<SubmitAIPreferences>(_onSubmitPreferences);
    on<ResetAIGift>(_onReset);
  }

  Future<void> _onSubmitPreferences(
    SubmitAIPreferences event,
    Emitter<AIGiftState> emit,
  ) async {
    emit(const AIGiftLoading());
    try {
      final catalog = await _apiDataSource.getProducts(limit: 100);

      final catalogEntities = catalog.map((m) => m.toEntity()).toList();

      final response = await _aiDataSource.getRecommendations(
        catalog: catalogEntities,
        ageRange: event.ageRange,
        gender: event.gender,
        occasion: event.occasion,
        interests: event.interests,
        budgetMax: event.budgetMax,
      );

      final matchedProducts = <Product>[];
      final matchedReasons = <String>[];

      for (final suggestion in response.suggestions) {
        final match = catalogEntities
            .where((p) => p.id == suggestion.productId)
            .toList();
        if (match.isNotEmpty) {
          matchedProducts.add(match.first);
          matchedReasons.add(suggestion.reason);
        }
      }

      emit(AIGiftLoaded(
        products: matchedProducts,
        reasons: matchedReasons,
        summary: response.summary,
      ));
    } catch (e) {
      emit(AIGiftError(e.toString()));
    }
  }

  void _onReset(ResetAIGift event, Emitter<AIGiftState> emit) {
    emit(const AIGiftInitial());
  }
}
