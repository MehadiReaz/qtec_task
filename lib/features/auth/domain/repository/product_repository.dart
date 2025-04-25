import 'package:qtec_task/core/resources/data_state.dart';

import '../entities/product.dart';

abstract class ProductRepository {
  Future<DataState<List<ProductEntity>>> getProducts();
}
