import 'package:equatable/equatable.dart';

import '../../../domain/entities/gallery_image.dart';

enum FavoritesStatus { initial, loading, loaded, failure }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const <GalleryImage>[],
    this.error,
  });

  final FavoritesStatus status;
  final List<GalleryImage> favorites;
  final String? error;

  Set<int> get favoriteIds => favorites.map((GalleryImage i) => i.id).toSet();

  bool isFavorite(int imageId) => favoriteIds.contains(imageId);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<GalleryImage>? favorites,
    String? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, favorites, error];
}
