import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';
import '../application/application.dart';
import '../widgets/widgets.dart';

class PopularMoviesListScreen extends ConsumerStatefulWidget {
  const PopularMoviesListScreen({super.key, required this.onMovie});

  final void Function(MovieResponseDto) onMovie;

  @override
  ConsumerState<PopularMoviesListScreen> createState() => _PopularMoviesListScreenState();
}

class _PopularMoviesListScreenState extends ConsumerState<PopularMoviesListScreen> {
  final scrollController = ScrollController();

  void _fetchNextPageListener() {
    if (!scrollController.hasClients) return;

    if (scrollController.isAtEndOfList) {
      ref.read(popularMoviesVm.notifier).fetchNextMovies();
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(popularMoviesVm.notifier).fetchMovies();
    });

    scrollController.addListener(_fetchNextPageListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie viewer'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: ref
          .watch(popularMoviesVm.select((s) => s.moviesUiState))
          .whenData(
            onData: (result, error, type) {
              if (result == null) {
                if (type.isLoading) return MovieTileShimmer.list;

                if (error != null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      Text('An error occurred\n$error', textAlign: TextAlign.center),
                      TextButton(
                        onPressed: ref.read(popularMoviesVm.notifier).fetchMovies,
                        child: const Text('Try again'),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              }

              if (result.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    const Text('No movies found...\nTry again later', textAlign: TextAlign.center),
                    TextButton(
                      onPressed: ref.read(popularMoviesVm.notifier).fetchMovies,
                      child: const Text('Get movies'),
                    ),
                  ],
                );
              }

              return ListView(
                controller: scrollController,
                children: [
                  ...result.map(
                    (r) => MovieTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage('https://image.tmdb.org/t/p/w185${r.posterPath}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(r.title),
                      onTap: () {
                        widget.onMovie(r);
                      },
                    ),
                  ),

                  if (type.isLoading) const MovieTileShimmer(),
                ],
              );
            },
          ),
    );
  }
}
