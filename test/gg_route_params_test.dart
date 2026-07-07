// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';

void main() {
  group('GgRouteParams', () {
    // .........................................................................
    final key = GlobalKey(debugLabel: 'GgRouteParams');
    late GgRouteTreeNode rootNode;
    const paramName = 'a';
    const paramSeed = 5;
    const paramName1 = 'b';
    const paramSeed1 = 'Hello';

    // .........................................................................
    setUp(WidgetTester tester, {Widget? child}) async {
      final widget = GgRouteParams(
        key: key,
        params: {
          paramName: GgRouteParam(seed: paramSeed),
          paramName1: GgRouteParam(seed: paramSeed1),
        },
        child: child ?? Container(),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: GgRouteInformationParser(),
          routerDelegate: GgRouterDelegate(
            child: Builder(
              builder: (context) {
                rootNode = GgRouter.of(context).node;
                return widget;
              },
            ),
          ),
        ),
      );
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should write the params into node', (
      WidgetTester tester,
    ) async {
      await setUp(tester);
      expect(rootNode.param(paramName)?.value, paramSeed);
      expect(rootNode.param(paramName1)?.value, paramSeed1);
      await tearDown(tester);
    });

    // .........................................................................
    testWidgets(
      'should throw an exception if a parameter is used multiple times in the same route.',
      (WidgetTester tester) async {
        await setUp(
          tester,
          child: GgRouteParams(
            params: {'a': GgRouteParam(seed: 5)},
            child: Container(),
          ),
        );

        expect(
          tester.takeException().message,
          'Cannot process route param "a". '
          'There is already a parent GgRouteParams object, containing a route param with the name "a". '
          'Make sure you are using unique param names accross a route and its parents.',
        );

        await tearDown(tester);
      },
    );
  });
}
