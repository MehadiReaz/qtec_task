import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtec_task/features/products/domain/entities/product.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_events.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_state.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/params/product_search_params.dart';
import '../../domain/params/products_params.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/search_product.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUsecase getProductUsecase;
  final SearchProductsUsecase searchProductsUsecase;

  int skip = 0;
  final int limit = 16;
  bool hasReachedMax = false;
  List<ProductEntity> products = [];

  // Add these properties to track current sorting
  String? currentSortBy;
  String? currentSortOrder;
  String? currentSearchQuery;

  ProductBloc(
    this.getProductUsecase,
    this.searchProductsUsecase,
  ) : super(const ProductsLoading()) {
    on<GetProductsEvent>(_onGetProductsEvent);
    on<LoadMoreProductsEvent>(_onLoadMoreProductsEvent);
    on<SearchProductsEvent>(_onSearchProductsEvent);
    on<SortProductsEvent>(_onSortProductsEvent);
  }

  void _onGetProductsEvent(
      GetProductsEvent event, Emitter<ProductState> emit) async {
    skip = 0;
    hasReachedMax = false;
    products.clear();
    currentSearchQuery = null; // Reset search when getting all products
    emit(const ProductsLoading());

    final params = ProductsParams(
      limit: limit,
      skip: skip,
      sort: currentSortBy,
      order: currentSortOrder,
    );
    final dataState = await getProductUsecase(params: params);

    _handleDataState(dataState, emit);
  }

  void _onLoadMoreProductsEvent(
      LoadMoreProductsEvent event, Emitter<ProductState> emit) async {
    if (hasReachedMax) return;

    emit(ProductsLoaded(products, isLoadingMore: true));

    DataState<ProductListEntity> dataState;

    // Use separate code paths rather than trying to use a conditional expression
    if (currentSearchQuery != null) {
      final params = ProductSearchParams(
        query: currentSearchQuery ?? '',
        limit: limit,
        skip: skip,
        sort: currentSortBy,
        order: currentSortOrder,
      );
      dataState = await searchProductsUsecase(params: params);
    } else {
      final params = ProductsParams(
        limit: limit,
        skip: skip,
        sort: currentSortBy,
        order: currentSortOrder,
      );
      dataState = await getProductUsecase(params: params);
    }

    _handleDataState(dataState, emit);
  }

  void _onSearchProductsEvent(
      SearchProductsEvent event, Emitter<ProductState> emit) async {
    emit(const ProductsLoading());
    products.clear();
    skip = 0;
    hasReachedMax = false;
    currentSearchQuery = event.query;

    final params = ProductSearchParams(
      query: event.query,
      sort: currentSortBy,
      order: currentSortOrder,
    );

    // Here's the fix - pass the parameter as a named parameter
    final dataState = await searchProductsUsecase(params: params);

    if (dataState is DataSuccess && dataState.data != null) {
      products.addAll(dataState.data!.products);
      skip += limit;
      hasReachedMax = dataState.data!.products.length < limit;
      emit(ProductsLoaded(products));
    } else if (dataState is DataFailed) {
      emit(ProductLoadFailed(dataState.error!));
    }
  }

  // New method to handle sorting
  void _onSortProductsEvent(
      SortProductsEvent event, Emitter<ProductState> emit) async {
    // Update current sort settings
    currentSortBy = event.sortBy;
    currentSortOrder = event.order;

    // Reset pagination and reload products
    skip = 0;
    products.clear();
    emit(const ProductsLoading());

    // Handle either search results or all products
    if (currentSearchQuery != null && currentSearchQuery!.isNotEmpty) {
      final params = ProductSearchParams(
        query: currentSearchQuery ?? '',
        limit: limit,
        skip: skip,
        sort: currentSortBy,
        order: currentSortOrder,
      );
      final dataState = await searchProductsUsecase(params: params);
      _handleDataState(dataState, emit);
    } else {
      final params = ProductsParams(
        limit: limit,
        skip: skip,
        sort: currentSortBy,
        order: currentSortOrder,
      );
      final dataState = await getProductUsecase(params: params);
      _handleDataState(dataState, emit);
    }
  }

  void _handleDataState(
      DataState<ProductListEntity> dataState, Emitter<ProductState> emit) {
    if (dataState is DataSuccess && dataState.data != null) {
      skip += limit;
      products.addAll(dataState.data!.products);

      hasReachedMax = dataState.data!.products.length < limit;
      emit(ProductsLoaded(products));
    } else if (dataState is DataFailed) {
      emit(ProductLoadFailed(dataState.error!));
    }
  }
}
