import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local/local_data_source.dart';
import '../../../data/data_sources/remote/firebase_data_source.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/product.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({
    required LocalDataSource localDataSource,
    required FirebaseDataSource firebaseDataSource,
  })  : _localDataSource = localDataSource,
        _firebaseDataSource = firebaseDataSource,
        super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  final LocalDataSource _localDataSource;
  final FirebaseDataSource _firebaseDataSource;

  List<Product> _favorites = [];

  // ─────────────────────────────────────────────
  // Load Favorites
  // ─────────────────────────────────────────────

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    try {
      final localFavorites = _localDataSource.getFavorites();

      _favorites = localFavorites
          .map((product) => product.toEntity())
          .toList();

      emit(FavoritesLoaded(List.unmodifiable(_favorites)));

      try {
        final remoteFavorites =
            await _firebaseDataSource.getFavorites();

        _favorites = remoteFavorites
            .map((product) => product.toEntity())
            .toList();

        await _localDataSource.saveFavorites(
          remoteFavorites,
        );

        emit(FavoritesLoaded(List.unmodifiable(_favorites)));
      } catch (_) {
        // Keep using local data if Firebase is unavailable.
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // Add Favorite
  // ─────────────────────────────────────────────

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final alreadyExists = _favorites.any(
        (product) => product.id == event.product.id,
      );

      if (alreadyExists) {
        emit(FavoritesLoaded(List.unmodifiable(_favorites)));
        return;
      }

      _favorites = [
        ..._favorites,
        event.product,
      ];

      emit(FavoritesLoaded(List.unmodifiable(_favorites)));

      final productModel =
          ProductModel.fromEntity(event.product);

      await _localDataSource.saveFavorites(
        _favorites
            .map(ProductModel.fromEntity)
            .toList(),
      );

      try {
        await _firebaseDataSource.saveFavorite(
          productModel,
        );
      } catch (_) {
        // Local storage remains available if Firebase fails.
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // Remove Favorite
  // ─────────────────────────────────────────────

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      _favorites = _favorites
          .where(
            (product) => product.id != event.productId,
          )
          .toList();

      emit(FavoritesLoaded(List.unmodifiable(_favorites)));

      await _localDataSource.saveFavorites(
        _favorites
            .map(ProductModel.fromEntity)
            .toList(),
      );

      try {
        await _firebaseDataSource.removeFavorite(
          event.productId,
        );
      } catch (_) {
        // Local storage remains available if Firebase fails.
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}