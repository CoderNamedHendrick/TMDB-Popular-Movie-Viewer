import 'package:flutter/material.dart';

import '../shared/shared.dart';
import 'router.dart';

class MovieViewerApp extends StatefulWidget {
  const MovieViewerApp({super.key});

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
