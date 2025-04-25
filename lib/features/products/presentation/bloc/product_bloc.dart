import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtec_task/features/products/domain/entities/product.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_events.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_state.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/usecases/get_products.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUsecase getProductUsecase;

  int skip = 0;
  final int limit = 16;
  bool hasReachedMax = false;
  List<ProductEntity> products = [];

  ProductBloc(this.getProductUsecase) : super(const ProductsLoading()) {
    on<GetProductsEvent>(_onGetProductsEvent);
    on<LoadMoreProductsEvent>(_onLoadMoreProductsEvent);
  }

  void _onGetProductsEvent(
      GetProductsEvent event, Emitter<ProductState> emit) async {
    skip = 0;
    hasReachedMax = false;
    products.clear();
    emit(const ProductsLoading());

    final params = ProductsParams(limit: limit, skip: skip);
    final dataState = await getProductUsecase(params: params);

    _handleDataState(dataState, emit);
  }

  void _onLoadMoreProductsEvent(
      LoadMoreProductsEvent event, Emitter<ProductState> emit) async {
    if (hasReachedMax) return;

    emit(ProductsLoaded(products, isLoadingMore: true));

    final params = ProductsParams(limit: limit, skip: skip);
    final dataState = await getProductUsecase(params: params);

    _handleDataState(dataState, emit);
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

class ProductsParams {
  final int limit;
  final int skip;

  ProductsParams({
    required this.limit,
    required this.skip,
  });
}
