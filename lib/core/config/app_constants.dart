abstract final class AppConstants {
  AppConstants._();

  static const int imagesPerPage = 40;

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const Duration searchDebounce = Duration(milliseconds: 400);

  static const String favoritesPrefsKey = 'favorite_images_v1';

  static const int maxDescriptionTags = 5;
}

abstract final class ImageCategories {
  ImageCategories._();

  static const String all = '';

  static const List<String> allCategories = <String>[
    all,
    'backgrounds',
    'fashion',
    'nature',
    'science',
    'education',
    'feelings',
    'health',
    'people',
    'religion',
    'places',
    'animals',
    'industry',
    'computer',
    'food',
    'sports',
    'transportation',
    'travel',
    'buildings',
    'business',
    'music',
  ];
}
