// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../gg_router.dart';

typedef GgNavigationPageBuilder = GgNavigationPage Function(BuildContext);

/// Allows you to create a widget with a navigation bar at the top
/// and a content widget below.
class GgNavigationPage extends StatefulWidget {
  // ...........................................................................
  GgNavigationPage({
    super.key,
    required this.pageContent,
    this.children,
    this.semanticLabels = const {},
    this.showBackButton = true,
    this.showCloseButton = true,
    this.onShow,
    this.onNavigateToParent,
    this.onNavigateToChild,
  }) {
    _checkChildren(children);
  }

  /// A function building the page content
  final Widget Function(BuildContext) pageContent;

  /// The children of the page. Must bee pages also
  final Map<String, Widget>? children;

  /// The semantic labels for each route
  final Map<String, String> semanticLabels;

  /// Show back button
  final bool showBackButton;

  /// Show back button
  final bool showCloseButton;

  /// Called when the page becomes active
  final VoidCallback? onShow;

  /// Called when the page navigates to parent
  final VoidCallback? onNavigateToParent;

  /// Called when the page navigates to child page
  final void Function(String childRoute)? onNavigateToChild;

  // ...........................................................................
  static void _checkChildren(Map<String, Widget>? children) {
    if (children?.containsKey('_INDEX_') == true) {
      throw ArgumentError(indexWidgetMustNotBeANavigationPage);
    }
  }

  // ...........................................................................
  @override
  State<GgNavigationPage> createState() => _GgNavigationPageState();

  static const indexWidgetMustNotBeANavigationPage =
      'GgNavigationPage must not contain an child route with name _INDEX_.';

  // ...........................................................................
  static const otherChildrenMustBeANavigationPage =
      'All children of the router of a navigation page '
      'must be also of type GgNavigationPage';

  // ...........................................................................
  static const noNavigationPageRootFound =
      'No ancestor of type GgNavigationPageRoot found. Please make sure to '
      'wrap your GgNavigationPage instance into a GgNavigationPageRoot instance';
}

// #############################################################################
// .............................................................................
class _GgNavigationPageState extends State<GgNavigationPage> {
  // ...........................................................................
  @override
  void initState() {
    _listenToRouteChanges();
    super.initState();
  }

  // ...........................................................................
  @override
  void dispose() {
    for (final d in _dispose.reversed) {
      d();
    }

    super.dispose();
  }

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    final root = _root(context);

    final routePath = GgRouter.of(context).routePath;

    return GgRouter(
      _generateChildren(context),
      semanticLabels: widget.semanticLabels,
      key: ValueKey(routePath),
      animationDuration: root.animationDuration,
      inAnimation: root.inAnimation,
      outAnimation: root.outAnimation,
    );
  }

  final key = GlobalKey(debugLabel: '_GgNavigationPageState');

  // ######################
  // Private
  // ######################

  final List<Function()> _dispose = [];

  // ...........................................................................
  GgNavigationPageRoot _root(BuildContext context) {
    if (widget is GgNavigationPageRoot) {
      return widget as GgNavigationPageRoot; // coverage:ignore-line
    }

    final root = GgNavigationPageRoot.of(context);

    if (root == null) {
      throw ArgumentError(GgNavigationPage.noNavigationPageRootFound);
    }

    return root;
  }

  // ...........................................................................
  GgPageWithNavBar Function(dynamic _) _indexPage(BuildContext context) {
    final content = widget.pageContent(context);
    if (content is GgNavigationPage) {
      throw ArgumentError(GgNavigationPage.indexWidgetMustNotBeANavigationPage);
    }
    GgPageWithNavBar result(_) => GgPageWithNavBar(
      content: content,
      showBackButton: widget.showBackButton,
      showCloseButton: widget.showCloseButton,
    );

    return result;
  }

  // ...........................................................................
  Map<String, WidgetBuilder> _generateChildren(BuildContext context) {
    final Map<String, WidgetBuilder> result = {'_INDEX_': _indexPage(context)};

    widget.children?.forEach((key, value) {
      result[key] = (_) => value;
    });

    return result;
  }

  // ...........................................................................
  void _callOnNavigateToParent() {
    if (!_didNavigateToParent) {
      widget.onNavigateToParent?.call();
      _didNavigateToParent = true;
    }
  }

  // ...........................................................................
  bool _didNavigateToParent = false;

  void _onStagedChildDidChange(GgRouteTreeNode ownNode) {
    // If stagedChild is true, and self is staged, call onNavigateToChild
    if (ownNode.isStaged) {
      _didNavigateToParent = false;
      final stagedChild = ownNode.stagedChild;

      if (stagedChild?.isIndexChild == true || stagedChild == null) {
        widget.onShow?.call();
      } else {
        widget.onNavigateToChild?.call(stagedChild.name);
      }
    } else {
      _callOnNavigateToParent();
    }
  }

  // ...........................................................................
  void _onIsStaged(GgRouteTreeNode ownNode) {
    // If stagedChild is null and isStaged is true, call onShow
    if (ownNode.isStaged && ownNode.stagedChild == null) {
      widget.onShow?.call();
    }

    // If self is not staged, call onNavigateToParent
    if (!ownNode.isStaged) {
      widget.onNavigateToParent?.call();
    }
  }

  // ...........................................................................
  void _listenToRouteChanges() {
    final ownNode = GgRouter.of(context).node;

    // ....................
    // Observe "onIsStaged"
    ownNode.parent?.onIsStaged.listen((isStaged) {
      _onIsStaged(ownNode);
    });
    _onIsStaged(ownNode);

    // ..............................
    // Observe "stagedChildDidChange"
    ownNode.stagedChildDidChange.listen((stagedChild) {
      _onStagedChildDidChange(ownNode);
    });

    _onStagedChildDidChange(ownNode);

    // On dispose, make sure "didNavigateToParent" is called.
    _dispose.add(() {
      _callOnNavigateToParent();
    });
  }
}

// #############################################################################

class GgNavigationPageRoot extends StatefulWidget {
  const GgNavigationPageRoot({
    super.key,
    required this.child,
    this.inAnimation,
    this.outAnimation,
    this.animationDuration = const Duration(milliseconds: 500),
    this.navigationBarBackgroundColor,
    this.navigationBarPadding = 0,
    this.navigationBarBackButton,
    this.navigationBarCloseButton,
    this.navigationBarTitle,
  });

  final Widget child;

  @override
  GgNavigationPageRootState createState() => GgNavigationPageRootState();

  // ...........................................................................
  // The background color of the navigation bar
  final Color? navigationBarBackgroundColor;

  // The padding of the navigation bar
  final double navigationBarPadding;

  // Use this callback to customize the close button appearance
  final Widget Function(BuildContext)? navigationBarCloseButton;

  // Use this callback to customize the back button appearance
  final Widget Function(BuildContext)? navigationBarBackButton;

  // Use this callback to customize the title appearance
  final Widget Function(BuildContext)? navigationBarTitle;

  // ...........................................................................
  /// The duration for route transitions.
  final Duration animationDuration;

  /// This animation is applied to the widget appearing on route transitions.
  final GgAnimationBuilder? inAnimation;

  /// this animation is applied to the widget disappearing on route transitions.
  final GgAnimationBuilder? outAnimation;

  // ...........................................................................
  static GgNavigationPageRoot? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<GgNavigationPageRoot>();
  }
}

class GgNavigationPageRootState extends State<GgNavigationPageRoot> {
  @override
  Widget build(BuildContext context) => widget.child;
}

// #############################################################################
class GgPageWithNavBar extends StatelessWidget {
  const GgPageWithNavBar({
    super.key,
    required this.content,
    this.showBackButton = true,
    this.showCloseButton = true,
  });

  final Widget content;
  final bool showBackButton;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [content, _navigationBar(context)]);
  }

  // ...........................................................................
  Widget _navigationBar(BuildContext context) {
    // Get root navigation page state
    final rootState = context
        .findAncestorStateOfType<GgNavigationPageRootState>();

    final rootPage = GgNavigationPageRoot.of(context)!;

    assert(rootState != null);
    assert(rootState?.context != null);
    final rootNode = GgRouter.of(rootState!.context).node;
    final ownNode = GgRouter.of(context).node;

    // Use context of rootState to get the parent node

    return Container(
      color: rootPage.navigationBarBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(rootPage.navigationBarPadding),
        child: Row(
          children: [
            if (showBackButton)
              MouseRegion(
                key: const ValueKey('GgNavigationPageBackButton'),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTapUp: (_) => ownNode.navigateTo('../'),
                  child:
                      rootPage.navigationBarBackButton?.call(context) ??
                      const Text('Back'),
                ),
              ),
            const Spacer(),
            Container(
              key: const ValueKey('GgNavigationPageTitle'),
              child:
                  rootPage.navigationBarTitle?.call(context) ??
                  Text(ownNode.semanticLabel),
            ),
            const Spacer(),
            if (showCloseButton)
              MouseRegion(
                key: const ValueKey('GgNavigationPageCloseButton'),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  // This behavior might not be wanted:
                  onTapUp: (_) => rootNode.navigateTo('../'),
                  child:
                      rootPage.navigationBarCloseButton?.call(context) ??
                      const Text('Close'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
