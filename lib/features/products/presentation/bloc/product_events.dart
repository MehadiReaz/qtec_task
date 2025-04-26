import '../../domain/entities/product.dart';

abstract class ProductEvent {}

class InitProductsEvent extends ProductEvent {}

class GetProductsEvent extends ProductEvent {}

class LoadMoreProductsEvent extends ProductEvent {}

class DebounceSearchEvent extends ProductEvent {
  final String query;

  DebounceSearchEvent(this.query);
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  SearchProductsEvent(this.query);
}

class SortProductsEvent extends ProductEvent {
  final String sortBy;
  final String order;

  SortProductsEvent({
    required this.sortBy,
    this.order = 'asc',
  });
}

class RefreshProductsEvent extends ProductEvent {
  final List<ProductEntity> currentProducts;

  RefreshProductsEvent({this.currentProducts = const []});
}

class WishlistToggleEvent extends ProductEvent {
  final String productId;

  WishlistToggleEvent({required this.productId});

  List<Object?> get props => [productId];
}
