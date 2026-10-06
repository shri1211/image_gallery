import '../../../core/config/app_constants.dart';
import '../../../core/config/app_env.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../datasources/remote/pixabay_api_service.dart';
import '../models/pixabay_response_model.dart';
import '../models/pixabay_image_model.dart';
import '../../../domain/entities/gallery_image.dart';
import '../../../domain/entities/paged_images.dart';
import '../../../domain/repositories/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  ImageRepositoryImpl(this._api, {String? apiKey})
    : _apiKey = apiKey ?? AppEnv.pixabayApiKey;

  final PixabayApiService _api;

  final String _apiKey;

  @override
  Future<Result<PagedImages>> getImages(ImageQuery query) async {
    if (_apiKey.isEmpty) {
      return const FailureResult<PagedImages>(
        MissingApiKeyFailure(
          'Missing Pixabay API key. '
          'Run with --dart-define=PIXABAY_API_KEY=your_key',
        ),
      );
    }

    try {
      final PixabayResponseModel response = await _api.fetchImages(
        page: query.page,
        query: query.query,
        category: query.category,
        perPage: AppConstants.imagesPerPage,
      );

      final List<GalleryImage> images = response.images
          .map((PixabayImageModel m) => m as GalleryImage)
          .toList();

      return Success<PagedImages>(
        PagedImages(
          images: images,
          page: query.page,
          total: response.totalHits,
          hasMore: query.page * AppConstants.imagesPerPage < response.totalHits,
        ),
      );
    } on RemoteException catch (error) {
      return FailureResult<PagedImages>(_toFailure(error));
    } catch (error) {
      return FailureResult<PagedImages>(
        UnknownFailure('Something unexpected happened while loading images.'),
      );
    }
  }

  Failure _toFailure(RemoteException error) {
    final String? code = error.code;
    final int? status = code == null ? null : int.tryParse(code);
    if (status != null && status >= 400 && status < 600) {
      return ServerFailure(error.message, code: code);
    }
    return NetworkFailure(error.message, code: code);
  }
}
