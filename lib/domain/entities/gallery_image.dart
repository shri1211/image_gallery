import 'package:equatable/equatable.dart';

class GalleryImage extends Equatable {
  const GalleryImage({
    required this.id,
    required this.tags,
    required this.previewUrl,
    required this.previewWidth,
    required this.previewHeight,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageSize,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.comments,
    required this.user,
    required this.userImageUrl,
    required this.pageUrl,
    required this.type,
  });

  final int id;

  final List<String> tags;

  final String previewUrl;
  final int previewWidth;
  final int previewHeight;

  final String webformatUrl;
  final String largeImageUrl;

  final int imageWidth;
  final int imageHeight;
  final int imageSize;

  final int views;
  final int downloads;
  final int likes;
  final int comments;

  final String user;
  final String userImageUrl;

  final String pageUrl;
  final String type;

  double get aspectRatio {
    if (imageWidth == 0 || imageHeight == 0) return 1;
    return imageWidth / imageHeight;
  }

  bool get isPortrait => imageHeight >= imageWidth;
  bool get isLandscape => imageWidth > imageHeight;

  @override
  List<Object?> get props => <Object?>[
    id,
    tags,
    previewUrl,
    previewWidth,
    previewHeight,
    webformatUrl,
    largeImageUrl,
    imageWidth,
    imageHeight,
    imageSize,
    views,
    downloads,
    likes,
    comments,
    user,
    userImageUrl,
    pageUrl,
    type,
  ];
}
