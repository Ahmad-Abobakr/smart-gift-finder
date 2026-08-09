import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String? photoUrl;
  // إحصائيات مبدئية (وهمية) لحد ما يتم ربطها بمهام Favorites / Orders لاحقًا
  final int favoritesCount;
  final int ordersCount;

  const ProfileLoaded({
    required this.name,
    required this.email,
    this.photoUrl,
    this.favoritesCount = 0,
    this.ordersCount = 0,
  });

  @override
  List<Object?> get props =>
      [name, email, photoUrl, favoritesCount, ordersCount];
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
