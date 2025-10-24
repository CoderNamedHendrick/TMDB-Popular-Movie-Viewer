import '../../../shared/shared.dart';
import '../domain/domain.dart';

final class RemoteMoviesRepository implements MoviesRepository {
  final DioNetworkClient _client;

  const RemoteMoviesRepository(this._client);

  @override
  FutureExceptionOr<PopularMoviesResponseDto> fetchPopularMovies([
    PopularMoviesQueryParamsDto query = const PopularMoviesQueryParamsDto(),
  ]) async {
    final result = await _client.call(
      path: ApiConfig.instance.getPopularMovies,
      request: RequestType.get,
      queryParams: query.toMap()
        ..addAll({'api_key': const String.fromEnvironment('TMDB_API_KEY')})
        ..removeWhere((k, v) => v == null),
    );

    return processData((p0) => PopularMoviesResponseDtoMapper.fromMap(p0), result);
  }
}
