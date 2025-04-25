import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repository/product_repository.dart';

class GetProducts implements UseCase<DataState<List<ProductListEntity>>, void> {
  final ProductRepository productRepository;

  GetProducts(this.productRepository);

  @override
  Future<DataState<List<ProductListEntity>>> call(void params) {
    return productRepository.getProducts();
  }
}
