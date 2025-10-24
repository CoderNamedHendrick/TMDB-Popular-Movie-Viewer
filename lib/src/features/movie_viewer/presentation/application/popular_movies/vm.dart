import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/shared.dart';
import '../../../domain/domain.dart';
import 'state.dart';

final popularMoviesVm = AutoDisposeNotifierProvider(() => PopularMoviesViewModel());

final class PopularMoviesViewModel extends AutoDisposeNotifier<PopularMoviesState> {
  late MoviesRepository _repository;

  @override
  PopularMoviesState build() {
    _repository = ref.read(moviesRepositoryProvider);
    return const PopularMoviesState.initial();
  }

  Future<void> fetchMovies() async {
    state = state.copyWith(moviesUiState: const Loading());

    final result = await _repository.fetchPopularMovies();

    state = result.fold(
      (l) => state.copyWith(moviesUiState: state.moviesUiState.error(l)),
      (r) => state.copyWith(moviesUiState: state.moviesUiState.success(r.results), maxPages: r.page + 1, page: r.page),
    );
  }

  Future<void> fetchNextMovies() async {
    if (state.page >= state.maxPages || state.moviesUiState.isLoading) return;

    state = state.copyWith(moviesUiState: state.moviesUiState.loading());

    final result = await _repository.fetchPopularMovies(PopularMoviesQueryParamsDto(page: state.page + 1));

    state = result.fold((l) => state.copyWith(moviesUiState: state.moviesUiState.error(l)..displayError()), (r) {
      final data = state.moviesUiState.requireData;

      return state.copyWith(
        page: r.page,
        maxPages: r.results.isEmpty ? r.page : r.page + 1,
        moviesUiState: state.moviesUiState.success(List.from([...data, ...r.results])),
      );
    });
  }
}
