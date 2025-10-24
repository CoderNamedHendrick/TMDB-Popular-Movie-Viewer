import 'package:dart_mappable/dart_mappable.dart';

part 'popular_movies_query.mapper.dart';

@MappableClass()
final class PopularMoviesQueryParamsDto with PopularMoviesQueryParamsDtoMappable {
  final String language;
  final int page;
  final String? region;

  const PopularMoviesQueryParamsDto({this.language = 'en-US', this.page = 1, this.region});
}
