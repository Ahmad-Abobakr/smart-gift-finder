import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/product_model.dart';

class FirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.uid;
  }

  // ─────────────────────────────────────────────
  // Favorites
  // ─────────────────────────────────────────────

  Future<void> saveFavorite(ProductModel product) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(product.id.toString())
        .set(product.toJson());
  }

  Future<List<ProductModel>> getFavorites() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> removeFavorite(int productId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(productId.toString())
        .delete();
  }

  // ─────────────────────────────────────────────
  // Cart
  // ─────────────────────────────────────────────

  Future<void> saveCartItem(
    ProductModel product,
    int quantity,
  ) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(product.id.toString())
        .set({
      'product': product.toJson(),
      'quantity': quantity,
    });
  }

  Future<Map<ProductModel, int>> getCart() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .get();

    final Map<ProductModel, int> cart = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final productData = Map<String, dynamic>.from(
        data['product'] as Map,
      );

      final product = ProductModel.fromJson(productData);

      final quantity =
          (data['quantity'] as num?)?.toInt() ?? 1;

      cart[product] = quantity;
    }

    return cart;
  }

  Future<void> removeCartItem(int productId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(productId.toString())
        .delete();
  }

  Future<void> clearCart() async {
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart');

    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}