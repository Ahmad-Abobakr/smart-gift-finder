import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../cart/bloc/cart_bloc.dart';
import '../cart/bloc/cart_event.dart';
import '../cart/cart_screen.dart';
import '../favorites/bloc/favorites_bloc.dart';
import '../favorites/bloc/favorites_event.dart';
import '../favorites/bloc/favorites_state.dart';
import 'product_card.dart';
import 'product_details_screen.dart';

class FavoritableProductCard extends StatelessWidget {
  const FavoritableProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final favorites = state is FavoritesLoaded
            ? state.favorites
            : const <Product>[];
        final isFavorite = favorites.any((p) => p.id == product.id);

        return ProductCard(
          product: product,
          isFavorite: isFavorite,
          onFavoriteToggle: (value) {
            final bloc = context.read<FavoritesBloc>();
            if (value) {
              bloc.add(AddFavorite(product));
            } else {
              bloc.add(RemoveFavorite(product.id));
            }
          },
          onTap: () => openProductDetails(context, product: product),
        );
      },
    );
  }
}

Future<void> openProductDetails(
  BuildContext context, {
  required Product product,
}) {
  final favoritesState = context.read<FavoritesBloc>().state;
  final isFavorite = favoritesState is FavoritesLoaded &&
      favoritesState.favorites.any((p) => p.id == product.id);

  return showProductDetails(
    context,
    product: product,
    isFavorite: isFavorite,
    onToggleFavorite: () {
      final bloc = context.read<FavoritesBloc>();
      if (isFavorite) {
        bloc.add(RemoveFavorite(product.id));
      } else {
        bloc.add(AddFavorite(product));
      }
    },
    onAddToCart: () {
      context.read<CartBloc>().add(AddToCart(product));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart'),
          duration: Duration(seconds: 1),
        ),
      );
    },
    onBuyNow: () {
      context.read<CartBloc>().add(AddToCart(product));
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const CartScreen(),
        ),
      );
    },
  );
}
