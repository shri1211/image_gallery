import 'pixabay_image_model.dart';

class PixabayResponseModel {
  const PixabayResponseModel({
    required this.total,
    required this.totalHits,
    required this.images,
  });

  final int total;
  final int totalHits;
  final List<PixabayImageModel> images;

  factory PixabayResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> hits =
        json['hits'] as List<dynamic>? ?? const <dynamic>[];
    return PixabayResponseModel(
      total: (json['total'] ?? 0) as int,
      totalHits: (json['totalHits'] ?? 0) as int,
      images: hits
          .map(
            (dynamic e) =>
                PixabayImageModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
