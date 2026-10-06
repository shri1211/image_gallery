import 'package:equatable/equatable.dart';

import 'failures.dart';

sealed class Result<T> extends Equatable {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  List<Object?> get props => <Object?>[data];
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

extension ResultX<T> on Result<T> {
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(Failure failure) onFailure,
  ) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      FailureResult<T>(:final failure) => onFailure(failure),
    };
  }

  bool get isError => this is FailureResult<T>;
}
