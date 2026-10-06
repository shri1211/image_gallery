import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/di/injector.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/gallery_image.dart';
import '../../bloc/favorites/favorites_cubit.dart';
import '../../bloc/image_detail/image_detail_cubit.dart';
import '../../bloc/image_detail/image_detail_state.dart';
import '../../widgets/gallery_image_tile.dart';

class ImageDetailScreen extends StatelessWidget {
  const ImageDetailScreen({super.key, required this.image});

  final GalleryImage image;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImageDetailCubit>(
      create: (_) => locator<ImageDetailCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Formatters.titleCase(image.user.isEmpty ? 'Photo' : image.user),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            _FavoriteAction(image: image),
            _ShareAction(image: image),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _HeroImage(image: image),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DescriptionSection(image: image),
                    const SizedBox(height: 24),
                    _StatsSection(image: image),
                    const SizedBox(height: 24),
                    _DownloadCard(image: image),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.image});
  final GalleryImage image;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = (width / image.aspectRatio).clamp(240.0, 520.0);

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Hero(
                  tag: GalleryImageTile.heroTag(image.id),
                  child: CachedNetworkImage(
                    imageUrl: image.largeImageUrl.isNotEmpty
                        ? image.largeImageUrl
                        : image.webformatUrl,
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) =>
                        ColoredBox(color: scheme.surfaceContainerHighest),
                    errorWidget:
                        (BuildContext context, String url, Object error) =>
                            ColoredBox(
                              color: scheme.surfaceContainerHighest,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                              ),
                            ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _PhotographerBadge(image: image),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhotographerBadge extends StatelessWidget {
  const _PhotographerBadge({required this.image});
  final GalleryImage image;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (image.userImageUrl.isNotEmpty)
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            backgroundImage: CachedNetworkImageProvider(image.userImageUrl),
          ),
        const SizedBox(width: 8),
        Text(
          Formatters.titleCase(image.user),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: <Shadow>[Shadow(blurRadius: 8, color: Colors.black54)],
          ),
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.image});
  final GalleryImage image;

  @override
  Widget build(BuildContext context) {
    final List<String> descriptionTags = image.tags;
    final String lead = descriptionTags.isEmpty
        ? 'No description available for this image.'
        : descriptionTags.take(AppConstants.maxDescriptionTags).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          lead[0].toUpperCase() + lead.substring(1),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (descriptionTags.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: descriptionTags
                .take(AppConstants.maxDescriptionTags)
                .map(
                  (String tag) => Chip(
                    label: Text(Formatters.titleCase(tag)),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.image});
  final GalleryImage image;

  @override
  Widget build(BuildContext context) {
    final List<_Stat> stats = <_Stat>[
      _Stat(
        icon: Icons.visibility_outlined,
        label: 'Views',
        value: Formatters.compactNumber(image.views),
      ),
      _Stat(
        icon: Icons.favorite_outline,
        label: 'Likes',
        value: Formatters.compactNumber(image.likes),
      ),
      _Stat(
        icon: Icons.download_outlined,
        label: 'Downloads',
        value: Formatters.compactNumber(image.downloads),
      ),
      _Stat(
        icon: Icons.comment_outlined,
        label: 'Comments',
        value: Formatters.compactNumber(image.comments),
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int perRow = constraints.maxWidth > 480 ? 4 : 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (final _Stat stat in stats)
              SizedBox(
                width: (constraints.maxWidth - 12 * (perRow - 1)) / perRow,
                child: _StatCard(stat: stat),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: <Widget>[
            Icon(
              stat.icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 6),
            Text(stat.value, style: Theme.of(context).textTheme.titleMedium),
            Text(
              stat.label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({required this.image});
  final GalleryImage image;

  @override
  Widget build(BuildContext context) {
    final ImageDetailState state = context
        .select<ImageDetailCubit, ImageDetailState>(
          (ImageDetailCubit cubit) => cubit.state,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Save to gallery',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            switch (state.downloadStatus) {
              DownloadStatus.idle => SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.read<ImageDetailCubit>().download(image),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download image'),
                ),
              ),
              DownloadStatus.downloading => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LinearProgressIndicator(
                    value: state.downloadProgress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Downloading ${(state.downloadProgress * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              DownloadStatus.success => Row(
                children: <Widget>[
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Saved to your photo gallery.')),
                  IconButton(
                    tooltip: 'Download again',
                    icon: const Icon(Icons.replay_rounded),
                    onPressed: () {
                      final ImageDetailCubit cubit = context
                          .read<ImageDetailCubit>();
                      cubit.resetDownload();
                      cubit.download(image);
                    },
                  ),
                ],
              ),
              DownloadStatus.failure => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    state.downloadError ?? 'Download failed.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      final ImageDetailCubit cubit = context
                          .read<ImageDetailCubit>();
                      cubit.resetDownload();
                      cubit.download(image);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _FavoriteAction extends StatelessWidget {
  const _FavoriteAction({required this.image});
  final GalleryImage image;

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = context.select<FavoritesCubit, bool>(
      (FavoritesCubit cubit) => cubit.state.isFavorite(image.id),
    );

    return IconButton(
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.redAccent : null,
      ),
      onPressed: () {
        context.read<FavoritesCubit>().toggle(image);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite ? 'Removed from favorites' : 'Added to favorites',
            ),
            duration: const Duration(milliseconds: 900),
          ),
        );
      },
    );
  }
}

class _ShareAction extends StatelessWidget {
  const _ShareAction({required this.image});
  final GalleryImage image;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Share',
      icon: const Icon(Icons.share_outlined),
      onPressed: () => SharePlus.instance.share(
        ShareParams(
          subject: 'Check out this photo on Pixabay',
          text:
              '${Formatters.titleCase(image.user)} — ${image.tags.join(', ')}\n${image.pageUrl}',
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
}
