sealed class AIGiftEvent {
  const AIGiftEvent();
}

class SubmitAIPreferences extends AIGiftEvent {
  final String ageRange;
  final String gender;
  final String occasion;
  final String interests;
  final double budgetMax;

  const SubmitAIPreferences({
    required this.ageRange,
    required this.gender,
    required this.occasion,
    required this.interests,
    required this.budgetMax,
  });
}

class ResetAIGift extends AIGiftEvent {
  const ResetAIGift();
}
