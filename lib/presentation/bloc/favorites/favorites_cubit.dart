import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/gallery_image.dart';
import '../../../domain/usecases/get_favorites.dart';
import '../../../domain/usecases/toggle_favorite.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._getFavorites, this._toggleFavorite)
    : super(const FavoritesState());

  final GetFavoritesUseCase _getFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;

  Future<void> load() async {
    if (state.status == FavoritesStatus.loaded) return;
    emit(state.copyWith(status: FavoritesStatus.loading, clearError: true));

    final Result<List<GalleryImage>> result = await _getFavorites(
      const NoParams(),
    );
    if (isClosed) return;

    result.fold(
      (List<GalleryImage> favorites) {
        emit(
          state.copyWith(status: FavoritesStatus.loaded, favorites: favorites),
        );
      },
      (failure) {
        emit(
          state.copyWith(
            status: FavoritesStatus.failure,
            error: failure.message,
          ),
        );
      },
    );
  }

  Future<bool> toggle(GalleryImage image) async {
    final List<GalleryImage> previous = state.favorites;
    final List<GalleryImage> updated = _withToggled(image);
    emit(state.copyWith(favorites: updated, status: FavoritesStatus.loaded));

    final Result<bool> result = await _toggleFavorite(image);
    if (isClosed) return false;

    return result.fold<bool>((_) => state.isFavorite(image.id), (failure) {
      emit(state.copyWith(favorites: previous));
      return false;
    });
  }

  List<GalleryImage> _withToggled(GalleryImage image) {
    final List<GalleryImage> favorites = List<GalleryImage>.of(state.favorites);
    final int index = favorites.indexWhere(
      (GalleryImage i) => i.id == image.id,
    );
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.insert(0, image);
    }
    return favorites;
  }
}
