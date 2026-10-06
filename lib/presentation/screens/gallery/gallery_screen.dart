import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/config/app_constants.dart';
import '../../../domain/entities/gallery_image.dart';
import '../../bloc/gallery/gallery_cubit.dart';
import '../../bloc/gallery/gallery_state.dart';
import '../../navigation/image_detail_route.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_retry_view.dart';
import '../../widgets/gallery_image_tile.dart';
import '../../widgets/shimmer_grid.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  static int crossAxisCountFor(double width) {
    if (width < 480) return 2;
    if (width < 700) return 3;
    if (width < 900) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final int crossAxisCount = crossAxisCountFor(width);

    return BlocBuilder<GalleryCubit, GalleryState>(
      buildWhen: (GalleryState previous, GalleryState current) {
        return previous.status != current.status ||
            previous.images != current.images ||
            previous.initialError != current.initialError ||
            previous.hasMore != current.hasMore;
      },
      builder: (BuildContext context, GalleryState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _GalleryHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<GalleryCubit>().refresh(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification.metrics.axis != Axis.vertical)
                      return false;
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 500) {
                      context.read<GalleryCubit>().loadMore();
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      _gridSliver(context, state, crossAxisCount),
                      _footer(context, state),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _gridSliver(
    BuildContext context,
    GalleryState state,
    int crossAxisCount,
  ) {
    if (state.isLoadingInitial) {
      return SliverToBoxAdapter(
        child: ShimmerGrid(crossAxisCount: crossAxisCount),
      );
    }

    if (state.status == GalleryStatus.failedInitial) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorRetryView(
          message: state.initialError ?? 'Something went wrong.',
          onRetry: () => context.read<GalleryCubit>().refresh(),
        ),
      );
    }

    if (state.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyView(
          title: state.isSearching ? 'No images found' : 'Nothing here yet',
          subtitle: state.isSearching
              ? 'Try a different keyword or category.'
              : 'Pull down to browse the latest photos.',
        ),
      );
    }

    if (state.status == GalleryStatus.loadingMore && state.images.isEmpty) {
      return SliverToBoxAdapter(
        child: ShimmerGrid(crossAxisCount: crossAxisCount),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childCount: state.images.length,
        itemBuilder: (BuildContext context, int index) {
          final GalleryImage image = state.images[index];
          return GalleryImageTile(
            image: image,
            onTap: () =>
                Navigator.of(context).push(imageDetailRoute(context, image)),
          );
        },
      ),
    );
  }

  Widget _footer(BuildContext context, GalleryState state) {
    if (state.status == GalleryStatus.loadingMore) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
      );
    }

    if (state.loadMoreError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  state.loadMoreError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => context.read<GalleryCubit>().loadMore(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Load more'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!state.hasMore && state.images.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'You have reached the end.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

class _GalleryHeader extends StatefulWidget {
  const _GalleryHeader();

  @override
  State<_GalleryHeader> createState() => _GalleryHeaderState();
}

class _GalleryHeaderState extends State<_GalleryHeader> {
  late final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    context.read<GalleryCubit>().search(value);
  }

  void _clearSearch() {
    _searchController.clear();
    _submitSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Infinite Gallery',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
                  return TextField(
                    key: const ValueKey<String>('gallery_search'),
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: _submitSearch,
                    decoration: InputDecoration(
                      hintText: 'Search images…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: value.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: _clearSearch,
                            ),
                    ),
                  );
                },
          ),
          const SizedBox(height: 12),
          CategoriesFilterBar(
            selectedCategory: context.select<GalleryCubit, String>(
              (GalleryCubit cubit) => cubit.state.category,
            ),
            onSelected: (String category) =>
                context.read<GalleryCubit>().selectCategory(category),
          ),
        ],
      ),
    );
  }
}

class CategoriesFilterBar extends StatelessWidget {
  const CategoriesFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ImageCategories.allCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final String category = ImageCategories.allCategories[index];
          final bool selected = category == selectedCategory;
          final String label = category.isEmpty
              ? 'All'
              : category[0].toUpperCase() + category.substring(1);
          return ChoiceChip(
            key: ValueKey<String>('category_$label'),
            label: Text(label),
            selected: selected,
            onSelected: (_) => onSelected(category),
            showCheckmark: false,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}
