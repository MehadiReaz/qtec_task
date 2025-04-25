import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_events.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_state.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/usecases/get_products.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductUsecase;

  ProductBloc(this.getProductUsecase) : super(const ProductsLoading()) {
    on<GetProductsEvent>(onGetProductsEvent);
  }

  void onGetProductsEvent(
      GetProductsEvent event, Emitter<ProductState> emit) async {
    final dataState = await getProductUsecase();
    if (dataState is DataSuccess && dataState.data != null) {
      if (dataState.data != null) {
        emit(ProductsLoaded(dataState.data));
      } else {
        emit(ProductLoadFailed(dataState.error!));
        return;
      }
    }
  }
}
