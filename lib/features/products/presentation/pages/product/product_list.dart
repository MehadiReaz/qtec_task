import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:qtec_task/features/products/domain/entities/product.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_events.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_state.dart';
import 'package:qtec_task/features/products/presentation/widgets/product_card.dart';

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
      // Only add LoadMoreProductsEvent if we're in a loaded state
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
    // Use the BLoC event instead of setState
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
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Anything...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[500],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
          ),
        ),
        actions: [
          PopupMenuButton<Map<String, String>>(
            icon: const Icon(Icons.sort, color: Colors.black54),
            tooltip: 'Sort by',
            onSelected: (Map<String, String> sortOption) {
              _applySorting(sortOption['sortBy']!, sortOption['order']!);
            },
            itemBuilder: (BuildContext context) {
              return [
                _buildSortMenuItem('Price (Low to High)', 'price', 'asc'),
                _buildSortMenuItem('Price (High to Low)', 'price', 'desc'),
                _buildSortMenuItem('Rating (Low to High)', 'rating', 'asc'),
                _buildSortMenuItem('Rating (High to Low)', 'rating', 'desc'),
                _buildSortMenuItem(
                    'Discount (Low to High)', 'discountPercentage', 'asc'),
                _buildSortMenuItem(
                    'Discount (High to Low)', 'discountPercentage', 'desc'),
              ];
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
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(GetProductsEvent());

                // context.read<ProductBloc>().add(
                //       RefreshProductsEvent(
                //         currentProducts: state.currentProducts,
                //       ),
                //     );
              },
              child: _buildProductGrid(
                state.currentProducts,
                false,
                state.wishlistedProducts,
              ),
            );
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
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
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
                          style: TextStyle(color: Colors.grey),
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

  PopupMenuItem<Map<String, String>> _buildSortMenuItem(
      String title, String sortBy, String order) {
    final isSelected = _currentSortBy == sortBy && _currentSortOrder == order;

    return PopupMenuItem<Map<String, String>>(
      value: {'sortBy': sortBy, 'order': order},
      child: Row(
        children: [
          Text(title),
          if (isSelected) const SizedBox(width: 8),
          if (isSelected) const Icon(Icons.check, size: 18),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Details placeholder
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
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

  Widget _buildProductGrid(
    List<ProductEntity> products,
    bool isLoadingMore,
    Set<String> wishlistedProducts,
  ) {
    return GridView.builder(
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
            isWishlisted: wishlistedProducts.contains(product.id.toString()),
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
