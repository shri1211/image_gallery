import '../../domain/entities/gallery_image.dart';

class PixabayImageModel extends GalleryImage {
  const PixabayImageModel({
    required super.id,
    required super.tags,
    required super.previewUrl,
    required super.previewWidth,
    required super.previewHeight,
    required super.webformatUrl,
    required super.largeImageUrl,
    required super.imageWidth,
    required super.imageHeight,
    required super.imageSize,
    required super.views,
    required super.downloads,
    required super.likes,
    required super.comments,
    required super.user,
    required super.userImageUrl,
    required super.pageUrl,
    required super.type,
  });

  factory PixabayImageModel.fromEntity(GalleryImage image) {
    return PixabayImageModel(
      id: image.id,
      tags: image.tags,
      previewUrl: image.previewUrl,
      previewWidth: image.previewWidth,
      previewHeight: image.previewHeight,
      webformatUrl: image.webformatUrl,
      largeImageUrl: image.largeImageUrl,
      imageWidth: image.imageWidth,
      imageHeight: image.imageHeight,
      imageSize: image.imageSize,
      views: image.views,
      downloads: image.downloads,
      likes: image.likes,
      comments: image.comments,
      user: image.user,
      userImageUrl: image.userImageUrl,
      pageUrl: image.pageUrl,
      type: image.type,
    );
  }

  factory PixabayImageModel.fromJson(Map<String, dynamic> json) {
    return PixabayImageModel(
      id: json['id'] as int? ?? 0,
      tags: _parseTags(json['tags'] as String?),
      previewUrl: json['previewURL'] as String? ?? '',
      previewWidth: json['previewWidth'] as int? ?? 0,
      previewHeight: json['previewHeight'] as int? ?? 0,
      webformatUrl: json['webformatURL'] as String? ?? '',
      largeImageUrl: json['largeImageURL'] as String? ?? '',
      imageWidth: json['imageWidth'] as int? ?? 0,
      imageHeight: json['imageHeight'] as int? ?? 0,
      imageSize: json['imageSize'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      user: json['user'] as String? ?? '',
      userImageUrl: json['userImageURL'] as String? ?? '',
      pageUrl: json['pageURL'] as String? ?? '',
      type: json['type'] as String? ?? 'photo',
    );
  }

  static List<String> _parseTags(String? raw) {
    if (raw == null || raw.isEmpty) return const <String>[];
    return raw
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'tags': tags.join(', '),
      'previewURL': previewUrl,
      'previewWidth': previewWidth,
      'previewHeight': previewHeight,
      'webformatURL': webformatUrl,
      'largeImageURL': largeImageUrl,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'imageSize': imageSize,
      'views': views,
      'downloads': downloads,
      'likes': likes,
      'comments': comments,
      'user': user,
      'userImageURL': userImageUrl,
      'pageURL': pageUrl,
      'type': type,
    };
  }
}
