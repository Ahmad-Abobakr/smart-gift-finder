import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _firebaseAuth;

  ProfileBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const ProfileError('No user is currently signed in'));
        return;
      }
      emit(ProfileLoaded(
        name: user.displayName ?? 'مستخدم',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        // TODO: استبدال القيم دي بالبيانات الحقيقية لما تتوفر مهام Favorites / Orders
        favoritesCount: 0,
        ordersCount: 0,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<ProfileState> emit) async {
    try {
      await _firebaseAuth.signOut();
      emit(const ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
