// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';

void main() {
  group('GgNavigationPage', () {
    // .........................................................................
    GgNavigationPage otherNavigationPage() {
      final result = GgNavigationPage(
        showBackButton: false,
        pageContent: (_) => Container(),
      );

      return result;
    }

    // .........................................................................
    testWidgets(
      'should throw an exception when index route shows a navigation page',
      (WidgetTester tester) async {
        // Create a navigation page using that router
        final navPage = GgNavigationPageRoot(
          child: GgNavigationPage(pageContent: (_) => otherNavigationPage()),
        );

        // An error should be thrown complaining about index child being
        // an navigation page
        await tester.pumpWidget(
          GgRouter.root(child: navPage, node: GgRouteTreeNode.newRoot()),
        );
        final exception = tester.takeException();
        expect(
          exception.message,
          GgNavigationPage.indexWidgetMustNotBeANavigationPage,
        );
      },
    );

    // .........................................................................
    testWidgets(
      'should throw an exception when GgNavigationPage is not wrapped into a root',
      (WidgetTester tester) async {
        // Create a navigation page using that router
        final navPage = GgNavigationPage(
          pageContent: (_) => otherNavigationPage(),
        );

        // An error should be thrown complaining about index child being
        // an navigation page
        await tester.pumpWidget(
          GgRouter.root(child: navPage, node: GgRouteTreeNode.newRoot()),
        );
        final exception = tester.takeException();
        expect(exception.message, GgNavigationPage.noNavigationPageRootFound);
      },
    );

    // .........................................................................
    testWidgets('should decorate the index page with a navigation bar', (
      WidgetTester tester,
    ) async {
      // Create a navigation page using that router
      final navPage = GgNavigationPageRoot(
        child: GgNavigationPage(pageContent: (_) => Container()),
      );

      // Expect the container to be decorated with a navigation bar
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GgRouter.root(child: navPage, node: GgRouteTreeNode.newRoot()),
        ),
      );

      final indexPage = GgEasyWidgetTest(find.byType(GgPageWithNavBar), tester);
      expect(indexPage.width, 800);
      expect(indexPage.height, 600);
    });

    // .........................................................................
    testWidgets(
      'should take over inAnimation, outAnimation and animationDuration froom root',
      (WidgetTester tester) async {
        // Define animationDuration, inAnimation, outAnimation
        const animationDuration = Duration(milliseconds: 345);

        Widget inAnimation(
          BuildContext context,
          Animation animation,
          Widget child,
          Size size,
        ) {
          return child;
        }

        Widget outAnimation(
          BuildContext context,
          Animation animation,
          Widget child,
          Size size,
        ) {
          return child;
        }

        // Create a widget
        final rootNode = GgRouteTreeNode.newRoot();
        final contentKey = GlobalKey();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GgRouter.root(
              node: rootNode,
              child: GgNavigationPageRoot(
                child: GgNavigationPage(
                  pageContent: (_) => Container(),
                  children: {
                    'childA': GgNavigationPage(
                      pageContent: (_) => Container(key: contentKey),
                    ),
                  },
                ),
                animationDuration: animationDuration,
                inAnimation: inAnimation,
                outAnimation: outAnimation,
              ),
            ),
          ),
        );

        rootNode.navigateTo('/childA');
        await tester.pumpAndSettle();

        // Find the child page
        final routerFinder = find.byType(GgRouter);
        expect(routerFinder, findsNWidgets(3));

        final router1 = tester.widget<GgRouter>(routerFinder.at(1));
        final router2 = tester.widget<GgRouter>(routerFinder.at(2));

        // Check if child page has taken over animation values from root

        expect(router1.animationDuration, animationDuration);
        expect(router1.inAnimation, inAnimation);
        expect(router1.outAnimation, outAnimation);

        expect(router2.animationDuration, animationDuration);
        expect(router2.inAnimation, inAnimation);
        expect(router2.outAnimation, outAnimation);
      },
    );

    testWidgets('should show the route\'s semantic label as title', (
      WidgetTester tester,
    ) async {
      final root = GgRouteTreeNode.newRoot();

      // .........................................
      // Create a widget showing a navigation page
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GgRouter.root(
            node: root,
            child: GgRouter(
              {
                'child0': (_) => GgNavigationPageRoot(
                  child: GgNavigationPage(
                    pageContent: (_) => Container(),
                    children: const {},
                    showBackButton: false,
                  ),
                  key: GlobalKey(),
                ),
              },
              defaultRoute: 'child0',
              semanticLabels: const {'child0': 'Child 0 Page'},
              key: GlobalKey(),
            ),
          ),
        ),
      );

      // ...........................
      // Navigate to the child0 page
      root.navigateTo('child0');
      await tester.pumpAndSettle();

      // ...............................................
      // Check if the semantic label is shown on the top
      final titleFinder = find.byKey(const ValueKey('GgNavigationPageTitle'));
      expect(titleFinder, findsOneWidget);
      final textFinder = find.descendant(
        of: titleFinder,
        matching: find.byType(Text),
      );
      expect(textFinder, findsOneWidget);
      Text text = tester.widget(textFinder);
      expect(text.data, 'Child 0 Page');
    });

    testWidgets('should not show a back button on root page', (tester) async {
      final root = GgRouteTreeNode.newRoot();

      const customizedBackButton = Text('Back');
      const customizedCloseButton = Text('Close');
      const customizedTitle = Text('Title');

      // .........................................
      // Create a widget with customized app bar
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GgRouter.root(
            node: root,
            child: GgRouter(
              {
                'rootPage': (_) => GgNavigationPageRoot(
                  child: GgNavigationPage(
                    pageContent: (_) => Container(),
                    showBackButton: false,
                  ),
                  key: GlobalKey(),
                  navigationBarBackButton: (_) => customizedBackButton,
                  navigationBarCloseButton: (_) => customizedCloseButton,
                  navigationBarTitle: (_) => customizedTitle,
                ),
              },
              defaultRoute: 'rootPage',
              key: GlobalKey(),
            ),
          ),
        ),
      );

      // ...................................
      // Test if customized buttons are used
      expect(find.byWidget(customizedBackButton), findsNothing);
      expect(find.byWidget(customizedCloseButton), findsOneWidget);
      expect(find.byWidget(customizedTitle), findsOneWidget);
    });

    testWidgets(
      'should allow to customize back button, title and close button',
      (tester) async {
        final root = GgRouteTreeNode.newRoot();

        const customizedBackButton = Text('Back');
        const customizedCloseButton = Text('Close');
        const customizedTitle = Text('Title');

        // .........................................
        // Create a widget with customized app bar
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GgRouter.root(
              node: root,
              child: GgRouter(
                {
                  'child': (_) => GgNavigationPageRoot(
                    child: GgNavigationPage(
                      pageContent: (_) => Container(),
                      children: {
                        'grandchild': GgNavigationPage(
                          pageContent: (_) => Container(),
                        ),
                      },
                    ),
                    key: GlobalKey(),
                    navigationBarBackButton: (_) => customizedBackButton,
                    navigationBarCloseButton: (_) => customizedCloseButton,
                    navigationBarTitle: (_) => customizedTitle,
                  ),
                },
                defaultRoute: 'child',
                semanticLabels: const {'child': 'Child Page'},
                key: GlobalKey(),
              ),
            ),
          ),
        );

        root.navigateTo('child/grandchild');
        await tester.pumpAndSettle();

        // ...................................
        // Test if customized buttons are used
        expect(find.byWidget(customizedBackButton), findsOneWidget);
        expect(find.byWidget(customizedCloseButton), findsOneWidget);
        expect(find.byWidget(customizedTitle), findsOneWidget);
      },
    );

    // .........................................................................
    testWidgets('should call "onShow" if page is visited, '
        'should call "onNavigateToParent" if page navigates to parent, '
        'should call "onNavigateToChild" if page navigates to child, ', (
      WidgetTester tester,
    ) async {
      var onShowCalled = false;
      var onNavigateToParentCalled = false;
      String onNavigateToChildCalled = '';

      // Create a child page
      const childKey = Key('child');
      GgNavigationPage child() {
        final result = GgNavigationPage(
          key: childKey,
          showBackButton: true,
          pageContent: (_) => Container(),
        );

        return result;
      }

      // Create a parent page
      const selfKey = Key('self');
      GgNavigationPage self() {
        final result = GgNavigationPage(
          key: selfKey,
          showBackButton: true,
          pageContent: (_) => Container(),
          children: {'child': child()},
          onShow: () => onShowCalled = true,
          onNavigateToChild: (c) => onNavigateToChildCalled = c,
          onNavigateToParent: () => onNavigateToParentCalled = true,
        );

        return result;
      }

      // Create a parent page
      const parentKey = Key('parent');
      GgNavigationPage parent() {
        final result = GgNavigationPage(
          key: parentKey,
          showBackButton: true,
          pageContent: (_) => Container(),
          children: {'self': self()},
        );

        return result;
      }

      final root = GgNavigationPageRoot(child: parent());

      // Crate a root node
      final rootNode = GgRouteTreeNode.newRoot();

      // Pump the widget
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GgRouter.root(child: root, node: rootNode),
        ),
      );

      await tester.pumpAndSettle();

      // ......................
      // Navigate to the parent
      expect(rootNode.stagedChildPath, '');

      // Parent should be shown
      // Self and child should not be shown
      Finder parentFinder() => find.byKey(parentKey);
      expect(parentFinder(), findsOneWidget);

      Finder selfFinder() => find.byKey(selfKey);
      expect(selfFinder(), findsNothing);

      Finder childFinder() => find.byKey(childKey);
      expect(childFinder(), findsNothing);

      // ................
      // Navigate to self
      expect(onShowCalled, isFalse);
      rootNode.navigateTo('self');
      await tester.pumpAndSettle();
      expect(selfFinder(), findsOneWidget);

      // onShow should have been called
      expect(onShowCalled, isTrue);

      // .................
      // Navigate to child
      expect(onNavigateToChildCalled, isEmpty);
      onShowCalled = false;
      rootNode.navigateTo('self/child');
      await tester.pumpAndSettle();
      expect(selfFinder(), findsOneWidget);
      expect(childFinder(), findsOneWidget);

      // onNavigateToChild should have been called
      expect(onShowCalled, isFalse);
      expect(onNavigateToChildCalled, 'child');

      // .....................
      // Navigate back to self
      onNavigateToChildCalled = '';
      onShowCalled = false;
      rootNode.navigateTo('self');
      await tester.pumpAndSettle();
      expect(selfFinder(), findsOneWidget);
      expect(childFinder(), findsNothing);

      // onShow should have been called
      expect(onShowCalled, isTrue);
      expect(onNavigateToChildCalled, isEmpty);

      // .....................
      // Navigate back to parent
      onNavigateToChildCalled = '';
      onShowCalled = false;
      rootNode.navigateTo('/');
      await tester.pumpAndSettle();

      expect(parentFinder(), findsOneWidget);
      expect(selfFinder(), findsNothing);
      expect(childFinder(), findsNothing);

      // onShow should have been called
      expect(onShowCalled, false);
      expect(onNavigateToChildCalled, isEmpty);
      expect(onNavigateToParentCalled, isTrue);
    });

    // #########################################################################
    group('should show no back button and no close button when', () {
      testWidgets('if showBackButton and showCloseButton are false', (
        tester,
      ) async {
        // Create a parent page
        const parentKey = Key('parent');
        GgNavigationPage parent() {
          final result = GgNavigationPage(
            key: parentKey,
            showBackButton: false,
            showCloseButton: false,
            pageContent: (_) => Container(),
            children: {'self': Container()},
          );

          return result;
        }

        // Create a root page
        final root = GgNavigationPageRoot(child: parent());

        // Crate a root node
        final rootNode = GgRouteTreeNode.newRoot();

        // Pump the widget
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GgRouter.root(child: root, node: rootNode),
          ),
        );

        // Check buttons
        await tester.pumpAndSettle();

        final backButtonFinder = find.byKey(
          const ValueKey('GgNavigationPageBackButton'),
        );
        expect(backButtonFinder, findsNothing);

        final closeButtonFinder = find.byKey(
          const ValueKey('GgNavigationPageCloseButton'),
        );
        expect(closeButtonFinder, findsNothing);
      });
    });

    // #########################################################################
    group('should show a back button and a close button when', () {
      testWidgets('if showBackButton and showCloseButton are true', (
        tester,
      ) async {
        // Create a parent page
        const parentKey = Key('parent');
        GgNavigationPage parent() {
          final result = GgNavigationPage(
            key: parentKey,
            showBackButton: true,
            showCloseButton: true,
            pageContent: (_) => Container(),
            children: {'self': Container()},
          );

          return result;
        }

        // Create a root page
        final root = GgNavigationPageRoot(child: parent());

        // Crate a root node
        final rootNode = GgRouteTreeNode.newRoot();
        final childNode = rootNode.findOrCreateChild('child');
        final grandChildNode = childNode.findOrCreateChild('grandChild');
        grandChildNode.navigateTo('.');

        // Pump the widget
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GgRouter.root(child: root, node: grandChildNode),
          ),
        );

        // Check buttons
        await tester.pumpAndSettle();

        final backButtonFinder = find.byKey(
          const ValueKey('GgNavigationPageBackButton'),
        );
        expect(backButtonFinder, findsOneWidget);

        final closeButtonFinder = find.byKey(
          const ValueKey('GgNavigationPageCloseButton'),
        );
        expect(closeButtonFinder, findsOneWidget);

        // Back button should navigate back?
        expect(rootNode.stagedChildPath, 'child/grandChild');
        await tester.tap(backButtonFinder);
        await tester.pumpAndSettle();
        expect(rootNode.stagedChildPath, 'child');

        // Close button should navigate to the root?
        grandChildNode.navigateTo('.');
        expect(rootNode.stagedChildPath, 'child/grandChild');
        await tester.tap(closeButtonFinder);
        await tester.pumpAndSettle();
        expect(
          rootNode.stagedChildPath,
          'child',
        ); // This behavior might not be wanted
      });
    });

    // .........................................................................
    testWidgets('should throw if children contain an _INDEX_route', (
      WidgetTester tester,
    ) async {
      final node = GgRouteTreeNode.newRoot().findOrCreateChild('node');

      expect(
        () async => await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GgRouter.root(
              node: node,
              child: GgNavigationPageRoot(
                child: GgNavigationPage(
                  pageContent: (_) => Container(),
                  children: {
                    '_INDEX_': GgNavigationPage(
                      pageContent: (_) => const SizedBox(),
                    ),
                  },
                ),
              ),
            ),
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}
