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
  });

  @GET(search)
  Future<HttpResponse> searchProducts({
    @Query('q') required String query,
  });
}
