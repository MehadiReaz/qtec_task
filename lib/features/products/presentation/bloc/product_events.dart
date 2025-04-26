abstract class ProductEvent {}

class GetProductsEvent extends ProductEvent {}

class LoadMoreProductsEvent extends ProductEvent {}

class SearchProductsEvent extends ProductEvent {
  final String query;

  SearchProductsEvent(this.query);
}

class SortProductsEvent extends ProductEvent {
  final String sortBy;
  final String order;

  SortProductsEvent({
    required this.sortBy,
    this.order = 'asc', // Default to ascending order
  });
}
