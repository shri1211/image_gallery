import '../../core/error/result.dart';
import '../entities/paged_images.dart';

class ImageQuery {
  const ImageQuery({required this.page, this.query = '', this.category = ''});

  final int page;

  final String query;

  final String category;
}

abstract class ImageRepository {
  Future<Result<PagedImages>> getImages(ImageQuery query);
}
