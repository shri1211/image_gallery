import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../domain/entities/gallery_image.dart';
import '../../bloc/favorites/favorites_state.dart';
import '../../bloc/favorites/favorites_cubit.dart';
import '../../navigation/image_detail_route.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_retry_view.dart';
import '../../widgets/gallery_image_tile.dart';
import '../gallery/gallery_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (BuildContext context, FavoritesState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Favorites',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(child: _body(context, state)),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, FavoritesState state) {
    switch (state.status) {
      case FavoritesStatus.initial:
      case FavoritesStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case FavoritesStatus.failure:
        return ErrorRetryView(
          message: state.error ?? 'Favorites could not be loaded.',
          onRetry: () => context.read<FavoritesCubit>().load(),
        );
      case FavoritesStatus.loaded:
        if (state.favorites.isEmpty) {
          return const EmptyView(
            icon: Icons.favorite_border_rounded,
            title: 'No favorites yet',
            subtitle:
                'Tap the heart on any image to save it here. '
                'Favorites are stored on your device.',
          );
        }

        final double width = MediaQuery.sizeOf(context).width;
        final int crossAxisCount = GalleryScreen.crossAxisCountFor(width);

        return RefreshIndicator(
          onRefresh: () => context.read<FavoritesCubit>().load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: state.favorites.length,
                  itemBuilder: (BuildContext context, int index) {
                    final GalleryImage image = state.favorites[index];
                    return GalleryImageTile(
                      image: image,
                      onTap: () => Navigator.of(
                        context,
                      ).push(imageDetailRoute(context, image)),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
    }
  }
}
