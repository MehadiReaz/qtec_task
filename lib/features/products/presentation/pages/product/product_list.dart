import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:qtec_task/features/products/domain/entities/product.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_events.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_state.dart';
import 'package:qtec_task/features/products/presentation/widgets/product_card.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../widgets/search_textfield.dart';
import '../../widgets/sort_button.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _currentSortBy = 'price';
  String _currentSortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Initially load products
    // context.read<ProductBloc>().add(GetProductsEvent());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductsLoaded &&
          !state.isLoadingMore &&
          !state.hasReachedMax) {
        context.read<ProductBloc>().add(LoadMoreProductsEvent());
      }
    }
  }

  void _onSearchChanged(String query) {
    context.read<ProductBloc>().add(DebounceSearchEvent(query));
  }

  void _toggleWishlist(ProductEntity product) {
    context
        .read<ProductBloc>()
        .add(WishlistToggleEvent(productId: product.id.toString()));
  }

  void _applySorting(String sortBy, String order) {
    _currentSortBy = sortBy;
    _currentSortOrder = order;
    context.read<ProductBloc>().add(
          SortProductsEvent(
            sortBy: sortBy,
            order: order,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SearchTextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        actions: [
          BlocSelector<ProductBloc, ProductState, bool>(
            selector: (state) {
              return state is ProductsLoaded && state.isSearchActive;
            },
            builder: (context, showSortButton) {
              return Visibility(
                visible: showSortButton,
                child: SortButton(onPressed: () {
                  showModalBottomSheet(
                    barrierColor: Colors.transparent,
                    context: context,
                    builder: (_) => _buildSortBottomSheet(),
                  );
                }),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductLoadFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.toString())),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoading) {
            return _buildShimmerGrid();
          } else if (state is ProductsRefreshing) {
            if (state.currentProducts.isEmpty) {
              return _buildShimmerGrid();
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProductBloc>().add(
                        RefreshProductsEvent(
                          currentProducts: state.currentProducts,
                        ),
                      );
                },
                child: _buildProductGrid(
                  state.currentProducts,
                  false,
                  state.wishlistedProducts,
                  0, // No total count during refresh
                  false, // Not searching during refresh
                ),
              );
            }
          } else if (state is ProductsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(
                      RefreshProductsEvent(
                        currentProducts: state.products,
                      ),
                    );
              },
              child: _buildProductGrid(
                state.products,
                state.isLoadingMore,
                state.wishlistedProducts,
                state.totalCount,
                state.isSearchActive,
              ),
            );
          } else if (state is ProductsEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(RefreshProductsEvent());
              },
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 3),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: AppColors.greyColor),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try changing your search or filters',
                          style: TextStyle(color: AppColors.greyColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(RefreshProductsEvent());
              },
              child: const Center(child: Text('Failed to load products')),
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.lightGrey2,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors
                  .lightGrey, // Use a grey base for shimmer compatibility
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder with wishlist button
                Stack(
                  children: [
                    // Image placeholder
                    AspectRatio(
                      aspectRatio: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: Container(
                          color:
                              AppColors.lightGrey, // Match shimmer base color
                        ),
                      ),
                    ),

                    // Wishlist button placeholder
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              AppColors.lightGrey, // Match shimmer base color
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          width: 18,
                          height: 18,
                          color:
                              AppColors.lightGrey, // Match shimmer base color
                        ),
                      ),
                    ),
                  ],
                ),

                // Product details placeholder
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title placeholder (two lines)
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: AppColors.lightGrey, // Match shimmer base color
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: AppColors.lightGrey,
                      ),

                      const SizedBox(height: 12),

                      // Price placeholder
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 14,
                            color: AppColors.lightGrey,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 50,
                            height: 12,
                            color: AppColors.lightGrey,
                          ),
                          const Spacer(),
                          Container(
                            width: 40,
                            height: 14,
                            color: AppColors.lightGrey,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Rating placeholder
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: AppColors.lightGrey,
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 30,
                            height: 12,
                            color: AppColors.lightGrey,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 12,
                            color: AppColors.lightGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSortOption('Price - High to Low', 'price', 'desc'),
            _buildSortOption('Price - Low to High', 'price', 'asc'),
            _buildSortOption('Rating', 'rating', 'desc'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String sortBy, String order) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(title),
      trailing: _currentSortBy == sortBy && _currentSortOrder == order
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        _applySorting(sortBy, order);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildProductGrid(
    List<ProductEntity> products,
    bool isLoadingMore,
    Set<String> wishlistedProducts,
    int totalCount,
    bool isSearchActive,
  ) {
    return Column(
      children: [
        if (isSearchActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.lightGrey.withOpacity(0.1),
            width: double.infinity,
            child: Center(
              child: Text(
                '$totalCount Items',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length + (isLoadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index < products.length) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  isWishlisted:
                      wishlistedProducts.contains(product.id.toString()),
                  onWishlistToggle: _toggleWishlist,
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
