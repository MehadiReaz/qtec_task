import '../../domain/entities/product.dart';

class ProductModel extends ProductEntity {
  const ProductModel(
      {required super.price,
      required super.rating,
      required super.id,
      required super.title,
      required super.thumbnail,
      required super.discountPercentage});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      price: json['price'].toDouble(),
      rating: json['rating'].toDouble(),
      discountPercentage: json['discountPercentage'].toDouble(),
    );
  }
}
