import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:qtec_task/features/products/domain/repository/product_repository.dart';
import 'package:qtec_task/features/products/domain/usecases/get_products.dart';
import 'features/products/data/data_sources/remote/product_api_service.dart';
import 'features/products/data/repository/product_repository_impl.dart';
import 'features/products/domain/usecases/search_product.dart';
import 'features/products/presentation/bloc/product_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setup() async {
  // Register Dio
  getIt.registerSingleton<Dio>(Dio());

  // Register ProductApiService
  getIt.registerSingleton<ProductApiService>(
    ProductApiService(getIt<Dio>()),
  );

  // Register ProductRepository
  getIt.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(productApiService: getIt<ProductApiService>()),
  );

  // Register GetProductsUsecase
  getIt.registerSingleton<GetProductsUsecase>(
    GetProductsUsecase(getIt<ProductRepository>()),
  );

  // Register SearchProductsUsecase
  getIt.registerSingleton<SearchProductsUsecase>(
    SearchProductsUsecase(getIt<ProductRepository>()),
  );

  // Register ProductBloc with both usecases
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(
      getIt<GetProductsUsecase>(),
      getIt<SearchProductsUsecase>(),
    ),
  );
}
