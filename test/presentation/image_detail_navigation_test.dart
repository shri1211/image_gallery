import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_gallery/app.dart';
import 'package:image_gallery/core/di/injector.dart' show locator;
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/core/utils/debouncer.dart';
import 'package:image_gallery/domain/entities/gallery_image.dart';
import 'package:image_gallery/domain/entities/paged_images.dart';
import 'package:image_gallery/domain/usecases/download_image.dart';
import 'package:image_gallery/domain/usecases/get_favorites.dart';
import 'package:image_gallery/domain/usecases/get_images.dart';
import 'package:image_gallery/domain/usecases/toggle_favorite.dart';
import 'package:image_gallery/presentation/bloc/favorites/favorites_cubit.dart';
import 'package:image_gallery/presentation/bloc/gallery/gallery_cubit.dart';
import 'package:image_gallery/presentation/bloc/image_detail/image_detail_cubit.dart';
import 'package:image_gallery/presentation/screens/detail/image_detail_screen.dart';
import 'package:image_gallery/presentation/widgets/gallery_image_tile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fallbacks.dart';

class _MockGetImages extends Mock implements GetImagesUseCase {}

class _MockGetFavorites extends Mock implements GetFavoritesUseCase {}

class _MockToggleFavorite extends Mock implements ToggleFavoriteUseCase {}

class _MockDownloadImage extends Mock implements DownloadImageUseCase {}

const GalleryImage _image = GalleryImage(
  id: 42,
  tags: <String>['nature', 'forest'],
  previewUrl: 'https://example.com/preview.jpg',
  previewWidth: 150,
  previewHeight: 100,
  webformatUrl: 'https://example.com/web.jpg',
  largeImageUrl: 'https://example.com/large.jpg',
  imageWidth: 1200,
  imageHeight: 800,
  imageSize: 1000,
  views: 10,
  downloads: 5,
  likes: 3,
  comments: 1,
  user: 'tester',
  userImageUrl: '',
  pageUrl: 'https://example.com/page',
  type: 'photo',
);

void main() {
  registerTestFallbacks();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('tapping a gallery tile opens the detail screen', (
    WidgetTester tester,
  ) async {
    final _MockGetImages getImages = _MockGetImages();
    final _MockGetFavorites getFavorites = _MockGetFavorites();
    final _MockToggleFavorite toggleFavorite = _MockToggleFavorite();

    when(() => getImages(any())).thenAnswer(
      (_) async => const Success<PagedImages>(
        PagedImages(
          images: <GalleryImage>[_image],
          page: 1,
          total: 1,
          hasMore: false,
        ),
      ),
    );
    when(() => getFavorites(any())).thenAnswer(
      (_) async => const Success<List<GalleryImage>>(<GalleryImage>[]),
    );
    when(
      () => toggleFavorite(any()),
    ).thenAnswer((_) async => const Success<bool>(true));

    final GetIt container = locator;
    await container.reset();

    container.registerFactory<GalleryCubit>(
      () => GalleryCubit(
        getImages,
        debouncer: Debouncer(duration: Duration.zero),
      ),
    );
    container.registerFactory<FavoritesCubit>(
      () => FavoritesCubit(getFavorites, toggleFavorite),
    );
    container.registerFactory<ImageDetailCubit>(
      () => ImageDetailCubit(_MockDownloadImage()),
    );

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.byType(GalleryImageTile), findsOneWidget);

    await tester.tap(find.byType(GalleryImageTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(ImageDetailScreen), findsOneWidget);
  });
}
