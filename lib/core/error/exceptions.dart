sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class RemoteException extends AppException {
  const RemoteException(super.message, {super.code});
}

class ParsingException extends AppException {
  const ParsingException(super.message, {super.code});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

class DownloadException extends AppException {
  const DownloadException(super.message, {super.code});
}
