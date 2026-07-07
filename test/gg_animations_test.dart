// @license
// Copyright (c) 2019 - 2023 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/src/gg_animations.dart';

typedef NewGgAnimation =
    GgAnimation Function({
      required Animation<dynamic> animation,
      required Widget child,
      Key? key,
      required Size size,
    });

void main() {
  late WidgetTester tester;
  late AnimationController animationController;

  const width = 800.0;
  const height = 600.0;

  group('GgAnimation', () {
    // .........................................................................
    Future<void> setUp(WidgetTester tst, NewGgAnimation ggAnimation) async {
      tester = tst;
      animationController = AnimationController(vsync: tst);
      final widget = LayoutBuilder(
        builder: (context, layout) {
          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return ggAnimation(
                animation: animationController,
                child: Container(
                  key: const ValueKey('Animated Object'),
                  width: layout.maxWidth,
                  height: layout.maxHeight,
                ),
                size: Size(layout.maxWidth, layout.maxHeight),
              );
            },
          );
        },
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    }

    // .........................................................................
    Future<void> tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    Future<void> expectOffset(Offset initial, Offset finalOffset) async {
      // Initially the animated object is positioned outside the window
      final animatedObject = find.byKey(const ValueKey('Animated Object'));
      expect(tester.getTopLeft(animatedObject), initial);

      // After animation, the object is positioned within the window
      animationController.value = 1.0;
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(animatedObject), finalOffset);
    }

    // .........................................................................
    Future<void> expectInitialOffset(double x, double y) async {
      await expectOffset(Offset(x, y), const Offset(0, 0));
    }

    // .........................................................................
    Future<void> expectFinalOffset(double x, double y) async {
      await expectOffset(const Offset(0, 0), Offset(x, y));
    }

    // .........................................................................
    Future<void> expectOpacity({
      required double initial,
      required double finalOpacity,
    }) async {
      // Initially the animated object is positioned outside the window
      double opacity() => tester
          .widget<Opacity>(
            find.ancestor(
              of: find.byKey(const ValueKey('Animated Object')),
              matching: find.byType(Opacity),
            ),
          )
          .opacity;

      expect(opacity(), initial);

      // After animation, the object is positioned within the window
      animationController.value = 1.0;
      await tester.pumpAndSettle();
      expect(opacity(), finalOpacity);
    }

    // .........................................................................
    testWidgets('GgMoveInFromTop', (WidgetTester tester) async {
      await setUp(tester, GgMoveInFromTop.new);
      await expectInitialOffset(0, -height);
      await tearDown(tester);
    });

    testWidgets('GgMoveOutToTop', (WidgetTester tester) async {
      await setUp(tester, GgMoveOutToTop.new);
      await expectFinalOffset(0, -height);
      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('GgMoveInFromRight', (WidgetTester tester) async {
      await setUp(tester, GgMoveInFromRight.new);
      await expectInitialOffset(width, 0);
      await tearDown(tester);
    });

    testWidgets('GgMoveOutToRight', (WidgetTester tester) async {
      await setUp(tester, GgMoveOutToRight.new);
      await expectFinalOffset(width, 0);
      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('GgMoveInFromBottom', (WidgetTester tester) async {
      await setUp(tester, GgMoveInFromBottom.new);
      await expectInitialOffset(0, height);
      await tearDown(tester);
    });

    testWidgets('GgMoveOutToBottom', (WidgetTester tester) async {
      await setUp(tester, GgMoveOutToBottom.new);
      await expectFinalOffset(0, height);
      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('GgMoveInFromLeft', (WidgetTester tester) async {
      await setUp(tester, GgMoveInFromLeft.new);
      await expectInitialOffset(-width, 0);
      await tearDown(tester);
    });

    testWidgets('GgMoveOutToLeft', (WidgetTester tester) async {
      await setUp(tester, GgMoveOutToLeft.new);
      await expectFinalOffset(-width, 0);
      await tearDown(tester);
    });

    // ######################
    // Diagonal
    // ######################

    // .........................................................................
    testWidgets('GgMoveInFromTopLeft', (WidgetTester tester) async {
      await setUp(tester, GgMoveInFromTopLeft.new);
      await expectInitialOffset(-width, -height);
      await tearDown(tester);
    });

    testWidgets('GgMoveOutToTopLeft', (WidgetTester tester) async {
      await setUp(tester, GgMoveOutToTopLeft.new);
      await expectFinalOffset(-width, -height);
      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('GgMoveInFromTopRight', (WidgetTester tester) async {
      await setUp(tester, GgMoveInFromTopRight.new);
      await expectInitialOffset(width, -height);
      await tearDown(tester);
    });

    testWidgets('GgMoveOutToTopRight', (WidgetTester tester) async {
      await setUp(tester, GgMoveOutToTopRight.new);
      await expectFinalOffset(width, -height);
      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('GgMoveInFromBottomRight', (WidgetTester tester) async {
      await setUp(tester, GgMoveInFromBottomRight.new);
      await expectInitialOffset(width, height);
      await tearDown(tester);
    });

    testWidgets('GgMoveOutToBottomRight', (WidgetTester tester) async {
      await setUp(tester, GgMoveOutToBottomRight.new);
      await expectFinalOffset(width, height);
      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('GgMoveInFromBottomLeft', (WidgetTester tester) async {
      await setUp(tester, GgMoveInFromBottomLeft.new);
      await expectInitialOffset(-width, height);
      await tearDown(tester);
    });

    testWidgets('GgMoveOutToBottomLeft', (WidgetTester tester) async {
      await setUp(tester, GgMoveOutToBottomLeft.new);
      await expectFinalOffset(-width, height);
      await tearDown(tester);
    });

    // ######################
    // Fade animations
    // ######################

    // .........................................................................
    testWidgets('GgFadeIn', (WidgetTester tester) async {
      await setUp(tester, GgFadeIn.new);
      await expectOpacity(initial: 0.0, finalOpacity: 1.0);
      await tearDown(tester);
    });

    testWidgets('GgFadeOut', (WidgetTester tester) async {
      await setUp(tester, GgFadeOut.new);
      await expectOpacity(initial: 1.0, finalOpacity: 0.0);
      await tearDown(tester);
    });
  });
}
