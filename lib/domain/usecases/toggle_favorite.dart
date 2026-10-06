import '../../core/error/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/gallery_image.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavoriteUseCase extends UseCase<Result<bool>, GalleryImage> {
  ToggleFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Result<bool>> call(GalleryImage params) =>
      _repository.toggleFavorite(params);
}
