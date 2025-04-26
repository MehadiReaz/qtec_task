import 'package:qtec_task/core/constants/constants.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'product_api_service.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class ProductApiService {
  factory ProductApiService(Dio dio, {String baseUrl}) = _ProductApiService;

  @GET(products)
  Future<HttpResponse> getProducts({
    @Query('limit') int? limit,
    @Query('skip') int? skip,
    @Query('select') String? select,
    @Query('sortBy') String? sort, // Add this parameter
    @Query('order') String? order, // Add this parameter
  });

  @GET(search)
  Future<HttpResponse> searchProducts({
    @Query('q') required String query,
    @Query('limit') int? limit, // Optional: add pagination to search as well
    @Query('skip') int? skip, // Optional: add pagination to search as well
    @Query('sortBy') String? sort, // Optional: add sorting to search
    @Query('order') String? order, // Optional: add ordering to search
  });
}
