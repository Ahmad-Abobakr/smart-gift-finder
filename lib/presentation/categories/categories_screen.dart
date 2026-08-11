import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_sources/remote/api_data_source.dart';
import '../widgets/favoritable_product_card.dart';

import 'bloc/categories_bloc.dart';
import 'bloc/categories_event.dart';
import 'bloc/categories_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoriesBloc(
        ApiDataSource(),
      )..add(LoadCategories()),
      child: const CategoriesView(),
    );
  }
}

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          // Loading
          if (state is CategoriesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (state is CategoriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<CategoriesBloc>()
                          .add(LoadCategories());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Loaded
          if (state is CategoriesLoaded) {
            return Column(
              children: [
                // Categories
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];

                      final isSelected =
                          state.selectedCategory == category;

                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            context
                                .read<CategoriesBloc>()
                                .add(
                                  SelectCategory(category),
                                );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                // Products
                Expanded(
                  child: state.products.isEmpty
                      ? const Center(
                          child: Text(
                            'Select a category to see products',
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (context, index) {
                            final product =
                                state.products[index];
                            return FavoritableProductCard(
                              product: product,
                            );
                          },
                        ),
                ),
              ],
            );
          }

          // Initial
          return const Center(
            child: Text('Loading categories...'),
          );
        },
      ),
    );
  }
}