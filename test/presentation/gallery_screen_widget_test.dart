import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/core/error/failures.dart';
import 'package:image_gallery/core/error/result.dart';
import 'package:image_gallery/core/utils/debouncer.dart';
import 'package:image_gallery/domain/entities/paged_images.dart';
import 'package:image_gallery/domain/usecases/get_images.dart';
import 'package:image_gallery/presentation/bloc/gallery/gallery_cubit.dart';
import 'package:image_gallery/presentation/screens/gallery/gallery_screen.dart';
import 'package:image_gallery/presentation/widgets/error_retry_view.dart';
import 'package:image_gallery/presentation/widgets/shimmer_grid.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fallbacks.dart';

class _MockGetImages extends Mock implements GetImagesUseCase {}

Widget _host(GalleryCubit cubit) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object>>>[
        BlocProvider<GalleryCubit>.value(value: cubit),
      ],
      child: const Scaffold(body: GalleryScreen()),
    ),
  );
}

void main() {
  registerTestFallbacks();
  late _MockGetImages getImages;

  setUp(() {
    getImages = _MockGetImages();
  });

  testWidgets('shows a shimmer grid while the first page loads', (
    WidgetTester tester,
  ) async {
    final Completer<Result<PagedImages>> gate =
        Completer<Result<PagedImages>>();
    when(() => getImages(any())).thenAnswer((_) => gate.future);

    final GalleryCubit cubit = GalleryCubit(
      getImages,
      debouncer: Debouncer(duration: Duration.zero),
    );
    addTearDown(cubit.close);

    unawaited(cubit.loadInitial());
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    expect(find.byType(ShimmerGrid), findsOneWidget);
    expect(find.byType(GalleryScreen), findsOneWidget);
  });

  testWidgets('shows the error view and retries on initial failure', (
    WidgetTester tester,
  ) async {
    when(() => getImages(any())).thenAnswer(
      (_) async =>
          const FailureResult<PagedImages>(NetworkFailure('No connectivity')),
    );

    final GalleryCubit cubit = GalleryCubit(
      getImages,
      debouncer: Debouncer(duration: Duration.zero),
    );
    addTearDown(cubit.close);
    unawaited(cubit.loadInitial());

    await tester.pumpWidget(_host(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorRetryView), findsOneWidget);
    expect(find.text('No connectivity'), findsOneWidget);

    when(() => getImages(any())).thenAnswer(
      (_) async => Success<PagedImages>(
        const PagedImages(images: [], page: 1, total: 0, hasMore: false),
      ),
    );
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorRetryView), findsNothing);
  });
}
