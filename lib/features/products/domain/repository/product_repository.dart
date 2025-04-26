import 'package:qtec_task/core/resources/data_state.dart';

import '../entities/product.dart';

abstract class ProductRepository {
  Future<DataState<ProductListEntity>> getProducts(int? limit, int? skip,
      {String? sort, String? order});

  Future<DataState<ProductListEntity>> searchProducts(String? query,
      {int? limit, int? skip, String? sort, String? order});
}
