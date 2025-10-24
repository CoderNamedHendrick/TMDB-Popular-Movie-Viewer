import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/shared.dart';
import '../../../domain/domain.dart';
import 'state.dart';

final searchMoviesVm = AutoDisposeNotifierProvider<SearchMoviesViewModel, SearchMoviesState>(
  () => SearchMoviesViewModel(),
);

final class SearchMoviesViewModel extends AutoDisposeNotifier<SearchMoviesState> {
  late MoviesRepository _repository;

  @override
  SearchMoviesState build() {
    _repository = ref.read(moviesRepositoryProvider);
    return const SearchMoviesState.initial();
  }

  Future<UiState<List<MovieResponseDto>>> search(String query) async {
    state = state.copyWith(moviesUiState: const Loading(), query: query);

    final result = await _repository.searchMovies(SearchMovieQueryParamsDto(query: query));

    state = result.fold(
      (l) => state.copyWith(moviesUiState: state.moviesUiState.error(l)),
      (r) => state.copyWith(moviesUiState: state.moviesUiState.success(r.results), maxPages: r.page + 1, page: r.page),
    );

    return state.moviesUiState;
  }
}
