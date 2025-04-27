import 'dart:async';
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
  final int limit = 10;
  bool hasReachedMax = false;
  List<ProductEntity> products = [];

  Set<String> wishlistedProducts = {};

  bool isLoadingMore = false;

  String? currentSortBy;
  String? currentSortOrder;
  String? currentSearchQuery;

  Timer? _searchDebounce;

  ProductBloc(
    this.getProductUsecase,
    this.searchProductsUsecase,
  ) : super(const ProductsInitial()) {
    on<InitProductsEvent>(_onInitProductsEvent);
    on<GetProductsEvent>(_onGetProductsEvent);
    on<LoadMoreProductsEvent>(_onLoadMoreProductsEvent);
    on<SearchProductsEvent>(_onSearchProductsEvent);
    on<DebounceSearchEvent>(_onDebounceSearchEvent);
    on<SortProductsEvent>(_onSortProductsEvent);
    on<RefreshProductsEvent>(_onRefreshProductsEvent);
    on<WishlistToggleEvent>(_onWishlistToggleEvent);
  }

  void _onInitProductsEvent(
      InitProductsEvent event, Emitter<ProductState> emit) async {
    emit(const ProductsInitial());
  }

  void _onGetProductsEvent(
      GetProductsEvent event, Emitter<ProductState> emit) async {
    skip = 0;
    hasReachedMax = false;
    isLoadingMore = false;
    products.clear();
    currentSearchQuery = null; // Clear search query
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
    if (hasReachedMax || isLoadingMore || state is! ProductsLoaded) return;

    isLoadingMore = true;
    emit(ProductsLoaded(products,
        isLoadingMore: true, wishlistedProducts: wishlistedProducts));

    DataState<ProductListEntity> dataState;

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

    isLoadingMore = false;
    _handleDataState(dataState, emit);
  }

  void _onDebounceSearchEvent(
      DebounceSearchEvent event, Emitter<ProductState> emit) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(SearchProductsEvent(event.query));
    });
  }

  void _onSearchProductsEvent(
      SearchProductsEvent event, Emitter<ProductState> emit) async {
    emit(const ProductsLoading());
    products.clear();
    skip = 0;
    hasReachedMax = false;
    isLoadingMore = false;
    currentSearchQuery = event.query;

    if (event.query.isEmpty) {
      add(GetProductsEvent());
      return;
    }

    final params = ProductSearchParams(
      query: event.query,
      limit: limit,
      skip: skip,
      sort: currentSortBy,
      order: currentSortOrder,
    );

    final dataState = await searchProductsUsecase(params: params);

    if (dataState is DataSuccess && dataState.data != null) {
      products.addAll(dataState.data!.products);
      skip += limit;
      hasReachedMax = dataState.data!.products.length < limit;

      // Get the total count from the API response
      final int totalItems = dataState.data!.total;

      if (products.isEmpty) {
        emit(ProductsEmpty(wishlistedProducts: wishlistedProducts));
      } else {
        emit(ProductsLoaded(
          products,
          wishlistedProducts: wishlistedProducts,
          hasReachedMax: hasReachedMax,
          totalCount: totalItems, // Pass the total count
          isSearchActive: true, // This is a search result
        ));
      }
    } else if (dataState is DataFailed) {
      emit(ProductLoadFailed(dataState.error!));
    }
  }

  void _onRefreshProductsEvent(
      RefreshProductsEvent event, Emitter<ProductState> emit) async {
    // Emit initial ProductsRefreshing state WITH shimmer (no products shown yet)
    emit(const ProductsRefreshing(
      currentProducts: [],
      wishlistedProducts: {},
    ));

    skip = 0;
    hasReachedMax = false;
    isLoadingMore = false;
    products.clear();

    DataState<ProductListEntity> dataState;

    if (currentSearchQuery != null && currentSearchQuery!.isNotEmpty) {
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

  void _onSortProductsEvent(
      SortProductsEvent event, Emitter<ProductState> emit) async {
    currentSortBy = event.sortBy;
    currentSortOrder = event.order;

    skip = 0;
    products.clear();
    hasReachedMax = false;
    isLoadingMore = false;

    // Get search active status before emitting loading state
    bool isSearching =
        currentSearchQuery != null && currentSearchQuery!.isNotEmpty;

    emit(const ProductsLoading());

    if (isSearching) {
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

  void _onWishlistToggleEvent(
      WishlistToggleEvent event, Emitter<ProductState> emit) {
    final newWishlistedProducts = Set<String>.from(wishlistedProducts);

    if (newWishlistedProducts.contains(event.productId)) {
      newWishlistedProducts.remove(event.productId);
    } else {
      newWishlistedProducts.add(event.productId);
    }

    wishlistedProducts = newWishlistedProducts;

    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      emit(ProductsLoaded(
        currentState.products,
        isLoadingMore: currentState.isLoadingMore,
        hasReachedMax: currentState.hasReachedMax,
        wishlistedProducts: newWishlistedProducts,
        totalCount: currentState.totalCount, // Preserve total count
        isSearchActive: currentState.isSearchActive, // Preserve search status
      ));
    } else if (state is ProductsRefreshing) {
      final currentState = state as ProductsRefreshing;
      emit(ProductsRefreshing(
        currentProducts: currentState.currentProducts,
        wishlistedProducts: newWishlistedProducts,
      ));
    } else if (state is ProductsEmpty) {
      emit(ProductsEmpty(wishlistedProducts: newWishlistedProducts));
    }
  }

  void _handleDataState(
      DataState<ProductListEntity> dataState, Emitter<ProductState> emit) {
    if (dataState is DataSuccess && dataState.data != null) {
      skip += limit;
      products.addAll(dataState.data!.products);

      hasReachedMax = dataState.data!.products.length < limit;

      // Store the total from the API response
      final int totalItems = dataState.data!.total;

      if (products.isEmpty) {
        emit(ProductsEmpty(wishlistedProducts: wishlistedProducts));
      } else {
        emit(ProductsLoaded(
          products,
          isLoadingMore: false,
          hasReachedMax: hasReachedMax,
          wishlistedProducts: wishlistedProducts,
          totalCount: totalItems, // Pass the total count
          isSearchActive: currentSearchQuery != null &&
              currentSearchQuery!.isNotEmpty, // Set search status
        ));
      }
    } else if (dataState is DataFailed) {
      emit(ProductLoadFailed(dataState.error!));
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
