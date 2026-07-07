// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_value/gg_value.dart';

// #############################################################################
class TestRouteInformationProvider extends RouteInformationProvider
    with ChangeNotifier {
  @override
  RouteInformation get value => _routeInformation;
  set routeInformation(RouteInformation routeInformation) {
    _routeInformation = routeInformation;
    notifyListeners();
  }

  RouteInformation _routeInformation = RouteInformation(
    uri: Uri.parse('https://example.com'),
  );
}

// #############################################################################

void main() {
  // .........................................................................
  late GgEasyWidgetTest<GgRouter, dynamic> ggRoute;

  late GgRouteInformationParser routeInformationParser;
  late GgRouterDelegate routerDelegate;

  late GgRouteTreeNode lastBuiltNode;
  late String? routeSegment;
  late String? childRouteSegment;
  late String routePath;

  late TestRouteInformationProvider routeInformationProvider;

  late GgEasyWidgetTest a0Button;
  late GgEasyWidgetTest a0OnlyButton;
  late GgEasyWidgetTest b0Button;

  // ..............................
  Container subBuilder(BuildContext context) {
    final router = GgRouter.of(context);
    lastBuiltNode = router.node;
    routeSegment = GgRouter.of(context).routeName;
    childRouteSegment = GgRouter.of(context).routeNameOfActiveChild;
    routePath = GgRouter.of(context).routePath;
    return Container();
  }

  // ..............................
  // Create a widget hierarchy /a/b
  final defaultChild = Builder(
    builder: (context) {
      final router = GgRouter.of(context);
      router.node.root.errorHandler = null;
      router.node.root.errorHandler = (_) {};
      return Column(
        children: [
          // ...............................
          // A button selecting route a0/a11
          TextButton(
            key: const ValueKey('a0/a11 Button'),
            onPressed: () => GgRouter.of(context).navigateTo('a0/a11'),
            child: Container(),
          ),

          // ...............................
          // A button selecting route b0/b11
          TextButton(
            key: const ValueKey('b0/b10 Button'),
            onPressed: () => GgRouter.of(context).navigateTo('b0/b10'),
            child: Container(),
          ),

          // ...............................
          // A button selecting route a0
          TextButton(
            key: const ValueKey('a0/ Button'),
            onPressed: () => router.navigateTo('a0/'),
            child: Container(),
          ),

          // ..........
          // The routes
          GgRouter({
            '_INDEX_': subBuilder,
            'a0': (context) {
              return Column(
                children: [
                  Builder(
                    builder: (context) {
                      return TextButton(
                        key: const ValueKey('backButton'),
                        onPressed: () {
                          GgRouter.of(context).navigateTo('.');
                        },
                        child: Container(),
                      );
                    },
                  ),
                  GgRouter({
                    '_INDEX_': subBuilder,
                    'a10': subBuilder,
                    'a11': subBuilder,
                  }, key: const ValueKey('a0SubRouter')),
                ],
              );
            },
            'b0': (context) {
              return GgRouter({
                'b10': subBuilder,
                'b11': subBuilder,
              }, key: const ValueKey('b0SubRouter'));
            },
          }, key: const ValueKey('mainRouter')),
        ],
      );
    },
  );

  // ...........................................................................
  updateAAndBButtons(WidgetTester tester) {
    // ........................
    // Get reference to buttons
    a0Button = GgEasyWidgetTest(
      find.byKey(const ValueKey('a0/a11 Button')),
      tester,
    );
    a0OnlyButton = GgEasyWidgetTest(
      find.byKey(const ValueKey('a0/ Button')),
      tester,
    );
    b0Button = GgEasyWidgetTest(
      find.byKey(const ValueKey('b0/b10 Button')),
      tester,
    );
  }

  // .........................................................................
  setUp(
    WidgetTester tester, {
    Widget? child,
    String initialRoute = '/_INDEX_',
  }) async {
    // Create routeInformationProvider
    routeInformationProvider = TestRouteInformationProvider();

    final widget = child ?? defaultChild;

    // ........................
    // Create a router delegate
    routeInformationParser = GgRouteInformationParser();
    routerDelegate = GgRouterDelegate(
      child: widget,
      defaultRoute: initialRoute,
    );

    // .....................
    // Initialize the widget
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: routeInformationParser,
        routerDelegate: routerDelegate,
        routeInformationProvider: routeInformationProvider,
      ),
    );

    await tester.pumpAndSettle();

    // ..................................
    // Create a GgEasyWidgetTest instance
    final ggRouteFinder = find.byWidget(widget);
    ggRoute = GgEasyWidgetTest(ggRouteFinder, tester);
  }

  // .........................................................................
  tearDown(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  group('GgRouter', () {
    late GgRouteTreeNode index;
    late GgRouteTreeNode a0;
    late GgRouteTreeNode b0;
    late GgRouteTreeNode a11;

    update() {
      index = lastBuiltNode;

      a0 = lastBuiltNode.root.findOrCreateChild('a0');
      b0 = lastBuiltNode.root.findOrCreateChild('b0');
      a11 = a0.findOrCreateChild('a11');
    }

    // .........................................................................
    testWidgets('should throw if animations are not consistent', (
      WidgetTester tester,
    ) async {
      expect(
        () => GgRouter(
          const {},
          key: GlobalKey(),
          inAnimation: null,
          outAnimation: (context, animation, child, size) => GgMoveInFromBottom(
            animation: animation,
            child: child,
            size: size,
          ),
        ),
        throwsArgumentError,
      );
    });

    // .........................................................................
    testWidgets('should allow to synchronize URI and widget hierarchy', (
      WidgetTester tester,
    ) async {
      // .................
      // Create the widget
      await setUp(tester);
      update();
      updateAAndBButtons(tester);
      expect(ggRoute.width, 800);
      expect(ggRoute.height, 600);

      // ................................................
      // Test if node hierarchy is synchronized correctly

      // By default the default route should be selected
      expect(index.path, '/_INDEX_');

      // The right widget indices should have been assigned
      expect(index.widgetIndex, 0);
      expect(a0.widgetIndex, 1);
      expect(b0.widgetIndex, 2);

      // Now activate /a0 and check if node the hierarchy was rebuilt
      a0.navigateTo('.');
      await tester.pumpAndSettle();
      update();
      expect(lastBuiltNode.path, '/a0/_INDEX_');
      expect(routeSegment, '_INDEX_');
      expect(routePath, '/a0/_INDEX_');
      expect(childRouteSegment, null);

      // Now activate /a0/a11 and check if node the hierarchy was rebuilt
      a11.navigateTo('.');
      await tester.pumpAndSettle();
      update();
      expect(lastBuiltNode.path, '/a0/a11');
      expect(routeSegment, 'a11');
      expect(routePath, '/a0/a11');

      // Now activate /b0 -> /a0/a11 should stay visible
      // because no _INDEX_ route has been defined for b0
      lastBuiltNode.parent!.parent!.findOrCreateChild('b0').navigateTo('.');

      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/a0/a11');

      // Now activate /b11 -> /b0/b11 should become visible
      lastBuiltNode.root.navigateTo('/b0/b11');
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/b0/b11');

      // Now let's activate an invalid route. ->
      // The previous defined route should stay visible
      lastBuiltNode.parent!.findOrCreateChild('unknown').navigateTo('.');
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/b0/b11');

      // ..............................................................
      // Test if the url is updated correctly from the widget hierarchy
      String? lastUpdateUrl;
      routerDelegate.addListener(() {
        lastUpdateUrl = routerDelegate.currentConfiguration.uri.toFilePath();
      });

      lastBuiltNode.parent!.parent!.stagedChildPathSegments = ['a0', 'a11'];
      await tester.pumpAndSettle();
      expect(lastUpdateUrl, 'a0/a11');

      lastBuiltNode.parent!.parent!.stagedChildPathSegments = ['b0', 'b10'];
      await tester.pumpAndSettle();
      expect(lastUpdateUrl, 'b0/b10');

      // .................................................................
      // Test if url changes are applied to the widget hierarchy correctly
      routeInformationProvider.routeInformation = RouteInformation(
        uri: Uri.parse('a0/a10'),
      );

      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/a0/a10');

      // .................................................................
      // Test if an invalid url makes GgRouter showing an error widget.
      // Additionally the error handler should be called.
      GgRouteTreeNodeError? receivedError;
      lastBuiltNode.root.errorHandler = null;
      lastBuiltNode.root.errorHandler = (error) => receivedError = error;

      routeInformationProvider.routeInformation = RouteInformation(
        uri: Uri.parse('a0/invalidRoute'),
      );
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/a0/a10');
      expect(receivedError!.id, 'GRC008448');
      expect(
        receivedError!.message,
        'Route "/a0" has no child named "invalidRoute" nor does your GgRouter define a "*" wild card route.',
      );

      // ..................................................
      // Invalid URLs should be removed from the route tree
      expect(lastBuiltNode.root.hasChild(name: 'a0'), true);
      expect(
        lastBuiltNode.root
            .findOrCreateChild('a0')
            .hasChild(name: 'invalidRoute'),
        false,
      );

      // .................................................................
      // Test if an missing _INDEX_ route makes GgRouter showing an error widget.
      // Additionally the error handler should be called.
      lastBuiltNode.root.errorHandler = null;
      lastBuiltNode.root.errorHandler = (error) => receivedError = error;

      routeInformationProvider.routeInformation = RouteInformation(
        uri: Uri.parse('b0/'),
      );
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/a0/a10');
      expect(receivedError!.id, 'GRC008505');
      expect(
        receivedError!.message,
        'Route "/b0" has no "_INDEX_" route and also no defaultRoute set. It cannot be displayed.',
      );

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('should allow to switch routes using other widgets', (
      WidgetTester tester,
    ) async {
      // .................
      // Create the widget
      await setUp(tester);
      updateAAndBButtons(tester);

      // ...............
      // Press a0 button -> should activate '/a0/a11'
      await a0Button.press();
      expect(lastBuiltNode.path, '/a0/a11');

      // Press back button -> should activate '/a0/_INDEX_'
      final backButton = GgEasyWidgetTest(
        find.byKey(const ValueKey('backButton')),
        tester,
      );
      await backButton.press();
      expect(lastBuiltNode.path, '/a0/_INDEX_');

      // Press b0 Button -> Should activate '/b0/b10'
      await b0Button.press();
      expect(lastBuiltNode.path, '/b0/b10');

      // ...............
      // Press a0Only Button -> Should activate '/a0/_INDEX_'
      await a0OnlyButton.press();
      expect(lastBuiltNode.path, '/a0/_INDEX_');
    });

    // .........................................................................
    testWidgets('GgRouter.of(context) should work correctly', (
      WidgetTester tester,
    ) async {
      BuildContext? context;

      late GgRouterCore rootRouter;
      late GgRouterCore rootRouter2;
      late GgRouterCore router;
      late GgRouterCore childRouter;
      late String? lastBuiltParam;

      // .....................................................................
      await setUp(
        tester,
        child: Builder(
          builder: (c0) {
            rootRouter = GgRouter.of(c0);
            rootRouter.node.navigateTo('routeA/childRouteA');

            GgRouter builder(BuildContext c1, String x) {
              context = c1;
              router = GgRouter.of(c1);

              final childName = 'childRoute$x';
              router.node.findOrCreateChild(childName).navigateTo('.');

              return GgRouter({
                childName: (c2) {
                  childRouter = GgRouter.of(c2);
                  rootRouter2 = GgRouter.of(c2, rootRouter: true);
                  return GgRouteParams(
                    params: {'param': GgRouteParam(seed: x)},
                    child: Builder(
                      builder: (c3) {
                        lastBuiltParam = GgRouter.of(c3).param('param')?.value;
                        return Container();
                      },
                    ),
                  );
                },
              }, key: ValueKey('childRouter_$x'));
            }

            return GgRouter({
              'routeA': (c) => builder(c, 'A'),
              'routeB': (c) => builder(c, 'B'),
              'routeC': (c) => builder(c, 'C'),
            }, key: const ValueKey('mainRouter'));
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(context!, isNotNull);

      // .............................................................
      // GgRouter.of(context) should give the current context's router
      expect(router, isInstanceOf<GgRouterCore>());
      expect(childRouter, isInstanceOf<GgRouterCore>());

      // .......................................................
      // GgRouter.of(context).node should give the route node assigned to the
      // current context, in our case this is the first route
      expect(router.node.name, 'routeA');
      expect(childRouter.node.name, 'childRouteA');

      // .......................................................
      // GgRouter.of(context).routeName should give the name of the
      // route segment
      expect(router.routeName, 'routeA');
      expect(childRouter.routeName, 'childRouteA');

      // .......................................................
      // GgRouter.of(context).routeNameOfStagedChild should give the name
      // of the visible child route, or null if no child route is visible.
      expect(router.routeNameOfActiveChild, 'childRouteA');
      expect(childRouter.routeNameOfActiveChild, null);

      // .......................................................
      // GgRouter.of(context).routePath should give the complete path
      // of the route
      expect(router.routePath, '/routeA');
      expect(childRouter.routePath, '/routeA/childRouteA');

      // .......................................................
      // GgRouter.of(context).routeParam('param') should give the param
      // with name 'param.
      expect(lastBuiltParam, 'A');

      // .............................................................
      // GgRouter.of(context, rootRouter: true) should the root router
      expect(rootRouter2, rootRouter);

      // .......................................................
      // GgRouter.of(context).indexOfStagedChild should give the index
      // of the visible child route, or null if no child route is visible.
      expect(rootRouter.indexOfActiveChild, 0);
      expect(childRouter.indexOfActiveChild, null);
      router.navigateTo('/routeC');
      expect(rootRouter.routeNameOfActiveChild, 'routeC');
      await tester.pumpAndSettle();
      expect(rootRouter.routeNameOfActiveChild, 'routeC');
      expect(rootRouter.indexOfActiveChild, 2);

      // .......................................................
      // GgRouter.of(context).onStagedChildChange should inform, when the
      // visible child changes
      expect(router.routeName, 'routeC');
      bool? onStagedChildChangeDidFire;
      final s = rootRouter.onActiveChildChange.listen(
        (event) => onStagedChildChangeDidFire = true,
      );

      await tester.pumpAndSettle();
      expect(onStagedChildChangeDidFire, isNull);

      // GgRouter.of(context).navigateTo() should allow to navigate relatively
      router.navigateTo('../routeB');
      await tester.pumpAndSettle();
      expect(onStagedChildChangeDidFire, true);

      expect(router.routePath, '/routeB');
      expect(childRouter.routePath, '/routeB/childRouteB');

      // GgRouter.of(context).navigateTo() should allow to navigate absolutely
      childRouter.navigateTo('/routeC');
      await tester.pumpAndSettle();
      expect(router.routePath, '/routeC');
      expect(childRouter.routePath, '/routeC/childRouteC');

      // GgRouter.of(context) should throw if context is not a child of
      // GgRouterDelegate

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            GgRouter.of(context);
            return Container();
          },
        ),
      );

      expect(
        tester.takeException().message,
        GgRouter.noGgRouterDelegateFoundError,
      );

      // ignore: unawaited_futures
      s.cancel();

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets(
      'should update indexOfStagedChild when order of widgets changes',
      (WidgetTester tester) async {
        routeInformationProvider = TestRouteInformationProvider();

        final showAAtFirstPlace = GgValue(seed: false);

        await setUp(
          tester,
          child: StreamBuilder(
            stream: showAAtFirstPlace.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              // Create route a. Route a will be on first place in variant 1
              // and on second place in variant 2.
              Container routeA(_) {
                final router = GgRouter.of(context);
                final indexOfStagedChild = router.indexOfActiveChild;
                if (showAAtFirstPlace.value) {
                  expect(indexOfStagedChild, 0);
                  expect(router.routeNameOfActiveChild, 'a');
                } else {
                  expect(indexOfStagedChild, 1);
                  expect(router.routeNameOfActiveChild, 'a');
                }

                return Container();
              }

              return StreamBuilder(
                stream: GgRouter.of(context).onActiveChildChange,
                builder: (context, snapshot) {
                  // Exchange the places of route 'a'
                  return showAAtFirstPlace.value
                      ? GgRouter({
                          'a': routeA,
                          'b': (_) => Container(),
                        }, key: const ValueKey('Router1'))
                      : GgRouter({
                          'b': (_) => Container(),
                          'a': routeA,
                        }, key: const ValueKey('Router2'));
                },
              );
            },
          ),
        );

        await tester.pumpAndSettle();
        showAAtFirstPlace.value = true;
        routerDelegate.root.navigateTo('a');
        await tester.pumpAndSettle();
        showAAtFirstPlace.value = false;
        await tester.pumpAndSettle();
      },
    );

    testWidgets('should update tree when children or semantic labels change', (
      tester,
    ) async {
      // ..................................
      // Create a GgRouter with a given key
      // and a given set of routes and semantic labels.
      final key = GlobalKey();

      final routes = GgValue<Map<String, WidgetBuilder>>(
        seed: {
          '_INDEX_': (_) => const SizedBox(),
          'a': (_) => const SizedBox(),
          'b': (_) => const SizedBox(),
          'c': (_) => const SizedBox(),
        },
      );

      final semanticLabels = GgValue<Map<String, String>>(
        seed: {'a': 'Route A', 'b': 'Route B', 'c': 'Route C'},
      );

      await setUp(
        tester,

        // Listen to route changes
        child: StreamBuilder<Map<String, WidgetBuilder>>(
          stream: routes.stream,
          builder: (context, snapshot) {
            // Listen to semantic label changes
            return StreamBuilder<Map<String, String>>(
              stream: semanticLabels.stream,
              builder: (context, snapshot) {
                // Rebuild the router
                return GgRouter(
                  routes.value,
                  key: key,
                  semanticLabels: semanticLabels.value,
                );
              },
            );
          },
        ),
      );

      // Check if the routes and labels were written into the node tree.
      final node = routerDelegate.root;
      expect(node.hasChild(name: 'a'), isTrue);
      expect(node.hasChild(name: 'b'), isTrue);
      expect(node.hasChild(name: 'c'), isTrue);

      expect(node.child('a')!.semanticLabel, semanticLabels.value['a']);
      expect(node.child('b')!.semanticLabel, semanticLabels.value['b']);
      expect(node.child('c')!.semanticLabel, semanticLabels.value['c']);

      // .......................................
      // Rebuild the GgRouter with the same key,
      // but with different semantic labels.

      // Add another route
      routes.value = {...routes.value, 'd': (context) => const SizedBox()};

      // Add another semantic label
      semanticLabels.value = {...semanticLabels.value, 'd': 'Route d'};

      // Rebuild
      await tester.pumpAndSettle();

      // Check if the routes and labels were written into the node tree again.
      expect(node.hasChild(name: 'a'), isTrue);
      expect(node.hasChild(name: 'b'), isTrue);
      expect(node.hasChild(name: 'c'), isTrue);
      expect(node.hasChild(name: 'd'), isTrue);

      expect(node.child('a')!.semanticLabel, semanticLabels.value['a']);
      expect(node.child('b')!.semanticLabel, semanticLabels.value['b']);
      expect(node.child('c')!.semanticLabel, semanticLabels.value['c']);
      expect(node.child('d')!.semanticLabel, semanticLabels.value['d']);
    });

    // #########################################################################
    group('GgRouter.from', () {
      final other = GgRouter(
        const {},
        key: GlobalKey(),
        animationDuration: const Duration(),
        defaultRoute: 'default',
        inAnimation: (c, a, child, size) => Container(),
        outAnimation: (c, a, child, size) => Container(),
        semanticLabels: const {},
      );

      test('should a copy of the router by default', () {
        final copy = GgRouter.from(other);
        expect(other.animationDuration, copy.animationDuration);
        expect(other.children, copy.children);
        expect(other.defaultRoute, copy.defaultRoute);
        expect(other.inAnimation, copy.inAnimation);
        expect(other.outAnimation, copy.outAnimation);
        expect(other.semanticLabels, copy.semanticLabels);
        expect(other.key, copy.key);
      });

      test('should allow to overwrite properties', () {
        final newKey = GlobalKey();
        final newChildren = {'x': (_) => Container()};
        const newAnimationDuration = Duration();
        const newDefaultRoute = 'other';
        Container newInAnimation(c, a, child, size) => Container();
        Container newOutAnimation(c, a, child, size) => Container();
        final newSemanticLabels = {'a': 'bla bla'};

        final copy = GgRouter.from(
          other,
          key: newKey,
          children: newChildren,
          animationDuration: newAnimationDuration,
          defaultRoute: newDefaultRoute,
          inAnimation: newInAnimation,
          outAnimation: newOutAnimation,
          semanticLabels: newSemanticLabels,
        );
        expect(copy.animationDuration, newAnimationDuration);
        expect(copy.children, newChildren);
        expect(copy.defaultRoute, copy.defaultRoute);
        expect(copy.inAnimation, copy.inAnimation);
        expect(copy.outAnimation, copy.outAnimation);
        expect(copy.semanticLabels, copy.semanticLabels);
      });
    });

    // #########################################################################
    group('Default children', () {
      // .......................................................................
      testWidgets(
        'An error should be thrown if defaultChild is not one of the child routes',
        (WidgetTester tester) async {
          await setUp(
            tester,
            child: Builder(
              builder: (context) {
                return GgRouter(
                  {'a': (_) => Container()},
                  key: GlobalKey(),
                  defaultRoute: 'b',
                );
              },
            ),
          );

          expect(
            tester.takeException(),
            predicate((ArgumentError f) {
              expect(
                f.message,
                'Error GRC008506: The defaultChild "b" does not exist.',
              );
              return true;
            }),
          );
        },
      );

      // .......................................................................
      testWidgets('Should write the default child into the node', (
        WidgetTester tester,
      ) async {
        late GgRouteTreeNode root;

        await setUp(
          tester,
          initialRoute: '/a',
          child: Builder(
            builder: (context) {
              root = GgRouter.of(context).node.root;
              return GgRouter(
                {'a': (_) => Container()},
                key: GlobalKey(),
                defaultRoute: 'a',
              );
            },
          ),
        );

        expect(root.defaultChildName, 'a');
      });
    });

    // #########################################################################
    group('Wild card routes', () {
      // .......................................................................
      testWidgets(
        'If no wild card is defined and an unknown route is opened, an error is thrown.',
        (WidgetTester tester) async {
          // .......................................
          // Define a router with no wild card route
          await setUp(
            tester,
            child: Builder(
              builder: (context) {
                return GgRouter(
                  {'a': (_) => Container(), '_INDEX_': (_) => Container()},
                  key: GlobalKey(),
                  defaultRoute: 'a',
                );
              },
            ),
          );

          // ........................................
          // Route to a known route first -> no error
          routerDelegate.root.navigateTo('/a');
          await tester.pumpAndSettle();
          expect(tester.takeException(), null);

          // .................................
          // Route to an unknown route -> error

          // .........................
          GgRouteTreeNodeError? error;
          routerDelegate.root.errorHandler = (err) => error = err;
          routerDelegate.root.navigateTo('/unknown');

          await tester.pumpAndSettle();
          expect(
            error!.message,
            'Route "/" has no child named "unknown" nor does your GgRouter define a "*" wild card route.',
          );
        },
      );

      // .......................................................................
      testWidgets(
        'If a wild card is defined and we navigate to an unknown route, the wild card route is opened.',
        (WidgetTester tester) async {
          // .......................................
          // Define a router with no wild card route

          final wildCardKey = GlobalKey();
          final routeAKey = GlobalKey();

          await setUp(
            tester,
            child: Builder(
              builder: (context) {
                return GgRouter(
                  {
                    'a': (_) => Container(key: routeAKey),
                    '_INDEX_': (_) => Container(),
                    '*': (_) => Container(key: wildCardKey),
                  },
                  key: GlobalKey(),
                  defaultRoute: 'a',
                );
              },
            ),
          );

          // ............................
          // Route to a known route first
          routerDelegate.root.navigateTo('/a');
          await tester.pumpAndSettle();
          expect(find.byKey(routeAKey), findsOneWidget);
          expect(find.byKey(wildCardKey), findsNothing);

          // .....................................................
          // Route to an unknown route -> wild card route is opened
          routerDelegate.root.navigateTo('/unknown');
          await tester.pumpAndSettle();
          expect(find.byKey(routeAKey), findsNothing);
          expect(find.byKey(wildCardKey), findsOneWidget);
          expect(routerDelegate.currentConfiguration.uri.toString(), 'unknown');
        },
      );
    });

    // #########################################################################
    group('Route animations', () {
      late Text inAnimationWidget;
      late Text outAnimationWidget;
      int? indexOfChildAnimatingIn;
      int? indexOfChildAnimatingOut;
      String? nameOfChildAnimatingIn;
      String? nameOfChildAnimatingOut;

      update(WidgetTester tester) {
        inAnimationWidget =
            tester.widget(find.byKey(const Key('inAnimation'))) as Text;
        outAnimationWidget =
            tester.widget(find.byKey(const Key('outAnimation'))) as Text;
      }

      updateAnimationDetails(BuildContext context) {
        indexOfChildAnimatingIn = GgRouter.of(context).indexOfChildAnimatingIn;
        indexOfChildAnimatingOut = GgRouter.of(
          context,
        ).indexOfChildAnimatingOut;
        nameOfChildAnimatingIn = GgRouter.of(context).nameOfChildAnimatingIn;
        nameOfChildAnimatingOut = GgRouter.of(context).nameOfChildAnimatingOut;
      }

      checkAnimationDetails(
        int? indexIn,
        int? indexOut,
        String? nameIn,
        String? nameOut,
      ) {
        expect(indexOfChildAnimatingIn, indexIn);
        expect(indexOfChildAnimatingOut, indexOut);
        expect(nameOfChildAnimatingIn, nameIn);
        expect(nameOfChildAnimatingOut, nameOut);
      }

      testWidgets('should animate route transitions', (
        WidgetTester tester,
      ) async {
        const routeAKey = Key('routeA');
        const routeBKey = Key('routeB');

        // ................................
        // Create a route with two siblings
        final router = GgRouter(
          {
            'routeA': (context) => Container(key: routeAKey),
            'routeB': (context) => Container(key: routeBKey),
          },
          key: const ValueKey('mainRouter'),

          // Wrap animated widgets into a stack showing a text with the
          // animation value
          inAnimation: (context, animation, child, size) {
            updateAnimationDetails(context);
            return Stack(
              children: [
                child,
                Text('${animation.value}', key: const Key('inAnimation')),
              ],
            );
          },
          outAnimation: (context, animation, child, size) {
            updateAnimationDetails(context);
            return Stack(
              children: [
                child,
                Text('${animation.value}', key: const Key('outAnimation')),
              ],
            );
          },
          animationDuration: const Duration(milliseconds: 1000),
        );

        // ........................
        // Create a router delegate
        final routerDelegate = GgRouterDelegate(child: router);
        final root = routerDelegate.root;
        root.findOrCreateChild('routeA').navigateTo('.');

        // .............
        // Create an app
        await tester.pumpWidget(
          MaterialApp.router(
            routeInformationParser: GgRouteInformationParser(),
            routerDelegate: routerDelegate,
          ),
        );
        await tester.pumpAndSettle();

        // ......................................
        // At the beginning routeA should be shown
        expect(find.byKey(routeAKey), findsOneWidget);
        expect(find.byKey(routeBKey), findsNothing);

        // ........................................
        // No animation details should be available
        checkAnimationDetails(null, null, null, null);

        // ..........................
        // Now let's switch to routeB
        root.findOrCreateChild('routeB').navigateTo('.');

        // ..........................
        // At the beginning both, routeA and routeB should be visbible
        // because both are animating
        await tester.pump(const Duration(microseconds: 0));
        update(tester);
        expect(find.byKey(routeAKey), findsOneWidget);
        expect(find.byKey(routeBKey), findsOneWidget);

        // The right animation values should be delivered
        expect(inAnimationWidget.data, '0.0');
        expect(outAnimationWidget.data, '0.0');
        checkAnimationDetails(1, 0, 'routeB', 'routeA');

        // Now jump to the middle of the animation and check if the
        // right animation values were delivered.
        await tester.pump(const Duration(milliseconds: 500));
        update(tester);
        expect(inAnimationWidget.data, '0.5');
        expect(outAnimationWidget.data, '0.5');

        // Once the animation has finished, only the new route should be
        // visible
        await tester.pump(const Duration(milliseconds: 1001));
        expect(find.byKey(routeAKey), findsNothing);
        expect(find.byKey(routeBKey), findsOneWidget);

        // Finish everything
        await tester.pumpAndSettle();
      });

      testWidgets('should animate widgets wrapped into "GgShowInForeground" in '
          'front of other widgets', (tester) async {
        // .........................................
        // While animating switch GgShowInForeground

        const routeOutKey = Key('routeOut');
        const routeInKey = Key('routeIn');

        // .........................................
        // Create an animation deciding if routeA and/or routeB should be shown
        // in front of the other
        bool showOutRouteOnTheTopWhileAnimating = false;
        bool showInRouteOnTheTopWhileAnimating = false;

        StatelessWidget animation(context, animation, child, size) {
          final c = child as GgRouterCore;
          expect(size.width, 800);
          expect(size.height, 600);

          return (c.routeName == 'routeOut' &&
                      showOutRouteOnTheTopWhileAnimating) ||
                  (c.routeName == 'routeIn' &&
                      showInRouteOnTheTopWhileAnimating)
              ? GgShowInForeground(child: child)
              : child;
        }

        // .........................................
        // Check if widget wrapped into "GgShowInForeground" is shown infront
        // of the other widget

        // ................................
        // Create a route with two siblings
        final router = GgRouter(
          {
            'routeOut': (context) => Container(key: routeOutKey),
            'routeIn': (context) => Container(key: routeInKey),
          },
          key: const ValueKey('mainRouter'),

          // While animating wrap animated child into "GgShowInForeground"
          // if the corresponding flag is set
          inAnimation: animation,
          outAnimation: animation,
          animationDuration: const Duration(milliseconds: 1000),
        );

        // ........................
        // Create a router delegate
        final routerDelegate = GgRouterDelegate(child: router);
        final root = routerDelegate.root;
        root.findOrCreateChild('routeOut').navigateTo('.');

        // .............
        // Create an app
        await tester.pumpWidget(
          MaterialApp.router(
            routeInformationParser: GgRouteInformationParser(),
            routerDelegate: routerDelegate,
          ),
        );
        await tester.pumpAndSettle();

        // ......................................
        // At the beginning routeA should be shown
        expect(find.byKey(routeOutKey), findsOneWidget);
        expect(find.byKey(routeInKey), findsNothing);

        // .........................................................
        // Which widget is shown background and which in foreground?
        late Finder stackFinder;
        late Stack stackWidget;
        late GgRouterCore widgetInForeground;
        late GgRouterCore widgetInBackground;

        update() {
          stackFinder = find.byType(Stack);
          expect(stackFinder, findsOneWidget);
          stackWidget = tester.widget(stackFinder);
          expect(stackWidget.children.length, 2);

          final last = stackWidget.children.last;
          final first = stackWidget.children.first;

          widgetInForeground = (last is GgShowInForeground)
              ? last.child as GgRouterCore
              : last as GgRouterCore;

          widgetInBackground = (first is GgShowInForeground)
              ? first.child as GgRouterCore
              : first as GgRouterCore;
        }

        // ..........................
        // Now let's switch to routeIn
        root.findOrCreateChild('routeIn').navigateTo('.');
        await tester.pump(const Duration(microseconds: 0));
        update();

        // By default the widget animating in is shown in the foreground
        expect(widgetInForeground.routeName, 'routeIn');
        expect(widgetInBackground.routeName, 'routeOut');

        // ........................................
        // Now let's put routeOut to the foreground
        showOutRouteOnTheTopWhileAnimating = true;
        await tester.pump(const Duration(microseconds: 100));
        update();

        expect(widgetInForeground.routeName, 'routeOut');
        expect(widgetInBackground.routeName, 'routeIn');

        // ........................................
        // Now let's put routeIn to the foreground
        showOutRouteOnTheTopWhileAnimating = false;
        showInRouteOnTheTopWhileAnimating = true;

        await tester.pump(const Duration(microseconds: 100));
        update();

        expect(widgetInForeground.routeName, 'routeIn');
        expect(widgetInBackground.routeName, 'routeOut');

        // Finish everything
        await tester.pumpAndSettle();
      });
    });

    // #########################################################################
    group('Semantic labels', () {
      test(
        'should throw an exception if semantic labels for non existing routes are defined',
        () {
          expect(
            () {
              GgRouter(
                const {},
                semanticLabels: const {'xyz': 'X Y Z'},
                key: GlobalKey(),
              );
            },
            throwsA(
              predicate((ArgumentError e) {
                expect(
                  e.message,
                  'You specified a semantic label for route "xyz", but you did not setup a route with name "xyz".',
                );
                return true;
              }),
            ),
          );
        },
      );

      test('should pass if semantic labels match the routes', () {
        GgRouter(
          {'xyz': (_) => Container()},
          semanticLabels: const {'xyz': 'X Y Z'},
          key: GlobalKey(),
        );
      });

      testWidgets('Semantic labels should be written to route tree', (
        WidgetTester tester,
      ) async {
        // ..................
        // Create a root node
        final root = GgRouteTreeNode.newRoot();

        // ......................
        // Instantiate the router
        await tester.pumpWidget(
          GgRouter.root(
            child: GgRouter(
              {
                'xyz': (_) => Container(key: GlobalKey()),
                'abc': (_) => Container(key: GlobalKey()),
              },
              semanticLabels: const {'xyz': 'XYZ Label', 'abc': 'ABC Label'},
              key: GlobalKey(),
              defaultRoute: 'xyz',
            ),
            node: root,
          ),
        );

        // ..............................................................
        // Check if the semantic labels have ben written to the node tree
        expect(root.child('xyz')?.semanticLabel, 'XYZ Label');
        expect(root.child('abc')?.semanticLabel, 'ABC Label');
      });

      testWidgets('Semantic labels should also work for PopoverRoute', (
        WidgetTester tester,
      ) async {
        // ......................
        // Create a popover route
        final root = GgRouteTreeNode.newRoot();
        await tester.pumpWidget(
          GgRouter.root(
            child: GgPopoverRoute(
              key: GlobalKey(),
              name: 'xyz',
              base: Container(),
              popover: (_) => Container(),
              semanticLabel: 'XYZ Label',
            ),
            node: root,
          ),
        );

        // ........................................
        // Has semantic label been written to node?
        expect(root.child('xyz')?.semanticLabel, 'XYZ Label');
      });

      testWidgets(
        'GgRouter.of(context).semanticLabelForPath() should return the right semantic label',
        (WidgetTester tester) async {
          // ...................
          // Create a route tree
          final root = GgRouteTreeNode.newRoot();
          bool didCheck = false;
          await tester.pumpWidget(
            GgRouter.root(
              child: GgRouter(
                {
                  'childA': (_) {
                    return GgRouter(
                      {
                        'childA0': (context) {
                          didCheck = true;

                          // ...................................................
                          // Check if semantic labels can be retrieved correctly
                          expect(
                            GgRouter.of(context).semanticLabelForPath('../'),
                            'childA',
                          );

                          expect(
                            GgRouter.of(context).semanticLabelForPath('../../'),
                            root.name,
                          );

                          expect(
                            GgRouter.of(
                              context,
                            ).semanticLabelForPath('../../childB'),
                            'childB Label',
                          );

                          return Container();
                        },
                      },
                      key: GlobalKey(),
                      defaultRoute: 'childA0',
                    );
                  },
                  'childB': (_) {
                    return Container();
                  },
                },
                semanticLabels: const {'childB': 'childB Label'},
                key: GlobalKey(),
                defaultRoute: 'childA',
              ),
              node: root,
            ),
          );

          // .....................
          // Check semantic labels
          expect(didCheck, true);
        },
      );

      testWidgets(
        'GgRouter.of(context).setSemanticLabelForPath(path, label) should '
        'allow to set a semantic labe for a given relative path',
        (WidgetTester tester) async {
          // ...................
          // Create a route tree
          final root = GgRouteTreeNode.newRoot();
          bool didCheck = false;
          await tester.pumpWidget(
            GgRouter.root(
              child: GgRouter(
                {
                  'childA': (_) {
                    return GgRouter(
                      {
                        'childA0': (context) {
                          didCheck = true;

                          GgRouter.of(context).setSemanticLabelForPath(
                            path: '../',
                            label: 'CUSTOMLABEL',
                          );

                          // ...................................................
                          // Check if semantic labels can be retrieved correctly
                          expect(
                            GgRouter.of(context).semanticLabelForPath('../'),
                            'CUSTOMLABEL',
                          );

                          return Container();
                        },
                      },
                      key: GlobalKey(),
                      defaultRoute: 'childA0',
                    );
                  },
                  'childB': (_) {
                    return Container();
                  },
                },
                semanticLabels: const {'childB': 'childB Label'},
                key: GlobalKey(),
                defaultRoute: 'childA',
              ),
              node: root,
            ),
          );

          // .....................
          // Check semantic labels
          expect(didCheck, true);
        },
      );
    });
  });
}
