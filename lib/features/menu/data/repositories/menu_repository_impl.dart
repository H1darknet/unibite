import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../../../../core/error/failures.dart';
import '../../domain/entities/dish_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';
import '../models/dish_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remote;

  MenuRepositoryImpl(this.remote);

  @override
  Stream<Either<Failure, List<DishEntity>>> watchDishes() {
    return remote.watchDishes().transform(
          StreamTransformer<List<DishModel>,
              Either<Failure, List<DishEntity>>>.fromHandlers(
            handleData: (dishes, sink) => sink.add(Right(dishes)),
            handleError: (error, stackTrace, sink) =>
                sink.add(Left(_failure(error))),
          ),
        );
  }

  @override
  Future<Either<Failure, void>> addDish(DishEntity dish) =>
      _guard(() => remote.addDish(DishModel.fromEntity(dish)));

  @override
  Future<Either<Failure, void>> updateDish(DishEntity dish) =>
      _guard(() => remote.updateDish(DishModel.fromEntity(dish)));

  @override
  Future<Either<Failure, void>> deleteDish(String id) =>
      _guard(() => remote.deleteDish(id));

  Future<Either<Failure, void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(null);
    } catch (e) {
      return Left(_failure(e));
    }
  }

  Failure _failure(Object error) {
    if (error is FirebaseException) {
      return ServerFailure(error.message ?? 'Server xatosi yuz berdi');
    }
    return const ServerFailure();
  }
}