sealed class Failure {
  const Failure(this.message, {this.code});

  final String message;

  final String? code;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

class DownloadFailure extends Failure {
  const DownloadFailure(super.message, {super.code});
}

class MissingApiKeyFailure extends Failure {
  const MissingApiKeyFailure(super.message) : super(code: 'missing_api_key');
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
