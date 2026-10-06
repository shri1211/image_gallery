import '../../core/error/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/gallery_image.dart';
import '../repositories/download_repository.dart';

class DownloadImageUseCase extends UseCase<Result<String>, DownloadParams> {
  DownloadImageUseCase(this._repository);

  final DownloadRepository _repository;

  @override
  Future<Result<String>> call(DownloadParams params) {
    return _repository.download(params.image, params.onProgress);
  }
}

class DownloadParams {
  const DownloadParams({required this.image, required this.onProgress});

  final GalleryImage image;
  final DownloadProgressCallback onProgress;
}
