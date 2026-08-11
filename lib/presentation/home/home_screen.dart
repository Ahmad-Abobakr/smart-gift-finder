import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../widgets/category_card.dart';
import '../widgets/favoritable_product_card.dart';
import '../ai_gift/ai_gift_form_screen.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // خريطة بسيطة لربط اسم الفئة (slug) بأيقونة مناسبة
  // خريطة أيقونة مناسبة لكل فئة (بناءً على الـ slug الراجع من DummyJSON)
  static const _categoryIcons = <String, IconData>{
    'fragrances': Icons.spa_outlined,
    'skin-care': Icons.face_retouching_natural_outlined,
    'skincare': Icons.face_retouching_natural_outlined,
    'beauty': Icons.brush_outlined,
    'jewellery': Icons.diamond_outlined,
    'womens-jewellery': Icons.diamond_outlined,
    'mens-watches': Icons.watch_outlined,
    'womens-watches': Icons.watch_outlined,
    'sunglasses': Icons.wb_sunny_outlined,
    'womens-bags': Icons.shopping_bag_outlined,
    'womens-shoes': Icons.checkroom_outlined,
    'mens-shoes': Icons.checkroom_outlined,
    'mens-shirts': Icons.checkroom_outlined,
    'tops': Icons.checkroom_outlined,
    'womens-dresses': Icons.checkroom_outlined,
    'mobile-accessories': Icons.headphones_outlined,
    'sports-accessories': Icons.sports_basketball_outlined,
    'smartphones': Icons.smartphone_outlined,
    'laptops': Icons.laptop_mac_outlined,
    'tablets': Icons.tablet_mac_outlined,
    'headphones': Icons.headphones_outlined,
  };

  // ألوان خلفية دائرية مختلفة لكل فئة (نفس فكرة التصميم: كل فئة بلونها)
  static const _categoryBgColors = <Color>[
    Color(0xFFFCE4EC), // pink
    Color(0xFFE3F2FD), // blue
    Color(0xFFFFF3E0), // orange
    Color(0xFFE8F5E9), // green
    Color(0xFFF3E5F5), // purple
    Color(0xFFFFFDE7), // yellow
    Color(0xFFE0F7FA), // teal
  ];

  static const _categoryIconColors = <Color>[
    Color(0xFFD81B60),
    Color(0xFF1976D2),
    Color(0xFFEF6C00),
    Color(0xFF388E3C),
    Color(0xFF8E24AA),
    Color(0xFFF9A825),
    Color(0xFF00838F),
  ];

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<HomeBloc>().add(SearchProducts(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Menu'),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(state.message, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeBloc>().add(const LoadHomeData()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loaded = state as HomeLoaded;
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<HomeBloc>().add(const LoadHomeData()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Find your gift...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!loaded.isSearching) ...[
                  _AskAiBanner(onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AIGiftFormScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  _SectionHeader(title: 'Popular Categories', onSeeAll: () {}),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: loaded.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final Category category = loaded.categories[index];
                        return CategoryCard(
                          category: category,
                          icon: _categoryIcons[category.slug.toLowerCase()] ??
                              Icons.card_giftcard_outlined,
                          backgroundColor: _categoryBgColors[
                              index % _categoryBgColors.length],
                          iconColor: _categoryIconColors[
                              index % _categoryIconColors.length],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionHeader(title: 'Recommended Gifts', onSeeAll: () {}),
                  const SizedBox(height: 12),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text('نتائج البحث',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: loaded.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final product = loaded.products[index];
                    return FavoritableProductCard(product: product);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AskAiBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AskAiBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find the perfect gift with AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Describe the person or occasion and let AI find the best gifts for you!',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Ask AI'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ai_robot.png',
            width: 90,
            height: 90,
            errorBuilder: (_, _, _) => const Icon(
              Icons.smart_toy_outlined,
              size: 56,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }
}
