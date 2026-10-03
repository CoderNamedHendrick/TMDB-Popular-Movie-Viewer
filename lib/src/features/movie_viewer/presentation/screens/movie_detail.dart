import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final MovieResponseDto movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(key: ValueKey('movie_detail_back_button')),
        title: Text(movie.title, key: const ValueKey('movie_detail_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ).add(EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom)),
        child: Column(
          spacing: 12,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6 + 40,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Hero(
                      tag: movie.id,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          color: context.colorScheme.onPrimaryContainer,
                          image: movie.posterPath.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage('https://image.tmdb.org/t/p/w500/${movie.posterPath}'),
                                  fit: BoxFit.fill,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    bottom: 0,
                    child: SizedBox.square(
                      dimension: 60,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.blue.shade800, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  '${(movie.voteAverage * 10).ceil()}%',
                                  key: const ValueKey('movie_detail_rating'),
                                  style: context.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.colorScheme.surface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 4,
                            right: 4,
                            left: 4,
                            bottom: 4,
                            // Pointer-transparent so the percentage text underneath stays hittable (tests).
                            child: IgnorePointer(
                              child: TweenAnimationBuilder(
                                tween: Tween(begin: 0.0, end: movie.voteAverage / 10),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeIn,
                                builder: (context, value, child) {
                                  return CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 3,
                                    strokeCap: StrokeCap.round,
                                    color: switch (value) {
                                      <= 0.3 => Colors.red,
                                      <= 0.6 => Colors.orange,
                                      _ => Colors.green,
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text(movie.overview, key: const ValueKey('movie_detail_overview'), style: context.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
