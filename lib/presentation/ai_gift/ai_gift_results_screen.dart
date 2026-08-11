import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/data_sources/remote/ai_gift_data_source.dart';
import '../../data/data_sources/remote/api_data_source.dart';
import '../../domain/entities/product.dart';
import '../favorites/bloc/favorites_bloc.dart';
import '../favorites/bloc/favorites_event.dart';
import '../favorites/bloc/favorites_state.dart';
import '../widgets/favoritable_product_card.dart';
import 'bloc/ai_gift_bloc.dart';
import 'bloc/ai_gift_event.dart';
import 'bloc/ai_gift_state.dart';

class AIGiftResultsScreen extends StatelessWidget {
  final String ageRange;
  final String gender;
  final String occasion;
  final String interests;
  final double budgetMax;

  const AIGiftResultsScreen({
    super.key,
    required this.ageRange,
    required this.gender,
    required this.occasion,
    required this.interests,
    required this.budgetMax,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AIGiftBloc(
        aiDataSource: AIGiftDataSource(),
        apiDataSource: ApiDataSource(),
      )..add(SubmitAIPreferences(
          ageRange: ageRange,
          gender: gender,
          occasion: occasion,
          interests: interests,
          budgetMax: budgetMax,
        )),
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBgColor,
        appBar: AppBar(
          title: const Text('AI Gift Recommendations'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<AIGiftBloc, AIGiftState>(
          builder: (context, state) {
            if (state is AIGiftLoading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'Finding the perfect gifts...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is AIGiftError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AIGiftBloc>().add(ResetAIGift());
                          Navigator.of(context).pop();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is AIGiftLoaded) {
              return _buildResults(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, AIGiftLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.aiGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ai_robot.png',
                      width: 56,
                      height: 56,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.smart_toy_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'نصيحة من الذكاء الاصطناعي',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.summary.isNotEmpty
                                ? state.summary
                                : 'هنا أفضل الهدايا لشخص عمره $ageRange ويبلغ بالجنس $gender!',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (state.products.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'لم يتم العثور على منتجات مطابقة. جرّب تفضيلات مختلفة.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = state.products[index];
                final reason =
                    index < state.reasons.length ? state.reasons[index] : '';
                return BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, favState) {
                    final favorites = favState is FavoritesLoaded
                        ? favState.favorites
                        : const <Product>[];
                    final isFavorite =
                        favorites.any((p) => p.id == product.id);
                    return _AIProductCard(
                      product: product,
                      reason: reason,
                      isFavorite: isFavorite,
                      onFavoriteToggle: () {
                        final bloc = context.read<FavoritesBloc>();
                        if (isFavorite) {
                          bloc.add(RemoveFavorite(product.id));
                        } else {
                          bloc.add(AddFavorite(product));
                        }
                      },
                      onTap: () => openProductDetails(
                        context,
                        product: product,
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AIProductCard extends StatelessWidget {
  final dynamic product;
  final String reason;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const _AIProductCard({
    required this.product,
    required this.reason,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.thumbnail,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.primaryLight,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppTheme.textHint,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.red
                              : AppTheme.textHint,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AI Suggestion',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppTheme.starColor),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
