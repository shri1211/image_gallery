import '../../core/error/result.dart';
import '../entities/gallery_image.dart';

abstract class FavoritesRepository {
  Future<Result<List<GalleryImage>>> getFavorites();

  Future<Result<bool>> isFavorite(int imageId);

  Future<Result<bool>> toggleFavorite(GalleryImage image);
}
