
import '../../../data/models/gift_preferences.dart';

sealed class AIGiftEvent {
  const AIGiftEvent();
}

class SubmitAIPreferences extends AIGiftEvent {
  final GiftPreferences preferences;

  const SubmitAIPreferences({required this.preferences});
}
