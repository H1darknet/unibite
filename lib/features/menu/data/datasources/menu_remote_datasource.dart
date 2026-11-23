import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dish_model.dart';

abstract class MenuRemoteDataSource {
  Stream<List<DishModel>> watchDishes();
  Future<void> addDish(DishModel dish);
  Future<void> updateDish(DishModel dish);
  Future<void> deleteDish(String id);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final FirebaseFirestore firestore;

  MenuRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _dishes =>
      firestore.collection('dishes');

  @override
  Stream<List<DishModel>> watchDishes() {
    return _dishes.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => DishModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  @override
  Future<void> addDish(DishModel dish) async {
    await _dishes.add(dish.toMap());
  }

  @override
  Future<void> updateDish(DishModel dish) async {
    await _dishes.doc(dish.id).update(dish.toMap());
  }

  @override
  Future<void> deleteDish(String id) async {
    await _dishes.doc(id).delete();
  }
}