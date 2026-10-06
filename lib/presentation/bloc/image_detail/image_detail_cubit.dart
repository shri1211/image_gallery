import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/result.dart';
import '../../../domain/entities/gallery_image.dart';
import '../../../domain/usecases/download_image.dart';
import 'image_detail_state.dart';

class ImageDetailCubit extends Cubit<ImageDetailState> {
  ImageDetailCubit(this._downloadImage) : super(const ImageDetailState());

  final DownloadImageUseCase _downloadImage;

  Future<void> download(GalleryImage image) async {
    if (state.isDownloading) return;

    emit(
      const ImageDetailState(
        downloadStatus: DownloadStatus.downloading,
        downloadProgress: 0,
      ),
    );

    final Result<String> result = await _downloadImage(
      DownloadParams(
        image: image,
        onProgress: (double progress) {
          if (isClosed) return;
          emit(state.copyWith(downloadProgress: progress));
        },
      ),
    );

    if (isClosed) return;

    result.fold(
      (String savedAt) {
        emit(
          ImageDetailState(
            downloadStatus: DownloadStatus.success,
            downloadProgress: 1,
            savedAt: savedAt,
          ),
        );
      },
      (failure) {
        emit(
          ImageDetailState(
            downloadStatus: DownloadStatus.failure,
            downloadError: failure.message,
          ),
        );
      },
    );
  }

  void resetDownload() => emit(const ImageDetailState());
}
