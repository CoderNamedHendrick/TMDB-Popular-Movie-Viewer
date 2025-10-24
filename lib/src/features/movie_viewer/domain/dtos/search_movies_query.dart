import 'package:dart_mappable/dart_mappable.dart';

part 'search_movies_query.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
final class SearchMovieQueryParamsDto with SearchMovieQueryParamsDtoMappable {
  final String query;
  final bool includeAdult;
  final String language;
  final int page;
  final String? region;
  final String? year;

  const SearchMovieQueryParamsDto({
    required this.query,
    this.includeAdult = false,
    this.language = 'en-US',
    this.page = 1,
    this.region,
    this.year,
  });
}
