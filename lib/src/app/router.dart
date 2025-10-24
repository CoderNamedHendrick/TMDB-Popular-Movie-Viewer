import 'package:flutter/material.dart';

import '../features/movie_viewer/domain/domain.dart';
import '../features/movie_viewer/presentation/presentation.dart';

class MovieViewerRoutes {
  const MovieViewerRoutes._();

  static const popularMovies = 'popular-movies';
  static const movieDetails = 'movie-details';
}

class MovieViewerRouter {
  MovieViewerRouter._();

  static MovieViewerRouter instance = MovieViewerRouter._();

  final navigator = GlobalKey<NavigatorState>();

  Map<String, WidgetBuilder> get routes {
    return {
      MovieViewerRoutes.popularMovies: (context) => PopularMoviesListScreen(
        onMovie: (movie) {
          Navigator.of(context).pushNamed(MovieViewerRoutes.movieDetails, arguments: movie);
        },
      ),
    };
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MovieViewerRoutes.movieDetails:
        assert(
          settings.arguments is MovieResponseDto,
          'Argument passed must be MovieResponse, type passed is ${settings.arguments.runtimeType}',
        );

        return MaterialPageRoute(
          builder: (context) => MovieDetailScreen(movie: settings.arguments as MovieResponseDto),
        );
      default:
        return null;
    }
  }
}
