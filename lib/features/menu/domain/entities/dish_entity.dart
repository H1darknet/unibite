import 'package:equatable/equatable.dart';

enum DishCategory {
  food('Taomlar'),
  drink('Ichimliklar'),
  dessert('Shirinliklar');

  final String label;
  const DishCategory(this.label);
}

class DishEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final DishCategory category;
  final bool isAvailable;

  const DishEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props =>
      [id, name, description, price, imageUrl, category, isAvailable];
}