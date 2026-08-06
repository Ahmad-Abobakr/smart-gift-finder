import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    this.fontSize = 16,
  });

  final double price;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${price.toStringAsFixed(2)}',
      style: AppTheme.priceText.copyWith(fontSize: fontSize),
    );
  }
}
