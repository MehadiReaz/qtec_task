import 'package:flutter/material.dart';

abstract class AppColors {
  // Backgrounds
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  // Search Bar
  static const Color hintTextColor = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFD1D5DB);
  static const Color iconColor = Color(0xFF6B7280);

  // Texts
  static const Color primaryText = Color(0xFF1F2937);
  static const Color priceColor = Color(0xFF000000);
  static const Color oldPriceColor = Color(0xFF9CA3AF);

  // Discount
  static const Color discountColor = Color(0xFFEA580C);

  // Ratings
  static const Color ratingStarColor = Color(0xFFFBBF24);
  static const Color ratingTextColor = Color(0xFF1F2937);

  // Favorites
  static const Color favoriteActiveColor = Color(0xFFEA580C);
  static const Color favoriteInactiveColor = Color(0xFFD1D5DB);

  // Others
  static const Color greyColor = Colors.grey;
  static const Color lightGrey = Color(0xFF9CA3AF);
  static Color lightGrey2 = Colors.grey.shade100;
  static Color darktGrey = Colors.grey.shade900;
}
