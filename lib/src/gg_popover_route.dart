// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import '../gg_router.dart';

import 'gg_router.dart';

// #############################################################################
/// Use [GgPopoverRoute] to show a selected route infront of an backgroundWidget.
class GgPopoverRoute extends StatefulWidget {
  // ...........................................................................

  /// Constructor.
  const GgPopoverRoute({
    required Key key,
    required this.name,
    this.semanticLabel,
    required this.base,
    required this.popover,
    this.inAnimation,
    this.outAnimation,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  /// The base widget. It is shown when the popover is not opened.
  final Widget base;

  /// The popover. It is shown when a route with [name] is opened.
  final WidgetBuilder popover;

  /// The name of the route opening this popover.
  final String name;

  /// The semantic label assigned to the popover
  final String? semanticLabel;

  /// This animation is applied to the appearing popover
  final GgAnimationBuilder? inAnimation;

  /// this animation is applied to the disappearing popover
  final GgAnimationBuilder? outAnimation;

  /// The duration for route transitions.
  final Duration animationDuration;

  @override
  GgPopoverRouteState createState() => GgPopoverRouteState();
}

// #############################################################################
class GgPopoverRouteState extends State<GgPopoverRoute>
    with TickerProviderStateMixin {
  // ...........................................................................
  @override
  dispose() {
    for (var d in _dispose.reversed) {
      d();
    }
    super.dispose();
  }

  // ...........................................................................
  @override
  void initState() {
    _initSemanticLabel();
    _initAnimation();
    _observeActiveChildChange();
    super.initState();
  }

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    if (_popOver == null) {
      return widget.base;
    } else {
      final child = Stack(children: [widget.base, _popOver!(context)]);

      return child;
    }
  }

  // ######################
  // Private
  // ######################

  final List<Function()> _dispose = [];

  // ...........................................................................
  void _observeActiveChildChange() {
    final s = GgRouter.of(context).onActiveChildChange.listen((event) {
      _update();
    });

    _dispose.add(s.cancel);
    _update();
  }

  // ...........................................................................
  WidgetBuilder? _popOver;

  // ...........................................................................
  void _update() {
    final node = GgRouter.of(context).node;
    final popoverChild = node.findOrCreateChild(widget.name);
    final popoverIsShown = popoverChild.isStaged;

    final fadeIn =
        popoverIsShown && popoverChild.needsFade && widget.inAnimation != null;

    final fadeOut =
        !popoverIsShown && _popOver != null && widget.outAnimation != null;

    // ....................................
    // If no content is shown, hide popover
    if (!popoverIsShown && !fadeIn && !fadeOut) {
      setState(() {
        _popOver = null;
      });
      return;
    }

    // ..............................
    // Wrap content into GgRouterCore
    GgRouterCore content(BuildContext context) => GgRouterCore(
      child: Builder(builder: (context) => widget.popover(context)),
      node: popoverChild,
    );

    // ...........................................................
    // If no animation is needed show the popover content directly
    bool noAnimationNeeded = !fadeIn && !fadeOut;
    if (noAnimationNeeded) {
      // coverage:ignore-start
      setState(() {
        _popOver = content;
      });
      // coverage:ignore-end
      return;
    }

    // .................
    // Prepare animation
    if (!_animation.isAnimating) {
      // ...............
      // Start animation
      _animation.forward();

      // ...........................
      // Wrap content into animation
      final animationCallback = (fadeIn
          ? widget.inAnimation
          : widget.outAnimation)!;

      final cnt = content(context);

      _popOver = (BuildContext context) => LayoutBuilder(
        builder: (context, layout) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return animationCallback(
                context,
                _animation,
                cnt,
                Size(layout.maxWidth, layout.maxHeight),
              );
            },
          );
        },
      );

      // ................................
      // Reset needs fade after animation
      _animationStatusListener = (status) {
        if (status == AnimationStatus.completed) {
          node.childToBeFadedIn?.needsFade = false;
          node.childToBeFadedOut?.needsFade = false;
          _popOver = fadeOut ? null : content;
          _animation.removeStatusListener(_animationStatusListener);
          _animation.reset();

          setState(() {});
        }
      };
      _animation.addStatusListener(_animationStatusListener);

      // Trigger build
      setState(() {});
    }
  }

  // ...........................................................................
  late AnimationController _animation;
  late Function(AnimationStatus) _animationStatusListener;

  // ...........................................................................
  void _initAnimation() {
    _animation = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _dispose.add(() => _animation.dispose());
  }

  // ...........................................................................
  void _initSemanticLabel() {
    if (widget.semanticLabel != null) {
      final node = GgRouter.of(context).node.findOrCreateChild(widget.name);
      node.semanticLabel = widget.semanticLabel!;
    }
  }
}
