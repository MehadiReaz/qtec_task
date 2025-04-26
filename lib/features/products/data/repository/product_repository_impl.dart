import 'dart:io';
import 'package:dio/dio.dart';
import 'package:qtec_task/core/resources/data_state.dart';
import 'package:qtec_task/features/products/data/models/product.dart';
import '../../domain/repository/product_repository.dart';
import '../data_sources/remote/product_api_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService productApiService;
  ProductRepositoryImpl({required this.productApiService});

  @override
  Future<DataState<ProductListModel>> getProducts(int? limit, int? skip) async {
    try {
      final httpResponse = await productApiService.getProducts(
        limit: limit,
        skip: skip,
      );
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final productListModel = ProductListModel.fromJson(httpResponse.data);
        return DataSuccess(productListModel);
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

  @override
  Future<DataState<ProductListModel>> searchProducts(String? query) async {
    try {
      final httpResponse = await productApiService.searchProducts(
        query: query ?? '',
      );
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final productListModel = ProductListModel.fromJson(httpResponse.data);
        return DataSuccess(productListModel);
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
