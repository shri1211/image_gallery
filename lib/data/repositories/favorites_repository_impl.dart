import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../datasources/local/favorites_local_data_source.dart';
import '../models/pixabay_image_model.dart';
import '../../../domain/entities/gallery_image.dart';
import '../../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._dataSource);

  final FavoritesLocalDataSource _dataSource;

  @override
  Future<Result<List<GalleryImage>>> getFavorites() async {
    try {
      final List<GalleryImage> favorites = _dataSource
          .readAll()
          .map((PixabayImageModel m) => m as GalleryImage)
          .toList();
      return Success<List<GalleryImage>>(favorites);
    } on CacheException catch (error) {
      return FailureResult<List<GalleryImage>>(CacheFailure(error.message));
    } catch (error) {
      return FailureResult<List<GalleryImage>>(
        const CacheFailure('Favorites could not be loaded.'),
      );
    }
  }

  @override
  Future<Result<bool>> isFavorite(int imageId) async {
    try {
      final bool found = _dataSource.readAll().any(
        (PixabayImageModel m) => m.id == imageId,
      );
      return Success<bool>(found);
    } on CacheException catch (error) {
      return FailureResult<bool>(CacheFailure(error.message));
    }
  }

  @override
  Future<Result<bool>> toggleFavorite(GalleryImage image) async {
    try {
      final List<PixabayImageModel> current = List<PixabayImageModel>.of(
        _dataSource.readAll(),
      );
      final int index = current.indexWhere(
        (PixabayImageModel m) => m.id == image.id,
      );

      final bool nowFavourite;
      if (index >= 0) {
        current.removeAt(index);
        nowFavourite = false;
      } else {
        current.insert(0, PixabayImageModel.fromEntity(image));
        nowFavourite = true;
      }

      await _dataSource.writeAll(current);
      return Success<bool>(nowFavourite);
    } on CacheException catch (error) {
      return FailureResult<bool>(CacheFailure(error.message));
    } catch (error) {
      return FailureResult<bool>(
        const CacheFailure('The favorite could not be saved.'),
      );
    }
  }
}
