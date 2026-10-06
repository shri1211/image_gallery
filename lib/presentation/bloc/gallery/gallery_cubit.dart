import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/error/result.dart';
import '../../../core/utils/debouncer.dart';
import '../../../domain/entities/gallery_image.dart';
import '../../../domain/entities/paged_images.dart';
import '../../../domain/repositories/image_repository.dart';
import '../../../domain/usecases/get_images.dart';
import 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit(this._getImages, {Debouncer? debouncer})
    : _debouncer =
          debouncer ?? Debouncer(duration: AppConstants.searchDebounce),
      super(const GalleryState());

  final GetImagesUseCase _getImages;
  final Debouncer _debouncer;

  bool _isFetching = false;

  Future<void> loadInitial() => _fetch();

  Future<void> refresh() => _fetch(showLoading: false);

  Future<void> loadMore() {
    if (_isFetching || !state.hasMore) return Future<void>.value();
    return _fetch(replace: false);
  }

  void search(String query) {
    _debouncer.run(() => _fetch(query: query.trim()));
  }

  void selectCategory(String category) {
    if (category == state.category) return;
    _fetch(category: category);
  }

  Future<void> _fetch({
    bool replace = true,
    bool showLoading = true,
    String? query,
    String? category,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    final GalleryState current = state;
    final String nextQuery = query ?? current.query;
    final String nextCategory = category ?? current.category;
    final int nextPage = replace ? 1 : current.page + 1;

    emit(
      replace
          ? current.copyWith(
              status: showLoading ? GalleryStatus.loading : current.status,
              query: nextQuery,
              category: nextCategory,
              clearInitialError: true,
              clearLoadMoreError: true,
            )
          : current.copyWith(
              status: GalleryStatus.loadingMore,
              clearLoadMoreError: true,
            ),
    );

    final Result<PagedImages> result = await _getImages(
      ImageQuery(page: nextPage, query: nextQuery, category: nextCategory),
    );

    if (isClosed) return;

    result.fold(
      (PagedImages paged) {
        final List<GalleryImage> merged = replace
            ? paged.images
            : _mergeById(current.images, paged.images);
        emit(
          GalleryState(
            status: GalleryStatus.loaded,
            images: merged,
            page: paged.page,
            hasMore: paged.hasMore,
            query: nextQuery,
            category: nextCategory,
          ),
        );
      },
      (failure) {
        if (replace) {
          emit(
            current.copyWith(
              status: GalleryStatus.failedInitial,
              initialError: failure.message,
              images: const <GalleryImage>[],
              page: 1,
              clearLoadMoreError: true,
            ),
          );
        } else {
          emit(
            current.copyWith(
              status: GalleryStatus.loaded,
              loadMoreError: failure.message,
              hasMore: false,
            ),
          );
        }
      },
    );

    _isFetching = false;
  }

  List<GalleryImage> _mergeById(
    List<GalleryImage> existing,
    List<GalleryImage> incoming,
  ) {
    final Set<int> known = existing.map((GalleryImage i) => i.id).toSet();
    return <GalleryImage>[
      ...existing,
      ...incoming.where((GalleryImage i) => !known.contains(i.id)),
    ];
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
