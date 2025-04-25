import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String title;
  final String thumbnail;
  final double price;
  final double rating;
  final num discountPercentage;

  const ProductEntity({
    required this.price,
    required this.rating,
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.discountPercentage,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        thumbnail,
        price,
        rating,
        discountPercentage,
      ];
}
