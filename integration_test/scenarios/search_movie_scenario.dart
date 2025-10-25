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
  patrolWidgetTest('User searches for a movie and enter its details', (tester) async {
    await tester.pumpWidgetAndSettle(const ProviderScope(child: MovieViewerApp()));

    // Given:
    expect(await tester("Movie viewer").safeExists(), true);

    // When:
    expect(await tester(IconButton).safeExists(), true);

    // Then:
    await tester(IconButton).tap(); // search button

    // When:
    expect(await tester(TextField).safeExists(), true);

    // Then:
    await tester(TextField).enterText('hell');

    // When:
    expect(await tester(MovieTile).safeExists(), true);

    // Then:
    final tile = await tester(Key('movie${Random().nextInt(10)}')).scrollTo();

    await tile.tap();

    // When:
    expect(await tester(MovieDetailScreen).safeExists(), true);

    // Then:
    expect(await tester(Text).safeExists(), true);
    await tester(BackButton).tap();

    // When:
    expect(await tester(TextField).safeExists(), true);

    // Then:
    await tester(BackButton).tap();

    // When:
    expect(await tester(PopularMoviesListScreen).safeExists(), true);

    // Then:
    expect(tester(MovieTile).exists, true);
  });
}
