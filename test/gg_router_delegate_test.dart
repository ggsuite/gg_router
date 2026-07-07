// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';

void main() {
  group('GgRouterDelegate', () {
    // .........................................................................
    late GgRouterDelegate routerDelegate;
    late GgRouteInformationParser routeInformationParser;
    late GgRouterCore router;

    const exampleData =
        '{"routeB":{"b": 1234}, "${GgRouteTreeNode.stagedChildJsonKey}":"routeB"}';

    // .........................................................................
    setUp(
      WidgetTester tester, {
      Function(String state)? saveState,
      Future<String?> Function()? restoreState,
    }) async {
      GgRouteParams Function(BuildContext context) builder(
        Map<String, GgRouteParam> params,
      ) => (BuildContext context) {
        router = GgRouter.of(context);
        return GgRouteParams(
          child: Container(key: const ValueKey('content')),
          params: params,
        );
      };

      final paramsA = GgRouteParam(seed: 5);
      final paramsB = GgRouteParam(seed: 6);

      final widget = GgRouter(
        {
          'routeA': builder({'a': paramsA}),
          'routeB': builder({'b': paramsB}),
          'routeC': builder({
            'c': GgRouteParam(seed: 7),
            'd': GgRouteParam(seed: 8),
          }),
        },
        defaultRoute: 'routeA',
        key: const ValueKey('router'),
      );
      routeInformationParser = GgRouteInformationParser();
      routerDelegate = GgRouterDelegate(
        child: widget,
        saveState: saveState,
        restoreState: restoreState,
      );
      final app = MaterialApp.router(
        routeInformationParser: routeInformationParser,
        routerDelegate: routerDelegate,
      );
      await tester.pumpWidget(app);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should take "root" as root node when not null', (
      WidgetTester tester,
    ) async {
      final root = GgRouteTreeNode.newRoot();
      final delegate = GgRouterDelegate(child: Container(), root: root);
      expect(delegate.root, root);
    });

    // .........................................................................
    testWidgets(
      'should apply "defaultRoute" when a root node is given and the staged child is "/"',
      (WidgetTester tester) async {
        final root = GgRouteTreeNode.newRoot();
        expect(root.stagedChildPath, '');
        final delegate = GgRouterDelegate(
          child: Container(),
          root: root,
          defaultRoute: 'hello',
        );
        expect(delegate.root, root);
        expect(root.stagedChild!.path, '/hello');
      },
    );

    // .........................................................................
    testWidgets(
      'should not apply "defaultRoute" when a root node is given and the staged child is "/something"',
      (WidgetTester tester) async {
        final root = GgRouteTreeNode.newRoot();
        root.navigateTo('/something');
        expect(root.stagedChildPath, 'something');
        final delegate = GgRouterDelegate(
          child: Container(),
          root: root,
          defaultRoute: 'hello',
        );
        expect(delegate.root, root);
        expect(root.stagedChild!.path, '/something');
      },
    );

    // .........................................................................
    testWidgets('should work correctly', (WidgetTester tester) async {
      await setUp(tester);

      // ...........................................
      // should inform when the visible route changes
      bool routeDidChange = false;
      routerDelegate.addListener(() => routeDidChange = true);
      await tester.pumpAndSettle();
      expect(routeDidChange, false);
      routeDidChange = false;

      router.navigateTo('/routeB');
      await tester.pumpAndSettle();
      routeDidChange = true;

      // ........................................................
      // Set an initial route configuration with a null location.
      // => no routing should happen
      var result = routerDelegate.setInitialRoutePath(
        RouteInformation(uri: Uri.parse('')),
      );
      expect(result, isInstanceOf<Future<void>>());
      await result;

      // ........................................................
      // Navigate to the root route. This should also lead to no navigation.
      // The app will navigate to the last saved state.
      result = routerDelegate.setInitialRoutePath(
        RouteInformation(uri: Uri.parse('/')),
      );
      expect(result, isInstanceOf<Future<void>>());
      await result;

      // ...........................................
      // Should provide the RouteInformation for the currently set path
      result = routerDelegate.setInitialRoutePath(
        RouteInformation(uri: Uri.parse('/routeC')),
      );
      await tester.pumpAndSettle();
      expect(
        routerDelegate.currentConfiguration.uri.toString(),
        'routeC?c=7&d=8',
      );
      expect(router.node.root.stagedChildPath, 'routeC');

      // ....................................................
      // Should apply RouteInformation to the route node tree
      await routerDelegate.setNewRoutePath(
        RouteInformation(uri: Uri.parse('/routeA')),
      );
      expect(router.node.root.stagedChildPath, 'routeA');
      expect(routerDelegate.currentConfiguration.uri.toString(), 'routeA?a=5');
      await tester.pumpAndSettle();

      // ..............................
      // Should also write query params
      await routerDelegate.setNewRoutePath(
        RouteInformation(uri: Uri.parse('/routeA?a=123')),
      );
      router.node.param('a')!.value = 6;

      // ..............................
      // Should write unknown parameters to uriParams
      await routerDelegate.setNewRoutePath(
        RouteInformation(uri: Uri.parse('/routeA?unknown=456')),
      );
      expect(router.node.uriParamForName('unknown'), '456');

      // ............................................
      // Should write changes of a param to the route
      router.node.param('a')!.value = 6;
      await tester.pumpAndSettle();
      expect(routerDelegate.currentConfiguration.uri.toString(), 'routeA?a=6');

      // .....................................
      // Should throw if a URL contains errors
      expect(
        () => RouteInformation(uri: Uri.parse(' \$d\$30:!!')),
        throwsException,
      );

      await tester.pumpAndSettle();
      expect(routerDelegate.currentConfiguration.uri.toString(), 'routeA?a=6');

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('should load the data given by restoreState callback', (
      WidgetTester tester,
    ) async {
      await setUp(tester, restoreState: () => SynchronousFuture(exampleData));
      expect(routerDelegate.root.stagedChildPath, 'routeB');
      expect(
        routerDelegate.root.findOrCreateChild('routeB').param('b')?.value,
        1234,
      );
    });

    // .........................................................................
    testWidgets(
      'should save the route state automatically when a save callback is given',
      (WidgetTester tester) async {
        String? savedData;

        // Setup delegate with a saveState callback
        await setUp(tester, saveState: (state) => savedData = state);
        await tester.pumpAndSettle();
        savedData = null;

        // Change the route. The new route state should be saved automatically.
        routerDelegate.root.navigateTo('routeB');
        await tester.pumpAndSettle();
        expect(
          savedData,
          contains('"${GgRouteTreeNode.stagedChildJsonKey}":"routeB"'),
        );
      },
    );

    // .........................................................................
    testWidgets('should show an empty container until data is loaded', (
      WidgetTester tester,
    ) async {
      // Setup a completer yielding last saved state
      final loadData = Completer<String?>();

      // Start application.
      await setUp(tester, restoreState: () => loadData.future);

      // Until completer has not completed, a loading
      // screen should be shown.
      var loadingScreen = find.byKey(
        const ValueKey('RouterDelegateLoadingScreen'),
      );
      expect(loadingScreen, findsOneWidget);
      var content = find.byKey(const ValueKey('content'));
      expect(content, findsNothing);

      await tester.pumpAndSettle();

      // Now lets complete the loading
      loadData.complete(exampleData);
      await tester.pumpAndSettle();
      loadingScreen = find.byKey(const ValueKey('RouterDelegateLoadingScreen'));
      expect(loadingScreen, findsNothing);
      content = find.byKey(const ValueKey('content'));
      expect(content, findsOneWidget);
    });

    // #########################################################################
    group('semantics widget', () {
      // ..........................................
      // Define a sample widget with two containers
      final widget = Stack(
        children: [
          Positioned(
            left: 0,
            child: Semantics(
              label: 'Hello',
              child: Container(width: 100, height: 100),
            ),
          ),
          Positioned(
            right: 0,
            child: Semantics(
              label: 'World',
              child: Container(width: 100, height: 100),
            ),
          ),
        ],
      );

      // .......................................................................
      testWidgets(
        'when instantiated without GgRouter, semantic widgets should work correctly',
        (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(home: widget));
          expect(find.bySemanticsLabel('Hello'), findsOneWidget);
          expect(find.bySemanticsLabel('World'), findsOneWidget);
        },
      );

      // .......................................................................
      testWidgets(
        'when instantiated within an overlay, semantic widgets should work too',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            GgRouter.root(
              node: GgRouteTreeNode(name: '_ROOT_'),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) {
                        return widget;
                      },
                    ),
                  ],
                ),
              ),
            ),
          );

          expect(find.bySemanticsLabel('Hello'), findsOneWidget);
          expect(find.bySemanticsLabel('World'), findsOneWidget);
        },
      );

      // .......................................................................
      testWidgets(
        'when instantiated within a RouterDelegate, semantic widgets should work too',
        (WidgetTester tester) async {
          // ..............................
          final routerDelegate = GgRouterDelegate(child: widget);

          await tester.pumpWidget(
            MaterialApp.router(
              routeInformationParser: GgRouteInformationParser(),
              routerDelegate: routerDelegate,
            ),
          );

          expect(find.bySemanticsLabel('Hello'), findsOneWidget);
          expect(find.bySemanticsLabel('World'), findsOneWidget);
        },
      );
    });

    // .........................................................................
    test('dispose', () {
      final delegate = GgRouterDelegate(child: Container());
      delegate.dispose();
    });
  });
}
