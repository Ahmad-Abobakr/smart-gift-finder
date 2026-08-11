import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

/// المصدر الوحيد اللي بيتكلم مع Firebase Authentication فعليًا
class AuthDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthDataSource({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// المستخدم الحالي (لو موجود) بدون استدعاء شبكة
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  /// تسجيل الدخول بالإيميل وكلمة المرور
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Login failed. Please try again.');
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// إنشاء حساب جديد بالإيميل وكلمة المرور، مع اسم العرض (اختياري)
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Sign up failed. Please try again.');
      }
      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
        await user.reload();
      }
      final refreshedUser = _firebaseAuth.currentUser ?? user;
      return UserModel.fromFirebaseUser(refreshedUser);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// إرسال إيميل إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// تحويل أكواد أخطاء Firebase لرسائل مفهومة للمستخدم
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
