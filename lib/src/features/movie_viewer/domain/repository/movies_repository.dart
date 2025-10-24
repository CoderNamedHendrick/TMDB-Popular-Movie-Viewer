import '../../data/remote_movies_repository.dart';
import '../dtos/dtos.dart';
import '../../../../shared/network/client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class MoviesRepository {
  FutureExceptionOr<PopularMoviesResponseDto> fetchPopularMovies([
    PopularMoviesQueryParamsDto query = const PopularMoviesQueryParamsDto(),
  ]);
}

final moviesRepositoryProvider = Provider.autoDispose<MoviesRepository>((ref) {
  return RemoteMoviesRepository(ref.read(networkClientProvider));
});
