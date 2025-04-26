import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_state.dart';
import '../../../domain/entities/product.dart';
import '../../bloc/product_events.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _currentSortBy = 'price'; // Default sort
  String _currentSortOrder = 'asc'; // Default order

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Initially load products
    context.read<ProductBloc>().add(GetProductsEvent());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ProductBloc>().add(LoadMoreProductsEvent());
    }
  }

  void _onSearchSubmitted(String query) {
    _searchQuery = query.trim();
    if (_searchQuery.isNotEmpty) {
      context.read<ProductBloc>().add(SearchProductsEvent(_searchQuery));
    } else {
      // If search is cleared, reload normal products
      context.read<ProductBloc>().add(GetProductsEvent());
    }
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
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearchSubmitted('');
              },
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearchSubmitted,
        ),
        actions: [
          PopupMenuButton<Map<String, String>>(
            icon: const Icon(Icons.sort),
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
                // _buildSortMenuItem(
                //     'Discount (Low to High)', 'discountPercentage', 'asc'),
                // _buildSortMenuItem(
                //     'Discount (High to Low)', 'discountPercentage', 'desc'),
              ];
            },
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductLoadFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.message.toString())),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            return _buildProductList(state.products, state.isLoadingMore);
          } else {
            return const Center(child: Text('Failed to load products'));
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

  Widget _buildProductList(List<ProductEntity> products, bool isLoadingMore) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < products.length) {
          return ListTile(
            title: Text(products[index].title ?? ''),
            subtitle: Text(products[index].description ?? ''),
          );
        } else {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ));
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
