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
      // Load more only if not searching
      if (_searchQuery.isEmpty) {
        context.read<ProductBloc>().add(LoadMoreProductsEvent());
      }
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
