import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.maxStars = 5,
  });

  final double rating;
  final double size;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final filled = rating.round().clamp(0, maxStars);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        return Icon(
          index < filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: AppTheme.starColor,
        );
      }),
    );
  }
}
