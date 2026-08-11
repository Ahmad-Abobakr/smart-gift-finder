import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/remote/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  @override
  User? get currentUser => authDataSource.currentUser?.toEntity();

  @override
  Future<User> signIn({required String email, required String password}) async {
    final model = await authDataSource.signIn(email: email, password: password);
    return model.toEntity();
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final model = await authDataSource.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    return model.toEntity();
  }

  @override
  Future<void> signOut() => authDataSource.signOut();

  @override
  Future<void> resetPassword(String email) =>
      authDataSource.resetPassword(email);
}
