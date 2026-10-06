import '../../core/error/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/paged_images.dart';
import '../repositories/image_repository.dart';

class GetImagesUseCase extends UseCase<Result<PagedImages>, ImageQuery> {
  GetImagesUseCase(this._repository);

  final ImageRepository _repository;

  @override
  Future<Result<PagedImages>> call(ImageQuery params) =>
      _repository.getImages(params);
}
