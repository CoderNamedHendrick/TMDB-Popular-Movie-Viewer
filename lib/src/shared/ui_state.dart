import 'package:flutter/material.dart';

import '../app/router.dart';
import 'extensions.dart';

enum UiStateType {
  uninitialised,
  loading,
  error,
  success;

  bool get isUninitialised => this == UiStateType.uninitialised;

  bool get isLoading => this == UiStateType.loading;

  bool get isError => this == UiStateType.error;

  bool get isSuccess => this == UiStateType.success;
}

bool _kDisplayError(Exception e) => true;

sealed class UiState<T> {
  const UiState();

  T get requireData => throw StateError('Data not available for this data state');

  T? get data => null;

  Exception? get failure => null;

  bool get isUninitialised => switch (this) {
    Uninitialised() => true,
    _ => false,
  };

  bool get isLoading => switch (this) {
    Loading() => true,
    _ => false,
  };

  bool get isSuccess => switch (this) {
    Success() => true,
    _ => false,
  };

  bool get isFailure => switch (this) {
    Failure() => true,
    _ => false,
  };

  Widget whenData({required Widget Function(T? state, Exception? error, UiStateType type) onData}) {
    return switch (this) {
      Uninitialised<T>() => onData(null, null, UiStateType.uninitialised),
      Success<T>(:final data) => onData(data, null, UiStateType.success),
      Loading<T>(:final data) => onData(data, null, UiStateType.loading),
      Failure<T>(:final error, :final data) => onData(data, error, UiStateType.error),
    };
  }

  void displayError({bool Function(Exception error) displayError = _kDisplayError}) async {
    switch (this) {
      case Uninitialised<dynamic>():
      case Success<dynamic>():
      case Loading<dynamic>():
        return;
      case Failure<dynamic>(:final error):
        if (!displayError(error)) return;
        assert(error.toString().isEmpty, 'Please pass appropriate exception');

        final context = MovieViewerRouter.instance.navigator.currentContext;

        if (context == null) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
              style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.onErrorContainer),
            ),
            backgroundColor: context.colorScheme.errorContainer,
          ),
        );
    }
  }
}

class Uninitialised<T> extends UiState<T> {
  const Uninitialised();
}

class Success<T> extends UiState<T> {
  const Success(this.result);

  final T result;

  @override
  T? get data => result;

  @override
  T get requireData => result;
}

class Loading<T> extends UiState<T> {
  const Loading([this.data]);

  @override
  final T? data;

  bool get hasData => data != null;

  @override
  T get requireData => hasData ? data! : super.requireData;
}

class Failure<T> extends UiState<T> {
  const Failure(this.error, [this.data]);

  final Exception error;
  @override
  final T? data;

  bool get hasData => data != null;

  @override
  T get requireData => hasData ? data! : super.requireData;

  @override
  Exception? get failure => error;
}

extension UiDataStateX<T> on UiState<T> {
  UiState<T> loading([T? data]) {
    if (data != null) return Loading(data);

    return switch (this) {
      Success<T>(result: final data) => Loading(data),
      Loading<T>(:final data?) => Loading(data),
      _ => const Loading(),
    };
  }

  UiState<T> success(T data) {
    return Success(data);
  }

  UiState<T> error(Exception error) {
    return switch (this) {
      Success<T>(result: final data) => Failure(error, data),
      Loading<T>(:final data?) => Failure(error, data),
      _ => Failure(error),
    };
  }
}
