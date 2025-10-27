import 'package:flutter_test/flutter_test.dart';
import 'scenarios/search_movie_scenario_test.dart' as search_movie;
import 'scenarios/view_movie_scenario_test.dart' as view_movie;

void main() {
  group('TDMB Movie viewer scenarios test', () {
    view_movie.main();
    search_movie.main();
  });
}
