import 'package:equatable/equatable.dart';

import '../../../menu/domain/entities/dish_entity.dart';

class CartItem extends Equatable {
  final DishEntity dish;
  final int quantity;

  const CartItem({required this.dish, this.quantity = 1});

  double get total => dish.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(dish: dish, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [dish, quantity];
}