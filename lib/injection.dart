import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/menu/data/datasources/menu_remote_datasource.dart';
import 'features/menu/data/repositories/menu_repository_impl.dart';
import 'features/menu/domain/repositories/menu_repository.dart';
import 'features/menu/domain/usecases/add_dish_usecase.dart';
import 'features/menu/domain/usecases/delete_dish_usecase.dart';
import 'features/menu/domain/usecases/update_dish_usecase.dart';
import 'features/menu/domain/usecases/watch_dishes_usecase.dart';
import 'features/menu/presentation/providers/menu_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Tashqi kutubxonalar
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Auth: datasource -> repository -> usecase -> provider
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerFactory(
    () => AuthProvider(
      login: sl(),
      register: sl(),
      logout: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Menu: datasource -> repository -> usecase -> provider
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MenuRepository>(() => MenuRepositoryImpl(sl()));

  sl.registerLazySingleton(() => WatchDishesUseCase(sl()));
  sl.registerLazySingleton(() => AddDishUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDishUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDishUseCase(sl()));

  sl.registerFactory(
    () => MenuProvider(
      watchDishes: sl(),
      addDish: sl(),
      updateDish: sl(),
      deleteDish: sl(),
    ),
  );

  // Cart: bazasiz, faqat xotirada (datasource va repository kerak emas)
  sl.registerFactory(() => CartProvider());
}