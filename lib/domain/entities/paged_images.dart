import 'package:equatable/equatable.dart';

import 'gallery_image.dart';

class PagedImages extends Equatable {
  const PagedImages({
    required this.images,
    required this.page,
    required this.total,
    required this.hasMore,
  });

  final List<GalleryImage> images;
  final int page;

  final int total;

  final bool hasMore;

  @override
  List<Object?> get props => <Object?>[images, page, total, hasMore];
}
