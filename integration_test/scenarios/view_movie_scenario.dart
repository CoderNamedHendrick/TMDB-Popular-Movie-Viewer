import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:tmdb_movie_viewer/src/app/app.dart';
import 'package:tmdb_movie_viewer/src/features/movie_viewer/presentation/presentation.dart';
import 'package:tmdb_movie_viewer/src/features/movie_viewer/presentation/widgets/widgets.dart';

import '../common.dart';

void main() {
  patrolWidgetTest('User views movie details after navigating around', (tester) async {
    await tester.pumpWidgetAndSettle(const ProviderScope(child: MovieViewerApp()));

    // Given:
    expect(await tester("Movie viewer").safeExists(), true);

    // When:
    expect(await tester(MovieTile).safeExists(), true);

    // Then:
    await tester(
      ListView,
    ).scrollTo(scrollDirection: AxisDirection.down, dragDuration: const Duration(milliseconds: 400));

    // When:
    expect(tester(MovieTile).exists, true);

    // Then:
    final tiles = tester(MovieTile).allCandidates;

    if (tiles.isEmpty) throw Exception('Can\'t find a movie tile');

    final tile = await tester(Key('movie${Random().nextInt(30)}')).scrollTo();

    await tile.tap();

    // When:
    expect(await tester(MovieDetailScreen).safeExists(), true);

    // Then:
    expect(await tester(Text).safeExists(), true);

    await Future.delayed(waitTime);
  });
}
