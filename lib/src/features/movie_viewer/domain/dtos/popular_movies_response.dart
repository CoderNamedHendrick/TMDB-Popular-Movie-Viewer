import 'package:dart_mappable/dart_mappable.dart';

part 'popular_movies_response.mapper.dart';

@MappableClass()
final class PopularMoviesResponseDto with PopularMoviesResponseDtoMappable {
  final int page;
  final List<MovieResponseDto> results;

  const PopularMoviesResponseDto({required this.page, required this.results});
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
final class MovieResponseDto with MovieResponseDtoMappable {
  final bool adult;
  final String backdropPath;
  final List<int> genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final num popularity;
  final String posterPath;
  final String releaseDate;
  final String title;
  final bool video;
  final num voteAverage;
  final int voteCount;

  const MovieResponseDto({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });
}
