final class ApiConfig {
  const ApiConfig._();

  static const instance = ApiConfig._();

  String get getPopularMovies => 'https://api.themoviedb.org/3/movie/popular';

  String get getSearchMovie => 'https://api.themoviedb.org/3/search/movie';
}
