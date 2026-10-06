import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/core/error/exceptions.dart';
import 'package:image_gallery/core/error/failures.dart';
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/data/datasources/remote/pixabay_api_service.dart';
import 'package:image_gallery/data/models/pixabay_response_model.dart';
import 'package:image_gallery/data/models/pixabay_image_model.dart';
import 'package:image_gallery/data/repositories/image_repository_impl.dart';
import 'package:image_gallery/domain/entities/paged_images.dart';
import 'package:image_gallery/domain/repositories/image_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';

class _MockApiService extends Mock implements PixabayApiService {}

void main() {
  late _MockApiService api;
  late ImageRepositoryImpl repository;

  setUp(() {
    api = _MockApiService();
    repository = ImageRepositoryImpl(api, apiKey: 'test-key');
  });

  test('returns a missing-key failure when no api key is configured', () async {
    repository = ImageRepositoryImpl(api, apiKey: '');

    final Result<PagedImages> result = await repository.getImages(
      const ImageQuery(page: 1),
    );

    expect(result, isA<FailureResult<PagedImages>>());
    expect(
      (result as FailureResult<PagedImages>).failure,
      isA<MissingApiKeyFailure>(),
    );
  });

  test('maps a successful response into paged result', () async {
    when(
      () => api.fetchImages(
        page: any(named: 'page'),
        query: any(named: 'query'),
        category: any(named: 'category'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer(
      (_) async => PixabayResponseModel(
        total: 200,
        totalHits: 200,
        images: <PixabayImageModel>[
          PixabayImageModel.fromJson(pixabayJson(id: 1)),
          PixabayImageModel.fromJson(pixabayJson(id: 2)),
        ],
      ),
    );

    final Result<PagedImages> result = await repository.getImages(
      const ImageQuery(page: 1),
    );

    expect(result, isA<Success<PagedImages>>());
    final PagedImages data = (result as Success<PagedImages>).data;
    expect(data.images, hasLength(2));
    expect(data.page, 1);
    expect(data.hasMore, isTrue);
  });

  test('reports hasMore = false when the last page is reached', () async {
    when(
      () => api.fetchImages(
        page: any(named: 'page'),
        query: any(named: 'query'),
        category: any(named: 'category'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer(
      (_) async => PixabayResponseModel(
        total: 40,
        totalHits: 40,
        images: <PixabayImageModel>[PixabayImageModel.fromJson(pixabayJson())],
      ),
    );

    final Result<PagedImages> result = await repository.getImages(
      const ImageQuery(page: 1),
    );

    expect((result as Success<PagedImages>).data.hasMore, isFalse);
  });

  test('maps a 500 remote exception to a ServerFailure', () async {
    when(
      () => api.fetchImages(
        page: any(named: 'page'),
        query: any(named: 'query'),
        category: any(named: 'category'),
        perPage: any(named: 'perPage'),
      ),
    ).thenThrow(const RemoteException('Oops', code: '500'));

    final Result<PagedImages> result = await repository.getImages(
      const ImageQuery(page: 1),
    );

    final Failure failure = (result as FailureResult<PagedImages>).failure;
    expect(failure, isA<ServerFailure>());
    expect(failure.message, 'Oops');
  });

  test('maps a connection failure to a NetworkFailure', () async {
    when(
      () => api.fetchImages(
        page: any(named: 'page'),
        query: any(named: 'query'),
        category: any(named: 'category'),
        perPage: any(named: 'perPage'),
      ),
    ).thenThrow(const RemoteException('No internet'));

    final Result<PagedImages> result = await repository.getImages(
      const ImageQuery(page: 1),
    );

    expect(
      (result as FailureResult<PagedImages>).failure,
      isA<NetworkFailure>(),
    );
  });
}
