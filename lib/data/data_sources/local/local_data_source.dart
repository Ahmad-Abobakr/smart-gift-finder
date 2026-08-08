import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product_model.dart';

class LocalDataSource {
  static const String _favoritesKey = 'favorites';
  static const String _cartKey = 'cart';

  final SharedPreferences _preferences;

  LocalDataSource(this._preferences);

  // ─────────────────────────────────────────────
  // Favorites
  // ─────────────────────────────────────────────

  Future<void> saveFavorites(List favorites) async {
    final data = favorites
        .map((product) => product.toJson())
        .toList();

    await _preferences.setString(
      _favoritesKey,
      jsonEncode(data),
    );
  }

  List<ProductModel> getFavorites() {
    final data = _preferences.getString(_favoritesKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(data);

    return decodedData
        .map(
          (item) => ProductModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> clearFavorites() async {
    await _preferences.remove(_favoritesKey);
  }

  // ─────────────────────────────────────────────
  // Cart
  // ─────────────────────────────────────────────

  Future<void> saveCart(
    Map<ProductModel, int> cartItems,
  ) async {
    final data = cartItems.entries.map((entry) {
      return {
        'product': entry.key.toJson(),
        'quantity': entry.value,
      };
    }).toList();

    await _preferences.setString(
      _cartKey,
      jsonEncode(data),
    );
  }

  Map<ProductModel, int> getCart() {
    final data = _preferences.getString(_cartKey);

    if (data == null || data.isEmpty) {
      return {};
    }

    final List<dynamic> decodedData = jsonDecode(data);

    final Map<ProductModel, int> cart = {};

    for (final item in decodedData) {
      final map = Map<String, dynamic>.from(item);

      final product = ProductModel.fromJson(
        Map<String, dynamic>.from(map['product']),
      );

      final quantity =
          (map['quantity'] as num?)?.toInt() ?? 1;

      cart[product] = quantity;
    }

    return cart;
  }

  Future<void> clearCart() async {
    await _preferences.remove(_cartKey);
  }
}