import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:qtec_task/features/products/domain/repository/product_repository.dart';
import 'package:qtec_task/features/products/domain/usecases/get_products.dart';
import 'features/products/data/data_sources/remote/product_api_service.dart';
import 'features/products/data/repository/product_repository_impl.dart';
import 'features/products/presentation/bloc/product_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setup() async {
  // Register Dio
  getIt.registerSingleton<Dio>(Dio());

  // Register ProductApiService with its implementation
  getIt.registerSingleton<ProductApiService>(ProductApiService(getIt<Dio>()));

  // Register ProductRepository with its implementation
  getIt.registerSingleton<ProductRepository>(
      ProductRepositoryImpl(productApiService: getIt<ProductApiService>()));

  // Register GetProductsUseCase with its implementation
  getIt.registerSingleton<GetProductsUseCase>(
      GetProductsUseCase(getIt<ProductRepository>()));

  // Register ProductBloc
  getIt.registerFactory<ProductBloc>(
      () => ProductBloc(getIt<GetProductsUseCase>()));
}
