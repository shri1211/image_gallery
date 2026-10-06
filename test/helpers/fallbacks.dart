import 'package:image_gallery/core/usecase/usecase.dart';
import 'package:image_gallery/domain/entities/gallery_image.dart';
import 'package:image_gallery/domain/repositories/image_repository.dart';
import 'package:image_gallery/domain/usecases/download_image.dart';
import 'package:mocktail/mocktail.dart';

import 'test_data.dart';

/// Registers reusable mocktail [fallback] values for the custom types used in
/// mocked use-case/repository signatures.
void registerTestFallbacks() {
  registerFallbackValue(const NoParams());
  registerFallbackValue(const ImageQuery(page: 1));
  registerFallbackValue(buildGalleryImage());
  registerFallbackValue((double _) {});
  registerFallbackValue(
    DownloadParams(image: buildGalleryImage(), onProgress: (_) {}),
  );
}
