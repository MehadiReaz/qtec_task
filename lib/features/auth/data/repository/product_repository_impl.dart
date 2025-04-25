import 'package:qtec_task/core/resources/data_state.dart';
import 'package:qtec_task/features/auth/data/models/product.dart';
import '../../domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<DataState<List<ProductModel>>> getProducts() {
    // TODO: implement getProducts
    throw UnimplementedError();
  }
}
