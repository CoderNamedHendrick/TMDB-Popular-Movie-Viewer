import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:tmdb_movie_viewer/src/app/app.dart';
import 'package:tmdb_movie_viewer/src/features/movie_viewer/presentation/presentation.dart';
import 'package:tmdb_movie_viewer/src/features/movie_viewer/presentation/widgets/widgets.dart';
import 'package:tmdb_movie_viewer/src/shared/shared.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

void main() {
  patrolTest('User views movie details after navigating around', (tester) async {
    await tester.pumpWidgetAndSettle(const ProviderScope(child: MovieViewerApp()));

    Permission.location.request();

    if (await tester.native2.isPermissionDialogVisible(timeout: const Duration(seconds: 5))) {
      await tester.native2.grantPermissionWhenInUse();
    }

    // Given:
    expect(await tester("Movie viewer").safeExists(), true);

    // When:
    expect(await tester(MovieTile).safeExists(), true);

    // Then:
    await tester(
      ListView,
    ).scrollTo(scrollDirection: AxisDirection.down, dragDuration: const Duration(milliseconds: 400));

    // When:
    await tester.native2.enableAirplaneMode();

    // Then:
    expect(await tester(noConnectionWidgetKey).safeExists(), true);

    // When:
    await tester.native2.disableAirplaneMode();

    // Then:
    expect(await tester(PopularMoviesListScreen).safeExists(), true);
    expect(await tester(MovieTile).safeExists(), true);

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
    await tester(BackButton).tap();

    // When:
    expect(await tester(PopularMoviesListScreen).safeExists(), true);

    // Then:
    expect(tester(MovieTile).exists, true);
  });
}
