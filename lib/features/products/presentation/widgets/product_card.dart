import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qtec_task/config/theme/app_colors.dart';
import 'package:qtec_task/config/theme/app_text_styles.dart';
import 'package:qtec_task/features/products/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final Function(ProductEntity) onWishlistToggle;
  final bool isWishlisted;

  const ProductCard({
    super.key,
    required this.product,
    required this.onWishlistToggle,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = (product.discountPercentage ?? 0) > 0;
    final originalPrice = product.price ?? 0;
    final discountPercentage = product.discountPercentage ?? 0;
    final discountedPrice = hasDiscount
        ? originalPrice - (originalPrice * discountPercentage / 100)
        : originalPrice;
    final isOutOfStock = (product.stock ?? 0) <= 0;

    return Stack(
      children: [
        Card(
          elevation: 0,
          color: AppColors.backgroundWhite,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Wishlist button
              Stack(
                children: [
                  // Product Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: product.thumbnail != null
                          ? Image.network(
                              product.thumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.greyColor,
                                child: const Icon(Icons.image_not_supported,
                                    color: AppColors.greyColor),
                              ),
                            )
                          : Container(
                              color: AppColors.lightGrey,
                              child: const Icon(Icons.image_not_supported,
                                  color: AppColors.greyColor),
                            ),
                    ),
                  ),

                  // Wishlist Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        log('Wishlist button tapped for ${product.id}');
                        onWishlistToggle(product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color:
                              isWishlisted ? Colors.red : AppColors.greyColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Product Details
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      product.title ?? 'Unnamed Product',
                      style: AppTextStyles.productTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      strutStyle:
                          const StrutStyle(forceStrutHeight: true, height: 1.5),
                    ),

                    const SizedBox(height: 8),

                    // Price Section
                    Row(
                      children: [
                        Text('\$${discountedPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.price),
                        if (hasDiscount) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '\$${originalPrice.toStringAsFixed(0)}',
                              style: AppTextStyles.oldPrice,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${discountPercentage.toStringAsFixed(0)}% OFF',
                              style: AppTextStyles.discount),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Rating row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 3.04),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: AppColors.backgroundWhite,
                            size: 10,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviews?[0].rating ?? 0})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.lightGrey,
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

        // Out of Stock Banner
        if (isOutOfStock)
          Positioned(
            top: 12,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
              ),
              child: const Text(
                'Out Of Stock',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
