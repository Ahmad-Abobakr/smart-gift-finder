import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/remote/api_data_source.dart';
import '../../../domain/usecases/get_ai_recommendations.dart';
import 'ai_gift_event.dart';
import 'ai_gift_state.dart';

class AIGiftBloc extends Bloc<AIGiftEvent, AIGiftState> {
  final GetAiRecommendations _getAiRecommendations;
  final ApiDataSource _apiDataSource;

  AIGiftBloc({
    required this._getAiRecommendations,
    required this._apiDataSource,
  }) : super(const AIGiftInitial()) {
    on<SubmitAIPreferences>(_onSubmitPreferences);
  }

  Future<void> _onSubmitPreferences(
    SubmitAIPreferences event,
    Emitter<AIGiftState> emit,
  ) async {
    emit(const AIGiftLoading());
    try {
      final catalog = await _apiDataSource.getProducts(limit: 100);

      final result = await _getAiRecommendations(
        catalog: catalog.map((m) => m.toEntity()).toList(),
        preferences: event.preferences,
      );

      emit(AIGiftLoaded(result: result));
    } catch (e) {
      emit(AIGiftError(e.toString()));
    }
  }
}
