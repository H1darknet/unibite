import '../../domain/entities/dish_entity.dart';

class DishModel extends DishEntity {
  const DishModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.category,
    super.isAvailable,
  });

  factory DishModel.fromEntity(DishEntity e) => DishModel(
        id: e.id,
        name: e.name,
        description: e.description,
        price: e.price,
        imageUrl: e.imageUrl,
        category: e.category,
        isAvailable: e.isAvailable,
      );

  factory DishModel.fromMap(Map<String, dynamic> map, String id) {
    return DishModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      category: DishCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => DishCategory.food,
      ),
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category.name,
        'isAvailable': isAvailable,
      };
}