import 'dart:io';
import 'package:dio/dio.dart';
import 'package:qtec_task/core/resources/data_state.dart';
import 'package:qtec_task/features/products/data/models/product.dart';
import '../../domain/repository/product_repository.dart';
import '../data_sources/remote/product_api_service.dart';
import 'package:logger/logger.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService productApiService;
  final Logger _logger = Logger(); // Initialize logger

  ProductRepositoryImpl({required this.productApiService});

  @override
  Future<DataState<ProductListModel>> getProducts(int? limit, int? skip,
      {String? sort, String? order}) async {
    try {
      final httpResponse = await productApiService.getProducts(
        limit: limit,
        skip: skip,
        sort: sort,
        order: order,
      );
      // Log the response data
      _logger.d('getProducts Response: ${httpResponse.data}');
      final requestUri = httpResponse.response.requestOptions.uri;
      _logger.d('API URL (getProducts): $requestUri');

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
      // Log the error
      _logger.e('getProducts Error: $e');
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ProductListModel>> searchProducts(String? query,
      {int? limit, int? skip, String? sort, String? order}) async {
    try {
      final httpResponse = await productApiService.searchProducts(
        query: query ?? '',
        limit: limit,
        skip: skip,
        sort: sort,
        order: order,
      );
      // Log the response data
      _logger.d('searchProducts Response: ${httpResponse.data}');

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
      // Log the error
      _logger.e('searchProducts Error: $e');
      return DataFailed(e);
    }
  }
}
