import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';
import 'price_tag.dart';
import 'rating_stars.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onAddToCart,
    this.onBuyNow,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int _imageIndex = 0;

  List<String> get _images {
    final images = widget.product.images;
    return images.isEmpty ? [widget.product.thumbnail] : images;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            onPressed: widget.onToggleFavorite,
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? AppTheme.primaryColor : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCarousel(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            PriceTag(price: product.price, fontSize: 22),
                            const Spacer(),
                            RatingStars(rating: product.rating),
                            const SizedBox(width: 6),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 16,
                              color: AppTheme.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.stock} متوفر',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.branding_watermark_outlined,
                              size: 16,
                              color: AppTheme.textHint,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                product.brand,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSuitableFor(product),
                        const SizedBox(height: 20),
                        _sectionTitle('الوصف'),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) => setState(() => _imageIndex = index),
            itemBuilder: (context, index) {
              return Image.network(
                _images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primaryLight,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: AppTheme.textHint,
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (index) {
            final active = index == _imageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppTheme.primaryColor : AppTheme.borderLight,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSuitableFor(Product product) {
    final tags = product.tags.isNotEmpty ? product.tags : [product.category];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('مناسب لـ'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => Chip(label: Text(tag))).toList(),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onAddToCart,
                child: const Text('أضف إلى السلة'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onBuyNow,
                child: const Text('اشترِ الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showProductDetails(
  BuildContext context, {
  required Product product,
  bool isFavorite = false,
  VoidCallback? onToggleFavorite,
  VoidCallback? onAddToCart,
  VoidCallback? onBuyNow,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ProductDetailsView(
        product: product,
        isFavorite: isFavorite,
        onToggleFavorite: onToggleFavorite,
        onAddToCart: onAddToCart,
        onBuyNow: onBuyNow,
      ),
    ),
  );
}
