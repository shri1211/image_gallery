import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/core/error/failures.dart';
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/domain/usecases/download_image.dart';
import 'package:image_gallery/presentation/bloc/image_detail/image_detail_cubit.dart';
import 'package:image_gallery/presentation/bloc/image_detail/image_detail_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallbacks.dart';
import '../../helpers/test_data.dart';

class _MockDownload extends Mock implements DownloadImageUseCase {}

void main() {
  registerTestFallbacks();
  late _MockDownload download;

  setUp(() {
    download = _MockDownload();
  });

  group('ImageDetailCubit', () {
    blocTest<ImageDetailCubit, ImageDetailState>(
      'streams download progress and completes successfully',
      build: () => ImageDetailCubit(download),
      act: (ImageDetailCubit cubit) async {
        when(() => download(any())).thenAnswer((Invocation invocation) async {
          final DownloadParams params =
              invocation.positionalArguments[0] as DownloadParams;
          params.onProgress(0.25);
          params.onProgress(0.8);
          return const Success<String>('saved/here.jpg');
        });
        await cubit.download(buildGalleryImage());
      },
      expect: () => <ImageDetailState>[
        const ImageDetailState(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: 0,
        ),
        const ImageDetailState(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: 0.25,
        ),
        const ImageDetailState(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: 0.8,
        ),
        const ImageDetailState(
          downloadStatus: DownloadStatus.success,
          downloadProgress: 1,
          savedAt: 'saved/here.jpg',
        ),
      ],
    );

    blocTest<ImageDetailCubit, ImageDetailState>(
      'emits a failure with the repository message',
      build: () => ImageDetailCubit(download),
      act: (ImageDetailCubit cubit) async {
        when(() => download(any())).thenAnswer(
          (_) async => const FailureResult<String>(
            PermissionFailure('Permission was denied'),
          ),
        );
        await cubit.download(buildGalleryImage());
      },
      expect: () => <ImageDetailState>[
        const ImageDetailState(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: 0,
        ),
        const ImageDetailState(
          downloadStatus: DownloadStatus.failure,
          downloadError: 'Permission was denied',
        ),
      ],
    );

    test('ignores duplicate download requests while one is running', () async {
      final Completer<Result<String>> gate = Completer<Result<String>>();
      when(() => download(any())).thenAnswer((_) => gate.future);
      final ImageDetailCubit cubit = ImageDetailCubit(download);

      final Future<void> first = cubit.download(buildGalleryImage());
      await cubit.download(buildGalleryImage());
      gate.complete(const Success<String>('/tmp/x.jpg'));
      await first;

      verify(() => download(any())).called(1);
      await cubit.close();
    });
  });
}
