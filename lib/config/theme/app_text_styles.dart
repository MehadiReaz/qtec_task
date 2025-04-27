import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static const TextStyle productTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.priceColor,
  );

  static const TextStyle oldPrice = TextStyle(
    fontSize: 10,
    decoration: TextDecoration.lineThrough,
    decorationThickness: 1,
    decorationColor: AppColors.oldPriceColor,
    color: AppColors.oldPriceColor,
  );

  static const TextStyle discount = TextStyle(
    fontSize: 10,
    color: AppColors.discountColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle rating = TextStyle(
    fontSize: 14,
    color: AppColors.ratingTextColor,
  );
}
