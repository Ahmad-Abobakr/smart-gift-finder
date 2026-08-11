import '../entities/user.dart';

/// واجهة مجردة (contract) — الـ presentation layer بيتكلم مع دي بس
/// وميعرفش حاجة عن Firebase ولا أي تفاصيل تانية
abstract class AuthRepository {
  User? get currentUser;

  Future<User> signIn({required String email, required String password});

  Future<User> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  Future<void> resetPassword(String email);
}
