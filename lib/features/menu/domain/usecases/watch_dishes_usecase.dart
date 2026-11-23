import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dish_entity.dart';
import '../repositories/menu_repository.dart';

class WatchDishesUseCase {
  final MenuRepository repository;

  WatchDishesUseCase(this.repository);

  Stream<Either<Failure, List<DishEntity>>> call() => repository.watchDishes();
}