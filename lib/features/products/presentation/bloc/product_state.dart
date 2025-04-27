// Updated product_state.dart file
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductState {
  const ProductsInitial();
}

class ProductsLoading extends ProductState {
  const ProductsLoading();
}

class ProductsRefreshing extends ProductState {
  final List<ProductEntity> currentProducts;
  final Set<String> wishlistedProducts;

  const ProductsRefreshing({
    required this.currentProducts,
    this.wishlistedProducts = const {},
  });

  @override
  List<Object?> get props => [currentProducts, wishlistedProducts];
}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final Set<String> wishlistedProducts;
  final int totalCount;
  final bool isSearchActive;

  const ProductsLoaded(
    this.products, {
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.wishlistedProducts = const {},
    this.totalCount = 0,
    this.isSearchActive = false,
  });

  @override
  List<Object?> get props => [
        products,
        isLoadingMore,
        hasReachedMax,
        wishlistedProducts,
        totalCount,
        isSearchActive,
      ];
}

class ProductsEmpty extends ProductState {
  final Set<String> wishlistedProducts;

  const ProductsEmpty({this.wishlistedProducts = const {}});

  @override
  List<Object?> get props => [wishlistedProducts];
}

class ProductLoadFailed extends ProductState {
  final Exception error;

  const ProductLoadFailed(this.error);

  @override
  List<Object?> get props => [error];
}
