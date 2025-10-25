import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';
import '../application/application.dart';
import '../application/search_movies/vm.dart';
import '../widgets/widgets.dart';

class PopularMoviesListScreen extends ConsumerStatefulWidget {
  const PopularMoviesListScreen({super.key, required this.onMovie});

  final void Function(MovieResponseDto) onMovie;

  @override
  ConsumerState<PopularMoviesListScreen> createState() => _PopularMoviesListScreenState();
}

class _PopularMoviesListScreenState extends ConsumerState<PopularMoviesListScreen> {
  final scrollController = ScrollController();

  late final Debounceable<UiState<List<MovieResponseDto>>, String> _debouncedSearch;
  late Iterable<Widget> _lastOptions = <Widget>[];

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
      _debouncedSearch = debounce<UiState<List<MovieResponseDto>>, String>(ref.read(searchMoviesVm.notifier).search);
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
        actions: [
          SearchAnchor(
            viewBackgroundColor: context.colorScheme.primary,
            viewHintText: 'Search movies',
            headerHintStyle: TextStyle(color: context.colorScheme.surface),
            dividerColor: context.colorScheme.inversePrimary,
            viewOnChanged: (value) {},
            viewBuilder: (widgets) {
              return ListView(
                padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
                children: [...widgets],
              );
            },
            builder: (context, controller) {
              return IconButton(onPressed: controller.openView, icon: const Icon(Icons.search));
            },
            suggestionsBuilder: (context, controller) async {
              final uiState = await _debouncedSearch(controller.text);

              if (uiState == null) return _lastOptions;

              _lastOptions = switch (uiState) {
                Uninitialised<List<MovieResponseDto>>() => [],
                Success<List<MovieResponseDto>>(:var result) => [
                  ...result.mapIndexed((i, r) {
                    return MovieTile(
                      key: Key('movie$i'),
                      leading: Hero(
                        tag: r.id,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colorScheme.onPrimaryContainer,
                            image: r.posterPath.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage('https://image.tmdb.org/t/p/w185${r.posterPath}'),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      title: Text(r.title, style: TextStyle(color: context.colorScheme.surface)),
                      onTap: () {
                        widget.onMovie(r);
                      },
                    );
                  }),
                ],
                Loading<List<MovieResponseDto>>() => [MovieTileShimmer.list],
                Failure<List<MovieResponseDto>>(:var error) => [
                  Text('An error occurred\n$error', textAlign: TextAlign.center),
                ],
              };

              return _lastOptions;
            },
          ),
        ],
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

              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  await ref.read(popularMoviesVm.notifier).fetchMovies();
                },
                child: ListView(
                  controller: scrollController,
                  children: [
                    ...result.mapIndexed(
                      (i, r) => MovieTile(
                        key: Key('movie$i'),
                        leading: Hero(
                          tag: r.id,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colorScheme.onPrimaryContainer,
                              image: r.posterPath.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage('https://image.tmdb.org/t/p/w185${r.posterPath}'),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
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
                ),
              );
            },
          ),
    );
  }
}
