import 'dart:io';
import 'package:dio/dio.dart';
import 'package:qtec_task/core/resources/data_state.dart';
import 'package:qtec_task/features/auth/data/models/product.dart';
import '../../domain/repository/product_repository.dart';
import '../data_sources/remote/product_api_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService productApiService;
  ProductRepositoryImpl({required this.productApiService});

  @override
  Future<DataState<List<ProductListModel>>> getProducts() async {
    try {
      final httpResponse = await productApiService.getProducts(
        limit: 10,
        skip: 0,
        select: 'id,title,thumbnail,price,rating,discountPercentage',
      );
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(DioException(
          error: 'Error: ${httpResponse.response.statusCode}',
          response: httpResponse.response,
          type: DioExceptionType.badResponse,
          message: 'Error: ${httpResponse.response.statusCode}',
          requestOptions: httpResponse.response.requestOptions,
        ));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
