final class ApiConfig {
  const ApiConfig._();

  static const instance = ApiConfig._();

  String get getPopularMovies => 'https://api.themoviedb.org/3/movie/popular';
}
