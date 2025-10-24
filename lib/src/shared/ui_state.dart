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
