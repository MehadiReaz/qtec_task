import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../presentation/bloc/product_bloc.dart';
import '../entities/product.dart';
import '../repository/product_repository.dart';

class SearchProductsUsecase
    implements UseCase<DataState<ProductListEntity>, ProductSearchParams> {
  final ProductRepository productRepository;

  SearchProductsUsecase(this.productRepository);

  @override
  Future<DataState<ProductListEntity>> call({ProductSearchParams? params}) {
    return productRepository.searchProducts(params?.query ?? '');
  }
}
