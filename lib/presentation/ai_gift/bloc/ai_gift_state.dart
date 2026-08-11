import '../../../domain/entities/product.dart';

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
  final List<Product> products;
  final List<String> reasons;
  final String summary;

  const AIGiftLoaded({
    required this.products,
    required this.reasons,
    required this.summary,
  });
}

class AIGiftError extends AIGiftState {
  final String message;

  const AIGiftError(this.message);
}
