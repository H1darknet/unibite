import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/menu_repository.dart';

class DeleteDishUseCase {
  final MenuRepository repository;

  DeleteDishUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.deleteDish(id);
}