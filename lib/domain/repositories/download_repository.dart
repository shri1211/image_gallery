import '../../core/error/result.dart';
import '../entities/gallery_image.dart';

typedef DownloadProgressCallback = void Function(double progress);

abstract class DownloadRepository {
  Future<Result<String>> download(
    GalleryImage image,
    DownloadProgressCallback onProgress,
  );
}
