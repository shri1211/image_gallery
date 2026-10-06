import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/core/error/exceptions.dart';
import 'package:image_gallery/core/error/failures.dart';
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/data/datasources/local/image_download_data_source.dart';
import 'package:image_gallery/data/repositories/download_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallbacks.dart';
import '../../helpers/test_data.dart';

class _MockDataSource extends Mock implements ImageDownloadDataSource {}

void main() {
  registerTestFallbacks();
  late _MockDataSource dataSource;
  late DownloadRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = DownloadRepositoryImpl(dataSource);
  });

  test('returns the saved location on success and forwards progress', () async {
    when(() => dataSource.download(any(), any())).thenAnswer((
      Invocation invocation,
    ) async {
      final void Function(double) onProgress =
          invocation.positionalArguments[1] as void Function(double);
      onProgress(0.5);
      return 'https://example.com/saved.jpg';
    });

    final List<double> progress = <double>[];
    final Result<String> result = await repository.download(
      buildGalleryImage(),
      progress.add,
    );

    expect((result as Success<String>).data, 'https://example.com/saved.jpg');
    expect(progress, contains(0.5));
  });

  test('maps a permission exception to a PermissionFailure', () async {
    when(
      () => dataSource.download(any(), any()),
    ).thenThrow(const PermissionException('Denied'));

    final Result<String> result = await repository.download(
      buildGalleryImage(),
      (_) {},
    );

    expect((result as FailureResult<String>).failure, isA<PermissionFailure>());
  });

  test('maps a download exception to a DownloadFailure', () async {
    when(
      () => dataSource.download(any(), any()),
    ).thenThrow(const DownloadException('Broken'));

    final Result<String> result = await repository.download(
      buildGalleryImage(),
      (_) {},
    );

    final Failure failure = (result as FailureResult<String>).failure;
    expect(failure, isA<DownloadFailure>());
    expect(failure.message, 'Broken');
  });
}
