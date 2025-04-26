class ProductSearchParams {
  final String query; // Non-nullable (required)
  final int limit;
  final int skip;
  final String? sort; // Nullable (optional)
  final String? order; // Nullable (optional)

  const ProductSearchParams({
    this.query = '', // Default empty query
    this.limit = 10, // Default limit
    this.skip = 0, // Default skip
    this.sort,
    this.order,
  });
}
