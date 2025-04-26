import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../params/product_search_params.dart';
import '../repository/product_repository.dart';

class SearchProductsUsecase
    implements UseCase<DataState<ProductListEntity>, ProductSearchParams> {
  final ProductRepository productRepository;

  SearchProductsUsecase(this.productRepository);

  @override
  Future<DataState<ProductListEntity>> call({ProductSearchParams? params}) {
    // Provide defaults for null parameters
    final effectiveParams = params ?? ProductSearchParams();

    return productRepository.searchProducts(
      effectiveParams.query, // Default query to empty string
      limit: effectiveParams.limit, // Default limit
      skip: effectiveParams.skip, // Default skip
      sort: effectiveParams.sort,
      order: effectiveParams.order,
    );
  }
}
