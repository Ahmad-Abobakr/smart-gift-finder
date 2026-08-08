import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local/local_data_source.dart';
import '../../../data/data_sources/remote/firebase_data_source.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/product.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required LocalDataSource localDataSource,
    required FirebaseDataSource firebaseDataSource,
  })  : _localDataSource = localDataSource,
        _firebaseDataSource = firebaseDataSource,
        super(const CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<IncreaseQuantity>(_onIncreaseQuantity);
    on<DecreaseQuantity>(_onDecreaseQuantity);
    on<ClearCart>(_onClearCart);
  }

  final LocalDataSource _localDataSource;
  final FirebaseDataSource _firebaseDataSource;

  Map<Product, int> _cartItems = {};

  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());

    try {
      final localCart = _localDataSource.getCart();

      _cartItems = {
        for (final entry in localCart.entries)
          entry.key.toEntity(): entry.value,
      };

      emit(CartLoaded(Map.unmodifiable(_cartItems)));

      try {
        final remoteCart = await _firebaseDataSource.getCart();

        _cartItems = {
          for (final entry in remoteCart.entries)
            entry.key.toEntity(): entry.value,
        };

        await _localDataSource.saveCart(
          _cartItems.map(
            (product, quantity) => MapEntry(
              ProductModel.fromEntity(product),
              quantity,
            ),
          ),
        );

        emit(CartLoaded(Map.unmodifiable(_cartItems)));
      } catch (_) {
        // Local cart remains available if Firebase is unavailable.
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      final currentQuantity = _cartItems[event.product] ?? 0;
      final newQuantity = currentQuantity + 1;

      _cartItems = {
        ..._cartItems,
        event.product: newQuantity,
      };

      await _saveCart();

      emit(CartLoaded(Map.unmodifiable(_cartItems)));

      try {
        await _firebaseDataSource.saveCartItem(
          ProductModel.fromEntity(event.product),
          newQuantity,
        );
      } catch (_) {
        // Local cart remains available if Firebase is unavailable.
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      _cartItems.removeWhere(
        (product, _) => product.id == event.productId,
      );

      await _saveCart();

      emit(CartLoaded(Map.unmodifiable(_cartItems)));

      try {
        await _firebaseDataSource.removeCartItem(event.productId);
      } catch (_) {
        // Local cart remains available if Firebase is unavailable.
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onIncreaseQuantity(
    IncreaseQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      Product? targetProduct;

      for (final product in _cartItems.keys) {
        if (product.id == event.productId) {
          targetProduct = product;
          break;
        }
      }

      if (targetProduct == null) return;

      final newQuantity =
          (_cartItems[targetProduct] ?? 0) + 1;

      _cartItems[targetProduct] = newQuantity;

      await _saveCart();

      emit(CartLoaded(Map.unmodifiable(_cartItems)));

      try {
        await _firebaseDataSource.saveCartItem(
          ProductModel.fromEntity(targetProduct),
          newQuantity,
        );
      } catch (_) {
        // Local cart remains available if Firebase is unavailable.
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onDecreaseQuantity(
    DecreaseQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      Product? targetProduct;

      for (final product in _cartItems.keys) {
        if (product.id == event.productId) {
          targetProduct = product;
          break;
        }
      }

      if (targetProduct == null) return;

      final currentQuantity =
          _cartItems[targetProduct] ?? 1;

      if (currentQuantity <= 1) {
        _cartItems.remove(targetProduct);

        try {
          await _firebaseDataSource.removeCartItem(
            event.productId,
          );
        } catch (_) {
          // Local cart remains available if Firebase is unavailable.
        }
      } else {
        final newQuantity = currentQuantity - 1;

        _cartItems[targetProduct] = newQuantity;

        try {
          await _firebaseDataSource.saveCartItem(
            ProductModel.fromEntity(targetProduct),
            newQuantity,
          );
        } catch (_) {
          // Local cart remains available if Firebase is unavailable.
        }
      }

      await _saveCart();

      emit(CartLoaded(Map.unmodifiable(_cartItems)));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      _cartItems = {};

      await _localDataSource.clearCart();

      try {
        await _firebaseDataSource.clearCart();
      } catch (_) {
        // Local cart remains cleared if Firebase is unavailable.
      }

      emit(const CartLoaded({}));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _saveCart() async {
    await _localDataSource.saveCart(
      _cartItems.map(
        (product, quantity) => MapEntry(
          ProductModel.fromEntity(product),
          quantity,
        ),
      ),
    );
  }
}