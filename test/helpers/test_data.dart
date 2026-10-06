import 'package:image_gallery/data/models/pixabay_image_model.dart';
import 'package:image_gallery/domain/entities/gallery_image.dart';

Map<String, dynamic> pixabayJson({int id = 42}) {
  return <String, dynamic>{
    'id': id,
    'type': 'photo',
    'tags': 'nature, mountain, lake',
    'previewURL': 'https://pixabay.com/preview/$id.jpg',
    'previewWidth': 150,
    'previewHeight': 100,
    'webformatURL': 'https://pixabay.com/webformat/$id.jpg',
    'webformatWidth': 640,
    'webformatHeight': 426,
    'largeImageURL': 'https://pixabay.com/large/$id.jpg',
    'imageWidth': 4000,
    'imageHeight': 2664,
    'imageSize': 1823456,
    'views': 12000,
    'downloads': 2300,
    'likes': 150,
    'comments': 22,
    'user': 'johndoe',
    'userImageURL': 'https://cdn.pixabay.com/user/avatar.jpg',
    'pageURL': 'https://pixabay.com/photos/example-$id/',
  };
}

GalleryImage buildGalleryImage({int id = 42}) {
  final PixabayImageModel model = PixabayImageModel.fromJson(
    pixabayJson(id: id),
  );
  return model;
}
