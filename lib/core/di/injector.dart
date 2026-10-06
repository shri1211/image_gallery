import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/favorites_local_data_source.dart';
import '../../data/datasources/local/image_download_data_source.dart';
import '../../data/datasources/remote/pixabay_api_service.dart';
import '../../data/repositories/download_repository_impl.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/image_repository_impl.dart';
import '../../domain/repositories/download_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/usecases/download_image.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_images.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../presentation/bloc/favorites/favorites_cubit.dart';
import '../../presentation/bloc/gallery/gallery_cubit.dart';
import '../../presentation/bloc/image_detail/image_detail_cubit.dart';
import '../../core/config/app_constants.dart';
import '../../core/config/app_env.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  locator.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        contentType: 'application/json',
        headers: const <String, dynamic>{'Accept': 'application/json'},
      ),
    ),
  );

  locator.registerLazySingleton<PixabayApiService>(
    () => PixabayApiService(locator<Dio>()),
  );
  locator.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSource(preferences),
  );
  locator.registerLazySingleton<ImageDownloadDataSource>(
    () => ImageDownloadDataSource(locator<Dio>()),
  );

  locator.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(
      locator<PixabayApiService>(),
      apiKey: AppEnv.pixabayApiKey,
    ),
  );
  locator.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(locator<FavoritesLocalDataSource>()),
  );
  locator.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(locator<ImageDownloadDataSource>()),
  );

  locator.registerLazySingleton<GetImagesUseCase>(
    () => GetImagesUseCase(locator<ImageRepository>()),
  );
  locator.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(locator<FavoritesRepository>()),
  );
  locator.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(locator<FavoritesRepository>()),
  );
  locator.registerLazySingleton<DownloadImageUseCase>(
    () => DownloadImageUseCase(locator<DownloadRepository>()),
  );

  locator.registerFactory<GalleryCubit>(
    () => GalleryCubit(locator<GetImagesUseCase>()),
  );
  locator.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(
      locator<GetFavoritesUseCase>(),
      locator<ToggleFavoriteUseCase>(),
    ),
  );
  locator.registerFactory<ImageDetailCubit>(
    () => ImageDetailCubit(locator<DownloadImageUseCase>()),
  );
}
