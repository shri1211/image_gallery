import 'package:equatable/equatable.dart';

import '../../../domain/entities/gallery_image.dart';

enum GalleryStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  failedInitial,
  failedLoadMore,
}

class GalleryState extends Equatable {
  const GalleryState({
    this.status = GalleryStatus.initial,
    this.images = const <GalleryImage>[],
    this.page = 0,
    this.hasMore = true,
    this.query = '',
    this.category = '',
    this.initialError,
    this.loadMoreError,
  });

  final GalleryStatus status;
  final List<GalleryImage> images;
  final int page;
  final bool hasMore;
  final String query;
  final String category;
  final String? initialError;
  final String? loadMoreError;

  bool get isLoadingInitial => status == GalleryStatus.loading;

  bool get isEmpty => images.isEmpty && status == GalleryStatus.loaded;

  bool get isSearching => query.trim().isNotEmpty || category.isNotEmpty;

  GalleryState copyWith({
    GalleryStatus? status,
    List<GalleryImage>? images,
    int? page,
    bool? hasMore,
    String? query,
    String? category,
    String? initialError,
    String? loadMoreError,
    bool clearInitialError = false,
    bool clearLoadMoreError = false,
  }) {
    return GalleryState(
      status: status ?? this.status,
      images: images ?? this.images,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      category: category ?? this.category,
      initialError: clearInitialError
          ? null
          : (initialError ?? this.initialError),
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    images,
    page,
    hasMore,
    query,
    category,
    initialError,
    loadMoreError,
  ];
}
