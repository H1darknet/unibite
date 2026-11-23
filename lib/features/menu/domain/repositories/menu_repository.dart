import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dish_entity.dart';

abstract class MenuRepository {
  Stream<Either<Failure, List<DishEntity>>> watchDishes();
  Future<Either<Failure, void>> addDish(DishEntity dish);
  Future<Either<Failure, void>> updateDish(DishEntity dish);
  Future<Either<Failure, void>> deleteDish(String id);
}