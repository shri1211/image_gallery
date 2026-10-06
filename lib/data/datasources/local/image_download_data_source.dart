import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/gallery_image.dart';

class ImageDownloadDataSource {
  ImageDownloadDataSource(this._dio);

  final Dio _dio;

  Future<String> download(
    GalleryImage image,
    void Function(double progress) onProgress,
  ) async {
    final String url = image.largeImageUrl.isNotEmpty
        ? image.largeImageUrl
        : image.webformatUrl;
    final String fileName = 'image_gallery_${image.id}.jpg';

    await _ensurePermission();

    final Directory tempDir = await getTemporaryDirectory();
    final File target = File('${tempDir.path}/$fileName');

    try {
      await _dio.download(
        url,
        target.path,
        options: Options(extra: const <String, dynamic>{'image_gallery': true}),
        onReceiveProgress: (int received, int total) {
          if (total <= 0) return;
          onProgress((received / total).clamp(0.0, 1.0));
        },
      );
    } on DioException catch (error) {
      throw DownloadException(
        _messageFor(error),
        code: error.response?.statusCode?.toString(),
      );
    }

    if (!await target.exists() || await target.length() == 0) {
      throw const DownloadException('The downloaded file is empty.');
    }

    try {
      await Gal.putImage(target.path);
    } on GalException catch (error) {
      throw const DownloadException(
        'The image could not be added to your gallery. '
        'Please make sure the Photos/Gallery permission is allowed.',
      ).codeMessage(error.type.name);
    } finally {
      if (await target.exists()) await target.delete();
    }

    return url;
  }

  Future<void> _ensurePermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw const PermissionException(
        'Downloading to the gallery is only supported on Android and iOS. please don"\t try it on web',
      );
    }
    if (!await Gal.hasAccess()) {
      final bool granted = await Gal.requestAccess();
      if (!granted) {
        throw const PermissionException(
          'Storage/Photos permission was denied. '
          'Enable it in Settings to download images.',
        );
      }
    }
  }

  String _messageFor(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        'Download failed. Check your internet connection and try again.',
      DioExceptionType.badResponse =>
        'The image could not be downloaded (${error.response?.statusCode}).',
      _ => 'Download failed. Please try again.',
    };
  }
}

extension on DownloadException {
  DownloadException codeMessage(String code) =>
      DownloadException(message, code: code);
}
