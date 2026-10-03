import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/shared.dart';
import 'router.dart';

/// Binding-free app root factory.
///
/// Used by `main()` and by the Patrol bootstrap (`gherkin/support/patrol_bootstrap.dart`).
/// It must never initialise a binding or call `runApp`, so tests can pump it directly.
Widget createApp({List<NavigatorObserver> navigatorObservers = const []}) {
  return ProviderScope(child: MovieViewerApp(navigatorObservers: navigatorObservers));
}

class MovieViewerApp extends StatefulWidget {
  const MovieViewerApp({super.key, this.navigatorObservers = const []});

  /// Extra observers attached to the root [MaterialApp] navigator (e.g. the Gherkin recorder).
  final List<NavigatorObserver> navigatorObservers;

  @override
  State<MovieViewerApp> createState() => _MovieViewerAppState();
}

class _MovieViewerAppState extends State<MovieViewerApp> {
  @override
  void initState() {
    super.initState();
    // Initialize the connectivity service
    ConnectivityService.instance.initialise();
  }

  @override
  void dispose() {
    ConnectivityService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.blue, primary: const Color(0xff032541));

    return ConnectivityOverlay(
      child: MaterialApp(
        title: 'TMDB Movie Viewer',
        routes: MovieViewerRouter.instance.routes,
        onGenerateRoute: MovieViewerRouter.instance.onGenerateRoute,
        initialRoute: MovieViewerRoutes.popularMovies,
        navigatorKey: MovieViewerRouter.instance.navigator,
        navigatorObservers: widget.navigatorObservers,
        theme: ThemeData(
          colorScheme: scheme,
          appBarTheme: AppBarTheme(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.surface,
            centerTitle: false,
          ),
        ),
      ),
    );
  }
}
