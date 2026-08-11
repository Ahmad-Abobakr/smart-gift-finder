import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../domain/entities/product.dart';

class AIGiftResponse {
  final List<AIGiftSuggestion> suggestions;
  final String summary;

  const AIGiftResponse({required this.suggestions, required this.summary});
}

class AIGiftSuggestion {
  final int productId;
  final String reason;

  const AIGiftSuggestion({required this.productId, required this.reason});
}

class AIGiftDataSource {
  GenerativeModel? _model;

  Future<GenerativeModel> _getModel() async {
    if (_model != null) return _model!;

    final ai = FirebaseAI.googleAI(
      app: Firebase.app(),
    );

    _model = ai.generativeModel(
      model: 'gemini-3.6-flash',
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'summary': Schema.string(),
            'suggestions': Schema.array(
              items: Schema.object(
                properties: {
                  'productId': Schema.integer(),
                  'reason': Schema.string(),
                },
              ),
            ),
          },
        ),
      ),
      systemInstruction: Content.system(
        'You are a smart gift recommendation assistant. '
        'Given a catalog of available gift products and user preferences, '
        'choose the BEST 1-3 products from the catalog that match the user\'s needs. '
        'Always return product IDs that exist in the provided catalog. '
        'Write a brief, friendly summary explaining your recommendations. '
        'Each suggestion must include a personalized reason explaining why it fits.',
      ),
    );

    return _model!;
  }

  Future<AIGiftResponse> getRecommendations({
    required List<Product> catalog,
    required String ageRange,
    required String gender,
    required String occasion,
    required String interests,
    required double budgetMax,
  }) async {
    final model = await _getModel();

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

    final prompt = [
      Content.text(
        'Available gift products (from our store):\n'
        '${const JsonEncoder.withIndent('  ').convert(catalogJson)}\n\n'
        'User preferences:\n'
        '- Recipient age range: $ageRange\n'
        '- Gender: $gender\n'
        '- Occasion: $occasion\n'
        '- Interests: $interests\n'
        '- Budget: up to \$$budgetMax\n\n'
        'Choose 1-3 products from the catalog above that best match these preferences. '
        'Return JSON with "summary" (a friendly 1-2 sentence overview) '
        'and "suggestions" (array of {productId, reason}).',
      ),
    ];

    final response = await model.generateContent(prompt);

    if (response.text == null) {
      throw Exception('AI returned an empty response');
    }

    final json = jsonDecode(response.text!) as Map<String, dynamic>;

    final suggestions = (json['suggestions'] as List<dynamic>? ?? [])
        .map((s) => AIGiftSuggestion(
              productId: s['productId'] as int,
              reason: s['reason'] as String? ?? '',
            ))
        .toList();

    final summary = json['summary'] as String? ?? '';

    return AIGiftResponse(suggestions: suggestions, summary: summary);
  }
}
