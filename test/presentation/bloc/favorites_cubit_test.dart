import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/core/error/failures.dart';
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/domain/entities/gallery_image.dart';
import 'package:image_gallery/domain/usecases/get_favorites.dart';
import 'package:image_gallery/domain/usecases/toggle_favorite.dart';
import 'package:image_gallery/presentation/bloc/favorites/favorites_cubit.dart';
import 'package:image_gallery/presentation/bloc/favorites/favorites_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallbacks.dart';
import '../../helpers/test_data.dart';

class _MockGetFavorites extends Mock implements GetFavoritesUseCase {}

class _MockToggleFavorite extends Mock implements ToggleFavoriteUseCase {}

void main() {
  registerTestFallbacks();
  late _MockGetFavorites getFavorites;
  late _MockToggleFavorite toggleFavorite;

  setUp(() {
    getFavorites = _MockGetFavorites();
    toggleFavorite = _MockToggleFavorite();
    when(() => getFavorites(any())).thenAnswer(
      (_) async => const Success<List<GalleryImage>>(<GalleryImage>[]),
    );
    when(
      () => toggleFavorite(any()),
    ).thenAnswer((_) async => const Success<bool>(true));
  });

  group('FavoritesCubit', () {
    blocTest<FavoritesCubit, FavoritesState>(
      'loads favorites from local storage',
      build: () => FavoritesCubit(getFavorites, toggleFavorite),
      act: (FavoritesCubit cubit) => cubit.load(),
      skip: 1,
      expect: () => <FavoritesState>[
        FavoritesState(
          status: FavoritesStatus.loaded,
          favorites: <GalleryImage>[],
        ),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'adds an image optimistically when toggled',
      build: () => FavoritesCubit(getFavorites, toggleFavorite),
      seed: () => const FavoritesState(status: FavoritesStatus.loaded),
      act: (FavoritesCubit cubit) => cubit.toggle(buildGalleryImage(id: 9)),
      expect: () => <FavoritesState>[
        FavoritesState(
          status: FavoritesStatus.loaded,
          favorites: <GalleryImage>[buildGalleryImage(id: 9)],
        ),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'removes an image already in favorites',
      build: () => FavoritesCubit(getFavorites, toggleFavorite),
      seed: () => FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: <GalleryImage>[buildGalleryImage(id: 9)],
      ),
      act: (FavoritesCubit cubit) async {
        when(
          () => toggleFavorite(any()),
        ).thenAnswer((_) async => const Success<bool>(false));
        await cubit.toggle(buildGalleryImage(id: 9));
      },
      expect: () => <FavoritesState>[
        const FavoritesState(
          status: FavoritesStatus.loaded,
          favorites: <GalleryImage>[],
        ),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'reverts the optimistic change when persistence fails',
      build: () => FavoritesCubit(getFavorites, toggleFavorite),
      seed: () => const FavoritesState(status: FavoritesStatus.loaded),
      act: (FavoritesCubit cubit) async {
        when(() => toggleFavorite(any())).thenAnswer(
          (_) async => const FailureResult<bool>(CacheFailure('Disk full')),
        );
        await cubit.toggle(buildGalleryImage(id: 5));
      },
      expect: () => <FavoritesState>[
        FavoritesState(
          status: FavoritesStatus.loaded,
          favorites: <GalleryImage>[buildGalleryImage(id: 5)],
        ),
        const FavoritesState(
          status: FavoritesStatus.loaded,
          favorites: <GalleryImage>[],
        ),
      ],
    );

    test('isFavorite reflects the current state', () async {
      final FavoritesCubit cubit = FavoritesCubit(getFavorites, toggleFavorite);
      await cubit.toggle(buildGalleryImage(id: 3));

      expect(cubit.state.isFavorite(3), isTrue);
      expect(cubit.state.isFavorite(999), isFalse);
      await cubit.close();
    });
  });
}
