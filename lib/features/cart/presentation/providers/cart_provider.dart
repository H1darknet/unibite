import 'package:flutter/foundation.dart';

import '../../../menu/domain/entities/dish_entity.dart';
import '../../domain/entities/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  DateTime? _pickupTime;

  List<CartItem> get items => List.unmodifiable(_items);
  DateTime? get pickupTime => _pickupTime;
  bool get isEmpty => _items.isEmpty;

  int get totalCount => _items.fold<int>(0, (sum, i) => sum + i.quantity);
  double get totalPrice => _items.fold<double>(0, (sum, i) => sum + i.total);

  void add(DishEntity dish) {
    final index = _items.indexWhere((i) => i.dish.id == dish.id);
    if (index == -1) {
      _items.add(CartItem(dish: dish));
    } else {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    }
    notifyListeners();
  }

  void increase(String dishId) {
    final index = _items.indexWhere((i) => i.dish.id == dishId);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    notifyListeners();
  }

  void decrease(String dishId) {
    final index = _items.indexWhere((i) => i.dish.id == dishId);
    if (index == -1) return;
    if (_items[index].quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity - 1);
    }
    notifyListeners();
  }

  void remove(String dishId) {
    _items.removeWhere((i) => i.dish.id == dishId);
    notifyListeners();
  }

  void setPickupTime(DateTime? time) {
    _pickupTime = time;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _pickupTime = null;
    notifyListeners();
  }
}