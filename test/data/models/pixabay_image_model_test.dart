import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/data/models/pixabay_image_model.dart';
import 'package:image_gallery/data/models/pixabay_response_model.dart';

import '../../helpers/test_data.dart';

void main() {
  group('PixabayImageModel', () {
    test('parses all fields from a valid response', () {
      final PixabayImageModel model = PixabayImageModel.fromJson(pixabayJson());

      expect(model.id, 42);
      expect(model.tags, <String>['nature', 'mountain', 'lake']);
      expect(model.previewUrl, 'https://pixabay.com/preview/42.jpg');
      expect(model.webformatUrl, 'https://pixabay.com/webformat/42.jpg');
      expect(model.largeImageUrl, 'https://pixabay.com/large/42.jpg');
      expect(model.views, 12000);
      expect(model.aspectRatio, closeTo(4000 / 2664, 0.0001));
      expect(model.isLandscape, isTrue);
    });

    test('tolerates missing optional fields', () {
      final PixabayImageModel model = PixabayImageModel.fromJson(
        <String, dynamic>{'id': 7, 'tags': ''},
      );

      expect(model.id, 7);
      expect(model.tags, isEmpty);
      expect(model.imageWidth, 0);
      expect(model.aspectRatio, 1);
      expect(model.type, 'photo');
    });

    test('round-trips through json', () {
      final PixabayImageModel original = PixabayImageModel.fromJson(
        pixabayJson(),
      );
      final PixabayImageModel restored = PixabayImageModel.fromJson(
        original.toJson(),
      );

      expect(restored, original);
    });
  });

  group('PixabayResponseModel', () {
    test('parses hits list', () {
      final PixabayResponseModel response = PixabayResponseModel.fromJson(
        <String, dynamic>{
          'total': 100,
          'totalHits': 90,
          'hits': <Map<String, dynamic>>[pixabayJson(), pixabayJson(id: 99)],
        },
      );

      expect(response.total, 100);
      expect(response.totalHits, 90);
      expect(response.images, hasLength(2));
    });

    test('handles empty hits', () {
      final PixabayResponseModel response = PixabayResponseModel.fromJson(
        <String, dynamic>{'totalHits': 0},
      );

      expect(response.images, isEmpty);
    });
  });
}
