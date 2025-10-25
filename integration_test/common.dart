import 'package:patrol_finders/patrol_finders.dart';

const waitTime = Duration(milliseconds: 700);
const kActionDelay = Duration(milliseconds: 800);

extension PatrolFinderX on PatrolFinder {
  Future<bool> safeExists([Duration timeout = const Duration(seconds: 3)]) async {
    try {
      await waitUntilExists(timeout: timeout);
      return true;
    } on WaitUntilExistsTimeoutException catch (_) {
      return false;
    }
  }
}

extension PatrolTesterX on PatrolTester {
  /// run the loading animation while counteracting the countdown animation
  /// pumpAndSettle timeout issue
  Future<void> progressAnimationSafely([int cycles = 10]) async {
    for (int i = 0; i < cycles; i++) {
      await pump(waitTime);
    }
  }
}
