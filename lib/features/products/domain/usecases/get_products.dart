import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repository/product_repository.dart';

class GetProductsUseCase
    implements UseCase<DataState<ProductListEntity>, void> {
  final ProductRepository productRepository;

  GetProductsUseCase(this.productRepository);

  @override
  Future<DataState<ProductListEntity>> call({void params}) {
    return productRepository.getProducts();
  }
}
