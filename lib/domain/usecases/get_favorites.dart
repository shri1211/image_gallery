import '../../core/error/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/gallery_image.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase
    extends UseCase<Result<List<GalleryImage>>, NoParams> {
  GetFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Result<List<GalleryImage>>> call(NoParams params) =>
      _repository.getFavorites();
}
