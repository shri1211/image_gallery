import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnv {
  AppEnv._();

  static const String _dartDefinePixabayApiKey = String.fromEnvironment(
    'PIXABAY_API_KEY',
  );

  static String get pixabayApiKey {
    if (dotenv.isInitialized) {
      final fromFile = dotenv.maybeGet('PIXABAY_API_KEY') ?? '';
      if (fromFile.isNotEmpty) return fromFile;
    }
    return _dartDefinePixabayApiKey;
  }

  static const String pixabayBaseUrl = String.fromEnvironment(
    'PIXABAY_BASE_URL',
    defaultValue: 'https://pixabay.com/api',
  );

  static bool get hasPixabayApiKey => pixabayApiKey.isNotEmpty;
}
