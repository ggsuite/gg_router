// Placed by `helix init` and `helix upgrade` — checks on every test run
// that the files this project's DNA generated are unchanged. It writes
// nothing; `gg dna build` applies DNA updates.

import 'package:flutter_test/flutter_test.dart';
import 'package:helix/helix.dart';

void main() {
  test(
    'generated dna files are unchanged',
    checkDna,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
