import 'package:equatable/equatable.dart';

enum DownloadStatus { idle, downloading, success, failure }

class ImageDetailState extends Equatable {
  const ImageDetailState({
    this.downloadStatus = DownloadStatus.idle,
    this.downloadProgress = 0,
    this.downloadError,
    this.savedAt,
  });

  final DownloadStatus downloadStatus;

  final double downloadProgress;
  final String? downloadError;
  final String? savedAt;

  bool get isDownloading => downloadStatus == DownloadStatus.downloading;

  ImageDetailState copyWith({
    DownloadStatus? downloadStatus,
    double? downloadProgress,
    String? downloadError,
    String? savedAt,
    bool clearDownloadError = false,
  }) {
    return ImageDetailState(
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadError: clearDownloadError
          ? null
          : (downloadError ?? this.downloadError),
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    downloadStatus,
    downloadProgress,
    downloadError,
    savedAt,
  ];
}
