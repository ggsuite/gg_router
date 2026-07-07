// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router_example/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GgRouterExample', () {
    // .........................................................................
    late GgEasyWidgetTest<GgRouterExample, dynamic> ggRouterExample;
    final key = GlobalKey(debugLabel: 'GgRouterExample');

    late GgRouterDelegate routerDelegate;
    late String currentUri;

    GgEasyWidgetTest? indexPage;
    GgEasyWidgetTest? sportsPage;
    GgEasyWidgetTest? transportationPage;
    GgEasyWidgetTest? placesPage;

    late GgEasyWidgetTest sportsButton;
    late GgEasyWidgetTest transportationButton;
    late GgEasyWidgetTest placesButton;

    GgEasyWidgetTest? bottomBarButton0;
    GgEasyWidgetTest? bottomBarButton1;
    GgEasyWidgetTest? bottomBarButton2;

    // .........................................................................
    initSharedPreferences({String? state}) {
      final lastState = state ?? '{}';

      // .......................................
      // Put the lastState to shared preferences
      SharedPreferences.setMockInitialValues({
        'lastApplicationState': lastState,
      });
    }

    // .........................................................................
    GgEasyWidgetTest? page(String key, WidgetTester tester) {
      final finder = find.byKey(ValueKey(key));
      final elements = finder.evaluate();
      if (elements.isNotEmpty) {
        return GgEasyWidgetTest(finder, tester);
      }
      return null;
    }

    // .........................................................................
    updatePages(WidgetTester tester) {
      indexPage = page('indexPage', tester);
      sportsPage = page('sportsPage', tester);
      transportationPage = page('transportationPage', tester);
      placesPage = page('placesPage', tester);
      currentUri = routerDelegate.currentConfiguration.uri.toString();
    }

    // .........................................................................
    updateHeaderBar(WidgetTester tester) {
      sportsButton = GgEasyWidgetTest(
        find.byKey(const ValueKey('sports')),
        tester,
      );
      transportationButton = GgEasyWidgetTest(
        find.byKey(const ValueKey('transportation')),
        tester,
      );
      placesButton = GgEasyWidgetTest(
        find.byKey(const ValueKey('places')),
        tester,
      );
    }

    // .........................................................................
    updateRouterDelegate(WidgetTester tester) {
      routerDelegate =
          (tester.widget(find.byType(MaterialApp)) as MaterialApp)
                  .routerDelegate
              as GgRouterDelegate;
    }

    // .........................................................................
    updateBottomBarButtons(WidgetTester tester) {
      final bottomNavigationBar = find.byType(BottomNavigationBar);

      final icons = find.descendant(
        of: bottomNavigationBar,
        matching: find.byType(Icon),
      );

      if (icons.evaluate().length == 3) {
        bottomBarButton0 = GgEasyWidgetTest(icons.at(0), tester);
        bottomBarButton1 = GgEasyWidgetTest(icons.at(1), tester);
        bottomBarButton2 = GgEasyWidgetTest(icons.at(2), tester);
      }
    }

    // .........................................................................
    update(WidgetTester tester) {
      updatePages(tester);
      updateHeaderBar(tester);
      updateBottomBarButtons(tester);
    }

    // .........................................................................
    pressBottomButton(int index, WidgetTester tester) async {
      final button = index == 0
          ? bottomBarButton0
          : index == 1
          ? bottomBarButton1
          : bottomBarButton2;

      final gesture = await tester.startGesture(button!.absoluteFrame.center);
      await gesture.up();
      await tester.pumpAndSettle();
      update(tester);
    }

    // .........................................................................
    setUp(WidgetTester tester, {String? lastState}) async {
      initSharedPreferences(state: lastState);
      final widget = GgRouterExample(key: key);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      final ggRouterExampleFinder = find.byWidget(widget);
      ggRouterExample = GgEasyWidgetTest(ggRouterExampleFinder, tester);
      updateRouterDelegate(tester);
      update(tester);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should only show the visible route page', (
      WidgetTester tester,
    ) async {
      // ................................
      // Check the inital size of the app
      await setUp(tester);
      expect(ggRouterExample.width, 800);
      expect(ggRouterExample.height, 600);
      routerDelegate.root.navigateTo('_INDEX_');
      await tester.pumpAndSettle();
      update(tester);

      // ........................................
      // Initially the index page should be shown
      expect(indexPage, isNotNull);
      expect(sportsPage, isNull);
      expect(transportationPage, isNull);
      expect(placesPage, isNull);

      // ..................................
      // Click on sports menu item
      // => Sports page should only be shown
      await sportsButton.press();
      update(tester);
      expect(sportsPage, isNotNull);
      expect(transportationPage, isNull);
      expect(placesPage, isNull);
      expect(currentUri, startsWith('sports/'));

      // ..................................
      // Click on transportations menu item
      // => Transportations page should only be shown
      await transportationButton.press();
      update(tester);
      expect(sportsPage, isNull);
      expect(transportationPage, isNotNull);
      expect(placesPage, isNull);
      expect(currentUri, startsWith('transportation/'));

      // .........................
      // Click on places menu item
      // => Transportations page should only be shown
      await placesButton.press();
      update(tester);
      expect(sportsPage, isNull);
      expect(transportationPage, isNull);
      expect(placesPage, isNotNull);
      expect(currentUri, startsWith('places/'));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('sports show a bottom navigation bar with tree items', (
      WidgetTester tester,
    ) async {
      await setUp(tester);

      // .......................
      // Jump to the sports page
      await sportsButton.press();
      update(tester);

      // ..........................
      // Click on the first button
      // => Basketball page should open
      await pressBottomButton(0, tester);
      expect(currentUri, startsWith('sports/basketball'));

      // ..........................
      // Click on the second button
      // => Basketball page should open
      await pressBottomButton(1, tester);
      expect(currentUri, startsWith('sports/football'));

      // ..........................
      // Click on the third button
      // => Handball page should open
      await pressBottomButton(2, tester);
      expect(currentUri, startsWith('sports/handball'));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets(
      'transportation should show a bottom navigation bar with tree items',
      (WidgetTester tester) async {
        await setUp(tester);

        // .......................
        // Jump to the sports page
        await sportsButton.press();
        update(tester);

        // .............................
        // Switch to transportation page
        await transportationButton.press();

        // ..........................
        // Click on the first button
        // => Basketball page should open
        await pressBottomButton(0, tester);
        expect(currentUri, startsWith('transportation/bus'));

        // ..........................
        // Click on the second button
        // => Basketball page should open
        await pressBottomButton(1, tester);
        expect(currentUri, startsWith('transportation/bike'));

        // ..........................
        // Click on the third button
        // => Handball page should open
        await pressBottomButton(2, tester);
        expect(currentUri, startsWith('transportation/car'));

        await tearDown(tester);
      },
    );

    // .........................................................................
    testWidgets('places should show a bottom navigation bar with tree items', (
      WidgetTester tester,
    ) async {
      await setUp(tester);

      // .............................
      // Switch to transportation page
      await placesButton.press();
      update(tester);

      // ..........................
      // Click on the first button
      // => Basketball page should open
      await pressBottomButton(0, tester);
      expect(currentUri, startsWith('places/airport'));

      // ..........................
      // Click on the second button
      // => Basketball page should open
      await pressBottomButton(1, tester);
      expect(currentUri, startsWith('places/park'));

      // ..........................
      // Click on the third button
      // => Handball page should open
      await pressBottomButton(2, tester);
      expect(currentUri, startsWith('places/hospital'));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('when switching from transporations page back to sports page, '
        'the last opened sports sub-page should be opeend', (
      WidgetTester tester,
    ) async {
      await setUp(tester);

      // .......................
      // Jump to the sports page
      await sportsButton.press();
      update(tester);

      // .............................
      // Open the football sports page
      await pressBottomButton(1, tester);
      expect(currentUri, startsWith('sports/football'));

      // .............................
      // Open the transportations page
      await transportationButton.press();
      update(tester);
      expect(currentUri, startsWith('transportation'));

      // .............................
      // Switch back to sports page
      // => last opened page should be visible again
      await sportsButton.press();
      update(tester);
      expect(currentUri, startsWith('sports/football'));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('when clicking on basket ball page, a dialog should open. '
        'The dialog should show a check box. '
        'Checking the checkbox should change the visit param in the URI. '
        'Changing the visit param in the URI should change the checkbox. '
        'Clicking the close button should switch back.', (
      WidgetTester tester,
    ) async {
      await setUp(tester);

      // .......................
      // Jump to the sports page
      await sportsButton.press();
      update(tester);
      expect(currentUri, startsWith('sports/basketball'));

      // ....................................................
      // Click on the basket ball in the center of the screen
      final gesture = await tester.startGesture(
        ggRouterExample.absoluteFrame.center,
      );
      await gesture.up();
      update(tester);

      // ................................
      // A dialog should have been opened
      expect(currentUri, startsWith('sports/basketball/popover'));
      await tester.pumpAndSettle();

      // ..........................
      // There should be a checkbox
      // The checkbox should not be checked
      var checkBox = GgEasyWidgetTest(find.byType(CheckboxListTile), tester);
      var checkBoxWidget = checkBox.widget as CheckboxListTile;
      expect(checkBoxWidget.value, false);
      update(tester);
      expect(currentUri, 'sports/basketball/popover?visit=false');

      // ........................
      // Let's click the checkbox
      // => The checkbox should be checked now
      await checkBox.press();
      update(tester);
      checkBox = GgEasyWidgetTest(find.byType(CheckboxListTile), tester);
      checkBoxWidget = checkBox.widget as CheckboxListTile;
      expect(checkBoxWidget.value, true);
      expect(currentUri, 'sports/basketball/popover?visit=true');

      // ..............
      // Change the URI
      // => checkbox should change also
      await routerDelegate.setNewRoutePath(
        RouteInformation(
          uri: Uri.parse('sports/basketball/popover?visit=false'),
        ),
      );
      await tester.pumpAndSettle();
      update(tester);
      checkBox = GgEasyWidgetTest(find.byType(CheckboxListTile), tester);
      checkBoxWidget = checkBox.widget as CheckboxListTile;
      expect(checkBoxWidget.value, false);

      // ..............................
      // Finally let's close the dialog
      // => dialog is removed from the URI
      final dialogCloseButton = GgEasyWidgetTest(
        find.byKey(const ValueKey('GgNavigationPageCloseButton')),
        tester,
      );
      await dialogCloseButton.press();
      await tester.pumpAndSettle();
      update(tester);
      expect(currentUri, 'sports/basketball?visit=false');

      await tearDown(tester);
    });

    testWidgets('when clicking on basket ball page, a dialog should open. '
        'Clicking on "Details" should open a detail page. '
        'Clicking on "Even more Details" should open another detail page. '
        'Clicking on the "back button" should navigate to the previous page. '
        'Clicking on the "close button" should close the dialog. ', (
      WidgetTester tester,
    ) async {
      await setUp(tester);

      // ................
      // Open the popover
      routerDelegate.root.navigateTo('/sports/basketball/popover');
      await tester.pumpAndSettle();
      expect(routerDelegate.root.stagedChildPath, 'sports/basketball/popover');

      // ..................
      // Click on "Details"
      final detailsButtonFinder = find.byKey(const ValueKey('Details Button'));
      expect(detailsButtonFinder, findsOneWidget);
      var gesture = await tester.press(detailsButtonFinder);
      await gesture.up();
      await tester.pumpAndSettle();

      // Check if the details page was opened
      expect(
        routerDelegate.root.stagedChildPath,
        'sports/basketball/popover/details',
      );

      // .......................
      // Click on "More details"
      final moreDetailsButtonFinder = find.byKey(
        const ValueKey('More Details Button'),
      );
      expect(moreDetailsButtonFinder, findsOneWidget);
      gesture = await tester.press(moreDetailsButtonFinder);
      await gesture.up();
      await tester.pumpAndSettle();

      // Check if the details page was opened
      expect(
        routerDelegate.root.stagedChildPath,
        'sports/basketball/popover/details/more-details',
      );

      // ........................
      // Click on the back button
      final dialogBackButton = GgEasyWidgetTest(
        find.byKey(const ValueKey('GgNavigationPageBackButton')),
        tester,
      );
      await dialogBackButton.press();
      await tester.pumpAndSettle();

      // Check if we have navigated back
      expect(
        routerDelegate.root.stagedChildPath,
        'sports/basketball/popover/details',
      );

      // ..............................
      // Finally let's close the dialog
      // => dialog is removed from the URI
      final dialogCloseButton = GgEasyWidgetTest(
        find.byKey(const ValueKey('GgNavigationPageCloseButton')),
        tester,
      );
      await dialogCloseButton.press();
      await tester.pumpAndSettle();
      update(tester);
      expect(currentUri, 'sports/basketball?visit=false');
    });

    // .........................................................................
    testWidgets('opening an unknown URL should show an error in the snack bar', (
      WidgetTester tester,
    ) async {
      await setUp(tester);

      await routerDelegate.setNewRoutePath(
        RouteInformation(uri: Uri.parse('sports/superhero')),
      );
      await tester.pumpAndSettle();
      final snackBar =
          GgEasyWidgetTest(find.byType(SnackBar), tester).widget as SnackBar;
      expect(
        (snackBar.content as Text).data,
        'Route "/sports" has no child named "superhero" nor does your GgRouter define a "*" wild card route.',
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('navigating to /xyz should open the wildcard page.', (
      WidgetTester tester,
    ) async {
      await setUp(tester);

      await routerDelegate.setNewRoutePath(
        RouteInformation(uri: Uri.parse('/xyz')),
      );
      await tester.pumpAndSettle();

      // Check if /xyz is the path of the staged child
      expect(routerDelegate.root.stagedChildPath, 'xyz');

      // Check if the name of the wild card route could be accessed
      // using the context.
      expect(find.byKey(const ValueKey('WildCardText: xyz')), findsOneWidget);

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('The last state should be loaded from shared preferences.', (
      WidgetTester tester,
    ) async {
      // ................................................................
      // Define an application state which makes transportion/bus visible
      // by default.

      const stagedChildKey = GgRouteTreeNode.stagedChildJsonKey;
      const lastState =
          '''
      {
        "$stagedChildKey":"transportation",
        "transportation":{
        "$stagedChildKey":"bus"
        }
      }
      ''';

      // .......................................
      // Start the application, and expect that it is on transportation/bus
      await setUp(tester, lastState: lastState);
      await tester.pumpAndSettle();
      update(tester);
      expect(routerDelegate.root.stagedChildPath, 'transportation/bus');
      expect(indexPage, isNull);
      expect(sportsPage, isNull);
      expect(transportationPage, isNotNull);
      expect(placesPage, isNull);
    });

    // .........................................................................
    testWidgets('State changes should be saved to shared preferences', (
      WidgetTester tester,
    ) async {
      initSharedPreferences();

      const stagedChildKey = GgRouteTreeNode.stagedChildJsonKey;
      // .......................................
      // Start the application, and expect that it is on transportation/bus
      await setUp(tester);
      routerDelegate.root.navigateTo('places/hospital');
      await tester.pumpAndSettle();
      update(tester);
      expect(indexPage, isNull);
      expect(sportsPage, isNull);
      expect(transportationPage, isNull);
      expect(placesPage, isNotNull);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('lastApplicationState'),
        contains('"$stagedChildKey":"hospital"'),
      );
    });

    // .........................................................................
    testWidgets('Semantic labels should be assigned correctly', (
      WidgetTester tester,
    ) async {
      await setUp(tester);
      expect(find.bySemanticsLabel('Navigate to Sports Page'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Navigate to Transportation Page'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Navigate to Places Page'), findsOneWidget);
    });
  });
}
