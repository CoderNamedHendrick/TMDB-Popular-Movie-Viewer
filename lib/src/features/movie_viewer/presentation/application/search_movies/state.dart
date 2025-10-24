import 'package:dart_mappable/dart_mappable.dart';

import '../../../../../shared/shared.dart';
import '../../../domain/domain.dart';

part 'state.mapper.dart';

@MappableClass()
final class SearchMoviesState with SearchMoviesStateMappable {
  final UiState<List<MovieResponseDto>> moviesUiState;
  final int page;
  final int maxPages;
  final String query;

  const SearchMoviesState({
    required this.moviesUiState,
    required this.page,
    required this.maxPages,
    required this.query,
  });

  const SearchMoviesState.initial() : moviesUiState = const Uninitialised(), page = 1, maxPages = 1, query = '';
}
