import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dish_entity.dart';
import '../../domain/usecases/add_dish_usecase.dart';
import '../../domain/usecases/delete_dish_usecase.dart';
import '../../domain/usecases/update_dish_usecase.dart';
import '../../domain/usecases/watch_dishes_usecase.dart';

class MenuProvider extends ChangeNotifier {
  final WatchDishesUseCase _watchDishes;
  final AddDishUseCase _addDish;
  final UpdateDishUseCase _updateDish;
  final DeleteDishUseCase _deleteDish;

  MenuProvider({
    required this._watchDishes,
    required this._addDish,
    required this._updateDish,
    required this._deleteDish,
  });

  StreamSubscription<Either<Failure, List<DishEntity>>>? _subscription;
  List<DishEntity> _dishes = [];
  DishCategory? _selectedCategory;
  bool _isLoading = true;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DishCategory? get selectedCategory => _selectedCategory;

  /// Tanlangan kategoriya bo'yicha saralangan taomlar.
  List<DishEntity> get dishes => _selectedCategory == null
      ? _dishes
      : _dishes.where((d) => d.category == _selectedCategory).toList();

  DishEntity? findById(String id) {
    for (final dish in _dishes) {
      if (dish.id == id) return dish;
    }
    return null;
  }

  /// Menyu ekrani ochilganda chaqiriladi (foydalanuvchi kirgandan keyin).
  void startListening() {
    _subscription?.cancel();
    _isLoading = true;
    _subscription = _watchDishes().listen((result) {
      result.fold(
        (failure) => _error = failure.message,
        (dishes) {
          _dishes = dishes;
          _error = null;
        },
      );
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectCategory(DishCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Xato bo'lsa xabar matnini, muvaffaqiyatli bo'lsa null qaytaradi.
  Future<String?> addDish(DishEntity dish) async {
    final result = await _addDish(dish);
    return result.fold<String?>((f) => f.message, (_) => null);
  }

  Future<String?> updateDish(DishEntity dish) async {
    final result = await _updateDish(dish);
    return result.fold<String?>((f) => f.message, (_) => null);
  }

  Future<String?> deleteDish(String id) async {
    final result = await _deleteDish(id);
    return result.fold<String?>((f) => f.message, (_) => null);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}