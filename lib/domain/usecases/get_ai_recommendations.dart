import '../../core/services/ai_service.dart';
import '../../data/models/gift_preferences.dart';
import '../entities/product.dart';

/// Domain use case: turn a product catalog + user preferences into
/// AI-gift recommendations backed by real [Product] entities.
///
/// Responsibilities (no UI, no Gemini internals):
/// 1. Convert [Product] entities into JSON maps the AI understands
/// 2. Call [AiService] to get the AI's suggestions + summary
/// 3. Match the suggested product IDs back to real [Product] entities
/// 4. Return the matched products, their reasons, and the AI summary
class GetAiRecommendations {
  final AiService aiService;

  GetAiRecommendations({required this.aiService});

  Future<AiGiftRecommendationResult> call({
    required List<Product> catalog,
    required GiftPreferences preferences,
  }) async {
    final catalogJson = catalog
        .map(
          (p) => {
            'id': p.id,
            'title': p.title,
            'price': p.price,
            'category': p.category,
            'brand': p.brand,
            'rating': p.rating,
            'description': p.description.length > 100
                ? p.description.substring(0, 100)
                : p.description,
          },
        )
        .toList();

    final result = await aiService.getGiftRecommendations(
      catalog: catalogJson,
      preferences: preferences,
    );

    final matchedProducts = <Product>[];
    final matchedReasons = <String>[];

    for (final suggestion in result.suggestions) {
      final matches = catalog
          .where((p) => p.id == suggestion.productId)
          .toList();
      if (matches.isNotEmpty) {
        matchedProducts.add(matches.first);
        matchedReasons.add(suggestion.reason);
      }
    }

    return AiGiftRecommendationResult(
      products: matchedProducts,
      reasons: matchedReasons,
      summary: result.summary,
    );
  }
}

/// The use case's output: the real products the AI picked, the reason
/// for each one, and a friendly summary in Arabic.
class AiGiftRecommendationResult {
  final List<Product> products;
  final List<String> reasons;
  final String summary;

  const AiGiftRecommendationResult({
    required this.products,
    required this.reasons,
    required this.summary,
  });
}
