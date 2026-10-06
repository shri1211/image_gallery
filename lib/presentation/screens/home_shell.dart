import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../bloc/favorites/favorites_cubit.dart';
import '../bloc/gallery/gallery_cubit.dart';
import 'favorites/favorites_screen.dart';
import 'gallery/gallery_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final GalleryCubit _galleryCubit;
  late final FavoritesCubit _favoritesCubit;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _galleryCubit = locator<GalleryCubit>()..loadInitial();
    _favoritesCubit = locator<FavoritesCubit>()..load();
  }

  @override
  void dispose() {
    _galleryCubit.close();
    _favoritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object>>>[
        BlocProvider<GalleryCubit>.value(value: _galleryCubit),
        BlocProvider<FavoritesCubit>.value(value: _favoritesCubit),
      ],
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _tabIndex == 0
                ? const GalleryScreen(key: ValueKey<String>('gallery'))
                : const FavoritesScreen(key: ValueKey<String>('favorites')),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (int index) =>
              setState(() => _tabIndex = index),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Gallery',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}
