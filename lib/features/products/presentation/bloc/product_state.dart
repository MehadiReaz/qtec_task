import 'package:equatable/equatable.dart';
import 'package:qtec_task/features/products/domain/entities/product.dart';
import 'package:dio/dio.dart';

abstract class ProductState extends Equatable {
  final ProductListEntity? products;
  final DioException? error;

  const ProductState({this.products, this.error});

  @override
  List<Object?> get props => [products, error];
}

class ProductsLoading extends ProductState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductState {
  const ProductsLoaded(ProductListEntity? products) : super(products: products);
}

class ProductLoadFailed extends ProductState {
  const ProductLoadFailed(DioException error) : super(error: error);
}
