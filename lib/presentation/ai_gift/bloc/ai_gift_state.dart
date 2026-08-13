import '../../../domain/usecases/get_ai_recommendations.dart';

sealed class AIGiftState {
  const AIGiftState();
}

class AIGiftInitial extends AIGiftState {
  const AIGiftInitial();
}

class AIGiftLoading extends AIGiftState {
  const AIGiftLoading();
}

class AIGiftLoaded extends AIGiftState {
  final AiGiftRecommendationResult result;

  const AIGiftLoaded({required this.result});
}

class AIGiftError extends AIGiftState {
  final String message;

  const AIGiftError(this.message);
}
