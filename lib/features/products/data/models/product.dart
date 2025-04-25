import '../../domain/entities/product.dart';

class ProductListModel extends ProductListEntity {
  const ProductListModel({
    required super.products,
    required super.total,
    required super.skip,
    required super.limit,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) {
    return ProductListModel(
      products: (json['products'] as List<dynamic>)
          .map((productJson) => ProductModel.fromJson(productJson))
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }
}

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    super.title,
    super.description,
    super.category,
    super.price,
    super.discountPercentage,
    super.rating,
    super.stock,
    super.sku,
    super.warrantyInformation,
    super.shippingInformation,
    super.availabilityStatus,
    super.reviews,
    super.returnPolicy,
    super.minimumOrderQuantity,
    super.images,
    super.thumbnail,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] as int,
      sku: json['sku'] as String,
      warrantyInformation: json['warrantyInformation'] as String,
      shippingInformation: json['shippingInformation'] as String,
      availabilityStatus: json['availabilityStatus'] as String,
      reviews: (json['reviews'] as List<dynamic>)
          .map((review) => ReviewEntity(
                rating: review['rating'] as int,
                comment: review['comment'] as String,
                date: review['date'] as String,
                reviewerName: review['reviewerName'] as String,
                reviewerEmail: review['reviewerEmail'] as String,
              ))
          .toList(),
      returnPolicy: json['returnPolicy'] as String,
      minimumOrderQuantity: json['minimumOrderQuantity'] as int,
      images: (json['images'] as List<dynamic>).cast<String>(),
      thumbnail: json['thumbnail'] as String,
    );
  }
}
