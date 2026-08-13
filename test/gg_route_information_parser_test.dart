// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_router/src/gg_route_information_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GgRouteInformationParser', () {
    test('should work fine', () {
      final parser = GgRouteInformationParser();
      expect(parser, isNotNull);
    });
  });
}
