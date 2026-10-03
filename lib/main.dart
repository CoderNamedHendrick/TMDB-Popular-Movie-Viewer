import 'package:flutter/material.dart';

import 'gherkin_harness/binding.dart';
import 'gherkin_harness/recorder.dart';
import 'src/app/app.dart';

void main() {
  // Must run before any other binding or plugin initialisation. In release builds and
  // in regular debug runs this is plain `WidgetsFlutterBinding.ensureInitialized()`;
  // only `--dart-define=INTEGRATION_TEST=true` debug/profile runs claim `MarionetteBinding`.
  initializeGherkinBinding();

  runApp(_root());
}

Widget _root() {
  // `gherkinRecordingEnabled` is a compile-time constant, so the recorder harness is
  // tree-shaken out of every build that does not pass GHERKIN_RECORD=true.
  if (!gherkinRecordingEnabled) return createApp();

  // Deny-by-default capture policy: no text input is logged literally and tapped
  // labels are only recorded for keys listed in `publicTextKeys`.
  final recorder = GherkinRecorder(publicTextKeys: const {}, sensitiveKeys: const {});

  return GherkinRecordingHarness(
    recorder: recorder,
    child: createApp(navigatorObservers: [GherkinNavigatorObserver(recorder)]),
  );
}
