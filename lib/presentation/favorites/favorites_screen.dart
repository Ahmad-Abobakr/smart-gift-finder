import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/data_sources/local/local_data_source.dart';
import '../../data/data_sources/remote/firebase_data_source.dart';
import '../../domain/entities/product.dart';
import 'bloc/favorites_bloc.dart';
import 'bloc/favorites_event.dart';
import 'bloc/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.localDataSource,
    required this.firebaseDataSource,
  });

  final LocalDataSource localDataSource;
  final FirebaseDataSource firebaseDataSource;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoritesBloc(
        localDataSource: localDataSource,
        firebaseDataSource: firebaseDataSource,
      )..add(const LoadFavorites()),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is FavoritesError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                ),
              ),
            );
          }

          if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return const Center(
                child: Text(
                  'No favorite products yet.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.favorites.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = state.favorites[index];

                return _FavoriteCard(
                  product: product,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        context.read<FavoritesBloc>().add(
              RemoveFavorite(product.id),
            );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.thumbnail,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 90,
                      height: 90,
                      color: AppTheme.primaryLight,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTheme.priceText,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.starColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<FavoritesBloc>().add(
                        RemoveFavorite(product.id),
                      );
                },
                icon: const Icon(
                  Icons.favorite,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}