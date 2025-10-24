import 'package:dart_mappable/dart_mappable.dart';

import '../../../../../shared/shared.dart';
import '../../../domain/domain.dart';

part 'state.mapper.dart';

@MappableClass()
final class PopularMoviesState with PopularMoviesStateMappable {
  final UiState<List<MovieResponseDto>> moviesUiState;
  final int page;
  final int maxPages;

  const PopularMoviesState({required this.moviesUiState, required this.page, required this.maxPages});

  const PopularMoviesState.initial() : moviesUiState = const Uninitialised(), page = 1, maxPages = 2;
}
