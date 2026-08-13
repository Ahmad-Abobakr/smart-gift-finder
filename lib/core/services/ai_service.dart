import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/gift_preferences.dart';

/// The ONLY component that talks to Gemini via Firebase AI Logic.
///
/// Responsibilities:
/// - Set up the Gemini model (model name, generation config, JSON response schema)
/// - Send the Arabic system instruction that makes the AI a gift assistant
/// - Build the structured prompt from the user's preferences + product catalog
/// - Parse the AI's raw JSON response into [AiRecommendationResult]
///
/// It does NOT know about [Product] entities or matching — that is the
/// domain use case's job ([GetAiRecommendations]).
class AiService {
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
        'أنت مساعد ذكي لتوصية الهدايا. '
        'بناءً على كتالوج منتجات الهدايا المتاحة وتفضيلات المستخدم، '
        'اختر أفضل 1-3 منتجات من الكتالوج تناسب احتياجات المستخدم. '
        'تأكد دائمًا من إرجاع معرفات منتجات موجودة في الكتالوج المقدم. '
        'اكتب ملخصًا ودودًا وموجزًا يشرح توصيحاتك. '
        'يجب أن يحتوي كل اقتراح على سبب شخصي يوضح لماذا هو مناسب. '
        'اكتب الإجابة كلها باللغة العربية.',
      ),
    );

    return _model!;
  }

  /// Structured request with explicit preference fields.
  ///
  /// [catalog] must be pre-resolved to a list of product-like maps
  /// (id, title, price, category, brand, rating, description) that
  /// exist in your store.
  Future<AiRecommendationResult> getGiftRecommendations({
    required List<Map<String, dynamic>> catalog,
    required GiftPreferences preferences,
  }) async {
    final model = await _getModel();

    final prompt = [
      Content.text(
        'منتجات الهدايا المتاحة (من متجرنا):\n'
        '${const JsonEncoder.withIndent('  ').convert(catalog)}\n\n'
        'تفضيلات المستخدم:\n'
        '- فئة عمرية المستلم: ${preferences.ageRange}\n'
        '- الجنس: ${preferences.gender}\n'
        '- المناسبة: ${preferences.occasion}\n'
        '- الاهتمامات: ${preferences.interests}\n'
        '- الميزانية: حتى \$${preferences.budgetMax}\n\n'
        'اختر منتجات من 1 إلى 3 من الكتالوج أعلاه تناسب هذه التفضيلات. '
        'أرجع JSON مع "summary" (نظرة عامة ودية مكوّنة من جملتين) '
        'و "suggestions" (مصفوفة من {productId, reason}).',
      ),
    ];

    final response = await model.generateContent(prompt);

    if (response.text == null) {
      throw Exception('AI returned an empty response');
    }

    return _parseResponse(response.text!);
  }

  AiRecommendationResult _parseResponse(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;

    final suggestions = (json['suggestions'] as List<dynamic>? ?? [])
        .map((s) => AiSuggestion(
              productId: s['productId'] as int,
              reason: s['reason'] as String? ?? '',
            ))
        .toList();

    final summary = json['summary'] as String? ?? '';

    return AiRecommendationResult(
      suggestions: suggestions,
      summary: summary,
    );
  }
}

/// Result returned by [AiService].
class AiRecommendationResult {
  final List<AiSuggestion> suggestions;
  final String summary;

  const AiRecommendationResult({
    required this.suggestions,
    required this.summary,
  });
}

/// A single product suggestion from the AI.
class AiSuggestion {
  final int productId;
  final String reason;

  const AiSuggestion({required this.productId, required this.reason});
}
