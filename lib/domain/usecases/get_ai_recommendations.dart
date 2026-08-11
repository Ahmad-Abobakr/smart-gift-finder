import '../../../core/services/ai_service.dart';
import '../../../domain/entities/product.dart';

/// Use case for getting AI gift recommendations.
///
/// This wraps [AiService] and handles matching AI suggestions
/// back to real [Product] entities from the catalog.
class GetAiRecommendations {
  final AiService aiService;

  GetAiRecommendations({required this.aiService});

  /// Gets AI recommendations and resolves product suggestions.
  ///
  /// Returns a [AiRecommendationResult] with matched products
  /// and reasons.
  Future<AiRecommendationResult> call({
    required List<Product> catalog,
    required String ageRange,
    required String gender,
    required String occasion,
    required String interests,
    required double budgetMax,
  }) async {
    final catalogJson = catalog.map((p) => {
          'id': p.id,
          'title': p.title,
          'price': p.price,
          'category': p.category,
          'brand': p.brand,
          'rating': p.rating,
          'description': p.description.length > 100
              ? p.description.substring(0, 100)
              : p.description,
        }).toList();

    return await aiService.getGiftRecommendations(
      catalog: catalogJson,
      ageRange: ageRange,
      gender: gender,
      occasion: occasion,
      interests: interests,
      budgetMax: budgetMax,
    );
  }
}
