import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dish_entity.dart';
import '../repositories/menu_repository.dart';

class AddDishUseCase {
  final MenuRepository repository;

  AddDishUseCase(this.repository);

  Future<Either<Failure, void>> call(DishEntity dish) =>
      repository.addDish(dish);
}