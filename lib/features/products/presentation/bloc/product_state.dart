import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductsLoading extends ProductState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;
  final bool isLoadingMore;

  const ProductsLoaded(
    this.products, {
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [products, isLoadingMore];
}

class ProductLoadFailed extends ProductState {
  final DioException error;

  const ProductLoadFailed(this.error);

  @override
  List<Object?> get props => [error];
}
