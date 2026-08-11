import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_cleanMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.name,
      );
      // Firebase بيسجل دخول المستخدم تلقائيًا بمجرد إنشاء الحساب،
      // فبنعمل تسجيل خروج فورًا عشان نطلب منه يسجل دخول يدويًا بعد كده
      await authRepository.signOut();
      emit(const AuthInitial(
        message: 'Account created successfully! Please log in.',
      ));
    } catch (e) {
      emit(AuthError(_cleanMessage(e)));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.resetPassword(event.email);
      emit(const AuthInitial(
        message: 'Password reset link sent. Please check your email.',
      ));
    } catch (e) {
      emit(AuthError(_cleanMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.signOut();
    emit(const AuthInitial());
  }

  void _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) {
    final user = authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    }
  }

  String _cleanMessage(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
