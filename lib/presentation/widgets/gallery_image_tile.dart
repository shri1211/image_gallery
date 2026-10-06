import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/gallery_image.dart';
import '../bloc/favorites/favorites_cubit.dart';

class GalleryImageTile extends StatelessWidget {
  const GalleryImageTile({super.key, required this.image, required this.onTap});

  final GalleryImage image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = context.select<FavoritesCubit, bool>(
      (FavoritesCubit cubit) => cubit.state.isFavorite(image.id),
    );

    final Widget visual = CachedNetworkImage(
      imageUrl: image.webformatUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (BuildContext context, String url) =>
          const _TileSkeleton(dark: true),
      errorWidget: (BuildContext context, String url, Object error) =>
          const _TileSkeleton(dark: false),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        return SizedBox(
          width: width,
          height: width / image.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                InkWell(
                  onTap: onTap,
                  child: Hero(tag: heroTag(image.id), child: visual),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: _FavoriteBadge(
                    isFavorite: isFavorite,
                    onPressed: () =>
                        context.read<FavoritesCubit>().toggle(image),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String heroTag(int imageId) => 'gallery_image_$imageId';
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isFavorite ? Colors.redAccent : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: dark
          ? const Color(0xFF2A2A2E)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
