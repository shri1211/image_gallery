import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/app.dart';
import 'package:image_gallery/core/di/injector.dart';
import 'package:image_gallery/presentation/screens/detail/image_detail_screen.dart';
import 'package:image_gallery/presentation/widgets/gallery_image_tile.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    try {
      await dotenv.load();
    } catch (_) {}
    await setupLocator();
  });

  testWidgets('tapping a gallery image opens the detail screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    final Finder tile = find.byType(GalleryImageTile);
    for (int i = 0; i < 30 && tile.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(tile, findsWidgets);

    await tester.tap(tile.first);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ImageDetailScreen), findsOneWidget);
  });
}
