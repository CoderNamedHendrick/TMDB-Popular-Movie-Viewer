import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

// Call FIRST in the normal mobile app entrypoint, before plugins or other bindings.
// Widget tests already own a binding; Patrol uses a different entrypoint entirely.
void initializeGherkinBinding({MarionetteConfiguration? configuration}) {
  if (!kReleaseMode &&
      const bool.fromEnvironment('INTEGRATION_TEST') &&
      !Platform.environment.containsKey('FLUTTER_TEST')) {
    BindingBase? existing;
    try {
      existing = WidgetsBinding.instance;
    } on FlutterError {
      /* not initialized */
    }
    if (existing != null && existing is! MarionetteBinding) {
      throw StateError('Gherkin: another binding already initialized. Patrol must use createApp(), not main().');
    }
    MarionetteBinding.ensureInitialized(configuration ?? const MarionetteConfiguration());
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
}
