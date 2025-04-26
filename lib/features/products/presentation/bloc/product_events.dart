abstract class ProductEvent {}

class GetProductsEvent extends ProductEvent {}

class LoadMoreProductsEvent extends ProductEvent {}

class SearchProductsEvent extends ProductEvent {
  final String query;

  SearchProductsEvent(this.query);
}
