import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmdb_movie_viewer/src/app/app.dart';

/// Pumps the binding-free app root for generated Patrol tests.
///
/// Never calls the app's `main()`: Patrol owns the test binding, and `main()` would try to
/// claim `MarionetteBinding` under INTEGRATION_TEST. The TMDB key comes from the ignored
/// `.env` define file listed in `gherkin/config.yaml` (`dart_define_files`).
Future<void> startApp(PatrolIntegrationTester $, {required String environment, required bool production}) async {
  if (const String.fromEnvironment('GHERKIN_ENVIRONMENT') != environment) {
    throw StateError('Pass the explicitly allowed GHERKIN_ENVIRONMENT via dart-define');
  }
  if (production && !const bool.fromEnvironment('GHERKIN_CONFIRM_PRODUCTION')) {
    throw StateError('Production needs renewed user confirmation for this run');
  }
  await $.pumpWidget(createApp());
  // The list screen shows a looping skeleton shimmer while the first page loads, which
  // makes `pumpAndSettle` time out; pump a few bounded frames instead.
  for (var i = 0; i < 5; i++) {
    await $.pump(const Duration(milliseconds: 200));
  }
}

// Dart process environment variables are not available inside a mobile app.
// Supply values via an ignored --dart-define-from-file and a reviewed finite map.
// Example: case r'${env:TEST_PASSWORD}': return const String.fromEnvironment('TEST_PASSWORD');
String resolveValue(String placeholder) => switch (placeholder) {
  _ => throw StateError('Unmapped secret/fixture placeholder (value suppressed)'),
};

/// The text field that currently owns focus. Used by `I enter "value" into the focused
/// field` for inputs that expose no key of their own (e.g. Material SearchAnchor's view,
/// which autofocuses its search bar).
Finder focusedField() => find.byWidgetPredicate(
  (widget) => widget is EditableText && widget.focusNode.hasFocus,
  description: 'focused EditableText',
);

Future<void> assertVisible(PatrolIntegrationTester $, Finder finder, int? count) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (true) {
    final actual = finder.hitTestable().evaluate().length;
    if (count == null ? actual > 0 : actual == count) return;
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Visible match count: expected ${count ?? 'at least one'}, found $actual');
    }
    await $.pump(const Duration(milliseconds: 100));
  }
}
