import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_gallery/app.dart';
import 'package:image_gallery/core/di/injector.dart' show locator;
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/core/utils/debouncer.dart';
import 'package:image_gallery/domain/entities/gallery_image.dart';
import 'package:image_gallery/domain/entities/paged_images.dart';
import 'package:image_gallery/domain/usecases/get_favorites.dart';
import 'package:image_gallery/domain/usecases/get_images.dart';
import 'package:image_gallery/domain/usecases/toggle_favorite.dart';
import 'package:image_gallery/presentation/bloc/favorites/favorites_cubit.dart';
import 'package:image_gallery/presentation/bloc/gallery/gallery_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fallbacks.dart';

class _MockGetImages extends Mock implements GetImagesUseCase {}

class _MockGetFavorites extends Mock implements GetFavoritesUseCase {}

class _MockToggleFavorite extends Mock implements ToggleFavoriteUseCase {}

void main() {
  registerTestFallbacks();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('app boots and renders the gallery shell', (
    WidgetTester tester,
  ) async {
    final _MockGetImages getImages = _MockGetImages();
    final _MockGetFavorites getFavorites = _MockGetFavorites();
    final _MockToggleFavorite toggleFavorite = _MockToggleFavorite();

    when(() => getImages(any())).thenAnswer(
      (_) async => const Success<PagedImages>(
        PagedImages(
          images: <GalleryImage>[],
          page: 1,
          total: 0,
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

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Infinite Gallery'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);

    // Switch to the (empty) favorites tab.
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('No favorites yet'), findsOneWidget);
  });
}
