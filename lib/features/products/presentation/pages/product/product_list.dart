import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_state.dart';

import '../../../domain/entities/product.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildProductList(),
    );
  }

  _buildProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (_, state) {
        if (state is ProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductsLoaded) {
          return _buildProductListView(state.products);
        } else if (state is ProductLoadFailed) {
          return Center(child: Text(state.error.toString()));
        } else {
          return const Center(child: Text('Unknown state'));
        }
      },
    );
  }

  _buildProductListView(ProductListEntity? products) {
    return ListView.builder(
      itemCount: products?.products.length,
      itemBuilder: (context, index) {
        final product = products?.products[index];
        return ListTile(
          title: Text(product?.title ?? 'No name'),
          // subtitle: Text(product?.description ?? 'No description'),
        );
      },
    );
  }
}
