// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';

void main() {
  group('GgRouteChangeBuilder', () {
    // .........................................................................
    late GgEasyWidgetTest<GgRouteChangeBuilder, dynamic> ggRouteChangeBuilder;
    final key = GlobalKey(debugLabel: 'GgRouteChangeBuilder');
    late int buildNumber;
    late GgRouteTreeNode rootNode;

    // .........................................................................
    setUp(WidgetTester tester) async {
      buildNumber = 0;
      rootNode = GgRouteTreeNode.newRoot();

      final widget = GgRouter.root(
        child: GgRouteChangeBuilder(
          key: key,
          builder: (_) => Text('${buildNumber++}'),
        ),
        node: rootNode,
      );

      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: widget),
      );

      // ...........
      // Get widgets
      ggRouteChangeBuilder = GgEasyWidgetTest(find.byWidget(widget), tester);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should be instantiated correctly', (
      WidgetTester tester,
    ) async {
      await setUp(tester);

      // ....................
      // Check overall widget
      expect(ggRouteChangeBuilder.width, 800);
      expect(ggRouteChangeBuilder.height, 600);

      // ...............................................
      // Initially, the initial build number should be 1
      var expectedBuildNumber = 1;
      expect(buildNumber, expectedBuildNumber);

      // ..............
      // Detailed tests

      // Let's create some child routes
      final child0 = rootNode.findOrCreateChild('child0');
      final child1 = rootNode.findOrCreateChild('child1');
      final grandChild0 = child0.findOrCreateChild('grandChild0');
      final grandChild1 = child0.findOrCreateChild('grandChild1');

      check() async {
        await tester.pumpAndSettle();
        expect(buildNumber, ++expectedBuildNumber);
      }

      // Let's change the active child => widget should be rebuilt
      child0.navigateTo('.');
      await check();

      child1.navigateTo('.');
      await check();

      // Let's change the active grandchild => widget should be rebuilt
      grandChild0.navigateTo('.');
      await check();

      // Let's change the active grandchild => widget should be rebuilt
      grandChild1.navigateTo('.');
      await check();

      // ........
      // Cleanup
      await tearDown(tester);
    });
  });
}
