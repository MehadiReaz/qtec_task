import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../presentation/bloc/product_bloc.dart';
import '../entities/product.dart';
import '../repository/product_repository.dart';

class GetProductsUsecase
    implements UseCase<DataState<ProductListEntity>, ProductsParams> {
  final ProductRepository productRepository;

  GetProductsUsecase(this.productRepository);

  @override
  Future<DataState<ProductListEntity>> call({ProductsParams? params}) {
    return productRepository.getProducts(
      params?.limit ?? 10,
      params?.skip ?? 0,
    );
  }
}
