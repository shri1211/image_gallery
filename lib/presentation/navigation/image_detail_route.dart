import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/gallery_image.dart';
import '../bloc/favorites/favorites_cubit.dart';
import '../screens/detail/image_detail_screen.dart';

Route<void> imageDetailRoute(BuildContext context, GalleryImage image) {
  return MaterialPageRoute<void>(
    builder: (_) => BlocProvider<FavoritesCubit>.value(
      value: context.read<FavoritesCubit>(),
      child: ImageDetailScreen(image: image),
    ),
  );
}
