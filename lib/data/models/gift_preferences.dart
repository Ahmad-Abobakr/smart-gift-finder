/// The user's gift preferences collected in the form and sent all the
/// way down to the AI. One object instead of passing 5 separate fields
/// through every layer (event → bloc → use case → service).
class GiftPreferences {
  final String ageRange;
  final String gender;
  final String occasion;
  final String interests;
  final double budgetMax;

  const GiftPreferences({
    required this.ageRange,
    required this.gender,
    required this.occasion,
    required this.interests,
    required this.budgetMax,
  });
}
