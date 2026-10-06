import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/core/error/failures.dart';
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/core/utils/debouncer.dart';
import 'package:image_gallery/domain/entities/gallery_image.dart';
import 'package:image_gallery/domain/entities/paged_images.dart';
import 'package:image_gallery/domain/repositories/image_repository.dart';
import 'package:image_gallery/domain/usecases/get_images.dart';
import 'package:image_gallery/presentation/bloc/gallery/gallery_cubit.dart';
import 'package:image_gallery/presentation/bloc/gallery/gallery_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallbacks.dart';
import '../../helpers/test_data.dart';

class _MockGetImages extends Mock implements GetImagesUseCase {}

PagedImages page(int page, int count, {int total = 1000}) {
  return PagedImages(
    images: List<GalleryImage>.generate(
      count,
      (int i) => buildGalleryImage(id: page * 100 + i),
    ),
    page: page,
    total: total,
    hasMore: page * 40 < total,
  );
}

void main() {
  registerTestFallbacks();
  late _MockGetImages getImages;

  setUp(() {
    getImages = _MockGetImages();
    when(
      () => getImages(any()),
    ).thenAnswer((_) async => Success<PagedImages>(page(1, 2)));
  });

  group('GalleryCubit', () {
    blocTest<GalleryCubit, GalleryState>(
      'emits loading then loaded on initial load',
      build: () => GalleryCubit(getImages),
      act: (GalleryCubit cubit) => cubit.loadInitial(),
      expect: () => <GalleryState>[
        const GalleryState(status: GalleryStatus.loading),
        GalleryState(
          status: GalleryStatus.loaded,
          images: page(1, 2).images,
          page: 1,
          hasMore: true,
        ),
      ],
    );

    blocTest<GalleryCubit, GalleryState>(
      'appends and deduplicates images on load more',
      build: () => GalleryCubit(getImages),
      seed: () => GalleryState(
        status: GalleryStatus.loaded,
        images: <GalleryImage>[buildGalleryImage(id: 1)],
        page: 1,
        hasMore: true,
      ),
      act: (GalleryCubit cubit) async {
        when(() => getImages(any())).thenAnswer(
          (_) async => Success<PagedImages>(
            PagedImages(
              images: <GalleryImage>[
                buildGalleryImage(id: 1),
                buildGalleryImage(id: 2),
              ],
              page: 2,
              total: 1000,
              hasMore: true,
            ),
          ),
        );
        await cubit.loadMore();
      },
      expect: () => <GalleryState>[
        GalleryState(
          status: GalleryStatus.loadingMore,
          images: <GalleryImage>[buildGalleryImage(id: 1)],
          page: 1,
          hasMore: true,
        ),
        GalleryState(
          status: GalleryStatus.loaded,
          images: <GalleryImage>[
            buildGalleryImage(id: 1),
            buildGalleryImage(id: 2),
          ],
          page: 2,
          hasMore: true,
        ),
      ],
    );

    blocTest<GalleryCubit, GalleryState>(
      'debounced search resets the list and passes the query',
      build: () => GalleryCubit(
        getImages,
        debouncer: Debouncer(duration: Duration.zero),
      ),
      act: (GalleryCubit cubit) async {
        when(() => getImages(any())).thenAnswer((Invocation invocation) async {
          final ImageQuery query =
              invocation.positionalArguments[0] as ImageQuery;
          expect(query.query, 'mountains');
          return Success<PagedImages>(page(1, 1, total: 40));
        });
        cubit.search('mountains');
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      expect: () => <GalleryState>[
        const GalleryState(status: GalleryStatus.loading, query: 'mountains'),
        GalleryState(
          status: GalleryStatus.loaded,
          images: page(1, 1, total: 40).images,
          page: 1,
          hasMore: false,
          query: 'mountains',
        ),
      ],
    );

    test('ignores load more while a fetch is already running', () async {
      final Completer<Result<PagedImages>> gate =
          Completer<Result<PagedImages>>();
      when(() => getImages(any())).thenAnswer((_) => gate.future);

      final GalleryCubit cubit = GalleryCubit(getImages);
      unawaited(cubit.loadMore());
      await Future<void>.delayed(Duration.zero);

      when(
        () => getImages(any()),
      ).thenAnswer((_) async => Success<PagedImages>(page(1, 2)));
      await cubit.loadMore();
      await cubit.loadMore();

      gate.complete(Success<PagedImages>(page(1, 2)));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      verify(() => getImages(any())).called(1);
      await cubit.close();
    });

    blocTest<GalleryCubit, GalleryState>(
      'shows an error view when the initial load fails',
      build: () => GalleryCubit(getImages),
      act: (GalleryCubit cubit) async {
        when(() => getImages(any())).thenAnswer(
          (_) async => const FailureResult<PagedImages>(
            NetworkFailure('No connectivity'),
          ),
        );
        await cubit.loadInitial();
      },
      expect: () => <GalleryState>[
        const GalleryState(status: GalleryStatus.loading),
        const GalleryState(
          status: GalleryStatus.failedInitial,
          initialError: 'No connectivity',
          page: 1,
        ),
      ],
    );

    blocTest<GalleryCubit, GalleryState>(
      'keeps existing images and reports a load-more failure',
      build: () => GalleryCubit(getImages),
      seed: () => GalleryState(
        status: GalleryStatus.loaded,
        images: <GalleryImage>[buildGalleryImage(id: 1)],
        page: 1,
        hasMore: true,
      ),
      act: (GalleryCubit cubit) async {
        when(() => getImages(any())).thenAnswer(
          (_) async => const FailureResult<PagedImages>(
            NetworkFailure('No connectivity'),
          ),
        );
        await cubit.loadMore();
      },
      expect: () => <GalleryState>[
        GalleryState(
          status: GalleryStatus.loadingMore,
          images: <GalleryImage>[buildGalleryImage(id: 1)],
          page: 1,
          hasMore: true,
        ),
        GalleryState(
          status: GalleryStatus.loaded,
          images: <GalleryImage>[buildGalleryImage(id: 1)],
          page: 1,
          hasMore: false,
          loadMoreError: 'No connectivity',
        ),
      ],
    );

    blocTest<GalleryCubit, GalleryState>(
      'refresh keeps the current filters',
      build: () => GalleryCubit(getImages),
      seed: () => const GalleryState(
        status: GalleryStatus.loaded,
        images: <GalleryImage>[],
        page: 1,
        query: 'mountains',
        category: 'nature',
        hasMore: false,
      ),
      act: (GalleryCubit cubit) async {
        when(() => getImages(any())).thenAnswer((Invocation invocation) async {
          final ImageQuery query =
              invocation.positionalArguments[0] as ImageQuery;
          expect(query.query, 'mountains');
          expect(query.category, 'nature');
          return Success<PagedImages>(page(1, 1, total: 40));
        });
        await cubit.refresh();
      },
      expect: () => <GalleryState>[
        GalleryState(
          status: GalleryStatus.loaded,
          images: page(1, 1, total: 40).images,
          page: 1,
          query: 'mountains',
          category: 'nature',
          hasMore: false,
        ),
      ],
    );
  });
}
