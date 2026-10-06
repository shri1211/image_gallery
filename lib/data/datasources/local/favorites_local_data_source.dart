import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/pixabay_image_model.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  List<PixabayImageModel> readAll() {
    final String? raw = _preferences.getString(AppConstants.favoritesPrefsKey);
    if (raw == null || raw.isEmpty) return const <PixabayImageModel>[];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (dynamic e) =>
                PixabayImageModel.fromJson(e as Map<String, dynamic>),
          )
          .where((PixabayImageModel m) => m.id > 0)
          .toList();
    } on FormatException catch (error) {
      throw CacheException(
        'Stored favorites could not be read.',
        code: error.toString(),
      );
    } on TypeError catch (error) {
      throw CacheException(
        'Stored favorites could not be read.',
        code: error.toString(),
      );
    }
  }

  Future<void> writeAll(List<PixabayImageModel> favorites) async {
    final String payload = jsonEncode(
      favorites.map((PixabayImageModel m) => m.toJson()).toList(),
    );
    final bool ok = await _preferences.setString(
      AppConstants.favoritesPrefsKey,
      payload,
    );
    if (!ok) {
      throw CacheException('Favorites could not be persisted.');
    }
  }
}
