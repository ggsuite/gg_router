// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:supply_chain_flutter/supply_chain_flutter.dart';

void main() {
  group('GgRoutePathBuilder', () {
    testWidgets('should rebuild with the staged path', (tester) async {
      final root = GgRouteNode.newRoot();
      final scm = root.scope.scm;
      final paths = <String>[];

      await tester.pumpWidget(
        ScmTickDriver(
          scm: scm,
          child: GgRouter.root(
            node: root,
            child: GgRoutePathBuilder(
              builder: (context, path) {
                paths.add(path);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(paths, ['/']);

      root.navigateTo('/a/b');
      await tester.pump();
      await tester.pump();
      expect(paths.last, '/a/b');

      await tester.pumpWidget(const SizedBox());
      root.dispose();
    });
  });
}
