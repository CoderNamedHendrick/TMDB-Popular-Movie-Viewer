import 'package:flutter/material.dart';

import 'router.dart';

class MovieViewerApp extends StatelessWidget {
  const MovieViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.blue.shade800);
    return MaterialApp(
      routes: MovieViewerRouter.instance.routes,
      onGenerateRoute: MovieViewerRouter.instance.onGenerateRoute,
      initialRoute: MovieViewerRoutes.popularMovies,
      navigatorKey: MovieViewerRouter.instance.navigator,
      theme: ThemeData(
        colorScheme: scheme,
        appBarTheme: AppBarTheme(backgroundColor: scheme.primary, foregroundColor: scheme.surface, centerTitle: false),
      ),
    );
  }
}
