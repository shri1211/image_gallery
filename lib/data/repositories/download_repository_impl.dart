import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../datasources/local/image_download_data_source.dart';
import '../../../domain/entities/gallery_image.dart';
import '../../../domain/repositories/download_repository.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  DownloadRepositoryImpl(this._dataSource);

  final ImageDownloadDataSource _dataSource;

  @override
  Future<Result<String>> download(
    GalleryImage image,
    DownloadProgressCallback onProgress,
  ) async {
    try {
      final String savedAt = await _dataSource.download(image, onProgress);
      return Success<String>(savedAt);
    } on PermissionException catch (error) {
      return FailureResult<String>(PermissionFailure(error.message));
    } on DownloadException catch (error) {
      return FailureResult<String>(
        DownloadFailure(error.message, code: error.code),
      );
    } catch (error) {
      return FailureResult<String>(
        const DownloadFailure('Download failed. Please try again.'),
      );
    }
  }
}
