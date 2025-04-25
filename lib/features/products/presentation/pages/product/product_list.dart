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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Access context through the State's context
      context.read<ProductBloc>().add(LoadMoreProductsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
