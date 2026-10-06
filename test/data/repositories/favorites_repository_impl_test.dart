import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/data/datasources/local/favorites_local_data_source.dart';
import 'package:image_gallery/data/repositories/favorites_repository_impl.dart';
import 'package:image_gallery/domain/entities/gallery_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_data.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('FavoritesRepositoryImpl', () {
    test('starts empty and toggle adds an image', () async {
      final FavoritesRepositoryImpl repository = await _repository();

      final Result<bool> addResult = await repository.toggleFavorite(
        buildGalleryImage(id: 1),
      );

      expect((addResult as Success<bool>).data, isTrue);

      final Result<List<GalleryImage>> favorites = await repository
          .getFavorites();
      expect(
        (favorites as Success<List<GalleryImage>>).data.map((g) => g.id),
        contains(1),
      );
    });

    test('toggle removes an already-favorited image', () async {
      final FavoritesRepositoryImpl repository = await _repository();
      await repository.toggleFavorite(buildGalleryImage(id: 1));
      final Result<bool> removeResult = await repository.toggleFavorite(
        buildGalleryImage(id: 1),
      );

      expect((removeResult as Success<bool>).data, isFalse);

      final Result<List<GalleryImage>> favorites = await repository
          .getFavorites();
      expect((favorites as Success<List<GalleryImage>>).data, isEmpty);
    });

    test('persists favorites across repository instances', () async {
      final FavoritesRepositoryImpl first = await _repository();
      await first.toggleFavorite(buildGalleryImage(id: 7));

      final FavoritesRepositoryImpl second = await _repository();
      final Result<bool> fav = await second.isFavorite(7);

      expect((fav as Success<bool>).data, isTrue);
    });

    test('keeps newest favorite first', () async {
      final FavoritesRepositoryImpl repository = await _repository();
      await repository.toggleFavorite(buildGalleryImage(id: 1));
      await repository.toggleFavorite(buildGalleryImage(id: 2));

      final Result<List<GalleryImage>> favorites = await repository
          .getFavorites();
      final List<GalleryImage> images =
          (favorites as Success<List<GalleryImage>>).data;

      expect(images.map((g) => g.id), <int>[2, 1]);
    });
  });
}

Future<FavoritesRepositoryImpl> _repository() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return FavoritesRepositoryImpl(FavoritesLocalDataSource(preferences));
}
