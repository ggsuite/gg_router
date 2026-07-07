// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import '../gg_router.dart';
import 'package:gg_value/gg_value.dart';

// #############################################################################
/// A callback GgRouter uses to animate appearing and disappearing widgets.
/// - [animation] The ongoing animation.
/// - [child] The child to appear or disappear.
/// - [size] The size of the enclosing widget.
typedef GgAnimationBuilder =
    Widget Function(
      BuildContext context,
      Animation animation,
      Widget child,
      Size size,
    );

// #############################################################################
/// During animation, wrap widgets into GgShowInForeground to have a widget
/// shown on the top
class GgShowInForeground extends StatelessWidget {
  const GgShowInForeground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(child: child);
  }
}

// #############################################################################
class GgRouterCore extends StatelessWidget {
  const GgRouterCore({super.key, required this.child, required this.node});
  // ...........................................................................
  final Widget child;
  final GgRouteTreeNode node;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return child;
  }

  // ...........................................................................
  /// Activates the path in the node hierarchy.
  /// - [path] can be absolute, e.g. `/a/b/c`
  /// - [path] can be relative, e.g. `b/c` or `./b/c`
  /// - [path] can address parent element, e.g. `../`
  /// - [path] can address root, e.g. `/`
  void navigateTo(String path) {
    node.navigateTo(path);
  }

  // ...........................................................................
  /// Returns the semantic label for a given path
  String semanticLabelForPath(String path) {
    return node.semanticLabelForPath(path);
  }

  // ...........................................................................
  /// Returns the semantic label for a given path
  void setSemanticLabelForPath({required String path, required String label}) {
    return node.setSemanticLabelForPath(path: path, label: label);
  }

  // ...........................................................................
  /// Returns the name of the route, this [GgRouter] instance is assigned.
  /// Returns null if the route doesn't have a name.
  String? get routeName {
    return node.name;
  }

  // ...........................................................................
  /// Returns the name of the visible child route.
  /// Returns null if no child is visible.
  String? get routeNameOfActiveChild {
    return node.stagedChild?.name;
  }

  // ...........................................................................
  /// Returns the index of the visible child.
  /// Returns null, if no child is visible.
  /// You can use that index to highlight the right entry in a menu for example.
  int? get indexOfActiveChild {
    return node.stagedChild?.widgetIndex;
  }

  // ######################
  // Animating children
  // ######################

  // ...........................................................................
  /// Returns the child's index currently fading out, or null, if no child is
  /// now fading.
  int? get indexOfChildAnimatingOut {
    return node.childToBeFadedOut?.widgetIndex;
  }

  // ...........................................................................
  /// Returns the child's name currently fading out, or null, if no child is
  /// now fading.
  String? get nameOfChildAnimatingOut {
    return node.childToBeFadedOut?.name;
  }

  // ...........................................................................
  /// Returns the child's index currently fading in, or null, if no child is
  /// now fading.
  int? get indexOfChildAnimatingIn {
    return node.childToBeFadedIn?.widgetIndex;
  }

  // ...........................................................................
  /// Returns the child's name currently fading in, or null, if no child is
  /// now fading.
  String? get nameOfChildAnimatingIn {
    return node.childToBeFadedIn?.name;
  }

  // ######################
  // Route path
  // ######################

  // ...........................................................................
  /// Returns the path of this [GgRouter] instance.
  String get routePath {
    return node.path;
  }

  // ...........................................................................
  /// Use this stream to be informed when the visible child changes.
  Stream<void> get onActiveChildChange {
    return node.stagedChildDidChange;
  }

  // ...........................................................................
  /// Use this method to change the param with [name] or to listen to changes.
  GgValue? param(String name) => node.ownOrParentParam(name);
}

// #############################################################################
/// Use [GgRouter] to connect your widget hierarchy with a nested route tree.
class GgRouter extends StatefulWidget {
  // ...........................................................................
  /// Constructor, which takes a map of child routes. Depending on the currently
  /// selected routed one of the child routes is shown.
  ///
  /// To animate widgets when switching a route, specify an [inAnimation] and
  /// an [outAnimation]. The first is applied to the widget appearing on
  /// the screen. The second is applied to the one disappearing.
  /// ```
  /// GgRouter({
  ///   '_INDEX_': (context) => Text('The index screen'),
  ///   'green':   (context) => Container(color: Colors.green),
  ///   'yellow':  (context) => Container(color: Colors.red),
  ///   'red':     (context) => Container(color: Colors.red),
  /// })
  /// ```
  GgRouter(
    this.children, {
    required Key key,
    this.semanticLabels = const {},
    this.defaultRoute,
    this.inAnimation,
    this.outAnimation,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : _rootChild = null,
       _rootNode = null,
       super(key: key) {
    _checkChildren();
    _checkAnimations();
    _checkSemanticLabels();
  }

  // ...........................................................................
  /// This method is called by [GgRouterDelegate] to create the root instance.
  const GgRouter.root({
    super.key,
    required Widget child,
    required GgRouteTreeNode node,
  }) : _rootChild = child,
       _rootNode = node,
       children = const {},
       semanticLabels = const {},
       defaultRoute = null,
       inAnimation = null,
       outAnimation = null,
       animationDuration = const Duration(milliseconds: 500);

  // ...........................................................................
  /// Copies a router object and allows to replace single properties.
  GgRouter.from(
    GgRouter other, {
    Key? key,
    Map<String, String>? semanticLabels,
    String? defaultRoute,
    Map<String, Widget Function(BuildContext)>? children,
    GgAnimationBuilder? inAnimation,
    GgAnimationBuilder? outAnimation,
    Duration? animationDuration,
  }) : children = children ?? other.children,
       semanticLabels = semanticLabels ?? other.semanticLabels,
       defaultRoute = defaultRoute ?? other.defaultRoute,
       inAnimation = inAnimation ?? other.inAnimation,
       outAnimation = outAnimation ?? other.outAnimation,
       animationDuration = animationDuration ?? other.animationDuration,
       _rootChild = other._rootChild,
       _rootNode = other._rootNode,
       super(key: key ?? other.key);

  // ...........................................................................
  /// The duration for route transitions.
  final Duration animationDuration;

  /// The child routes of this router.
  final Map<String, Widget Function(BuildContext)> children;

  /// A map assigning a semantic label to each route.
  final Map<String, String> semanticLabels;

  /// This animation is applied to the widget appearing on route transitions.
  final GgAnimationBuilder? inAnimation;

  /// this animation is applied to the widget disappearing on route transitions.
  final GgAnimationBuilder? outAnimation;

  /// The default route that is activated, if one navigates to _LAST_ and
  /// no child route was staged before.
  final String? defaultRoute;

  // ...........................................................................
  @override
  GgRouterState createState() => GgRouterState();

  // ...........................................................................
  /// This error message is thrown when you forget to instaniate a
  /// [GgRouterDelegate] before instantiating a GgRouter.
  static const noGgRouterDelegateFoundError =
      'Did not find an instance of GgRouterDelegate.\n'
      'Please wrap your GgRouter into a MaterialApp.router(...) and '
      'assign an instance of GgRouterDelegate to "routerDelegate".\n'
      'When testing, it is sufficient to wrap the GgRouter under test into '
      'another GgRouter.root instance.\n'
      'For more details look into "gg_router/example/main.dart".';

  // ...........................................................................
  /// Returns the next [GgRouterState] instance in the widget tree.
  static GgRouterCore of(BuildContext context, {bool rootRouter = false}) {
    GgRouterCore? core = context.findAncestorWidgetOfExactType<GgRouterCore>();

    if (rootRouter) {
      final rootRouterState = context
          .findRootAncestorStateOfType<GgRouterState>()!;

      core = rootRouterState.rootRouterCore;
    }

    assert(() {
      if (core == null) {
        throw FlutterError(noGgRouterDelegateFoundError);
      }
      return true;
    }());
    return core!;
  }

  // ######################
  // Private
  // ######################

  // ...........................................................................
  bool get _isRoot => _rootChild != null;
  final Widget? _rootChild;
  final GgRouteTreeNode? _rootNode;

  void _checkAnimations() {
    final inAnimationIsDefined = inAnimation != null;
    final outAnimationIsDefined = outAnimation != null;
    if (inAnimationIsDefined != outAnimationIsDefined) {
      throw ArgumentError(''); // coverage:ignore-line
    }
  }

  // ...........................................................................
  void _checkChildren() {
    for (var name in children.keys) {
      if (!GgRouteTreeNode.isValidName(name)) {
        // coverage:ignore-start
        throw ArgumentError('The name "$name" is not a valid route name.');
        // coverage:ignore-end
      }
    }
  }

  // ...........................................................................
  void _checkSemanticLabels() {
    for (var key in semanticLabels.keys) {
      if (!children.containsKey(key)) {
        throw ArgumentError(
          'You specified a semantic label for route "$key", but you did not setup a route with name "$key".',
        );
      }
    }
  }

  // ...........................................................................
}

// #############################################################################
class GgRouterState extends State<GgRouter> with TickerProviderStateMixin {
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
  initState() {
    _initParentNode();
    _initAnimation();
    _observeVisibleNode();
    _initRootRouterCore();
    super.initState();
  }

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    _updateTree();

    final b = widget._isRoot ? _buildRoot : _buildNonRoot;
    return b(context);
  }

  // ######################
  // Private
  // ######################

  // ...........................................................................
  final List<Function()> _dispose = [];

  // ...........................................................................
  GgRouteTreeNode? _previousVisibleNode;
  GgRouteTreeNode? _stagedNode;
  GgRouteTreeNode? _nodeToBeFadedIn;
  GgRouteTreeNode? _nodeToBeFadedOut;

  late GgRouteTreeNode _parentNode;
  void _initParentNode() {
    if (!widget._isRoot) {
      _parentNode = GgRouter.of(context).node;
    }
  }

  // ...........................................................................
  void _observeVisibleNode() {
    // .........................................................................
    // If widget is a root widget, the root node will always be the visible node.
    if (widget._isRoot) {
      _previousVisibleNode = null;
      _stagedNode = widget._rootNode;
      return;
    }

    // Update route tree
    _updateTree();

    // ........................
    // Observe the visible child
    final s = _parentNode.stagedChildDidChange.listen((_) {
      _updateStagedChild();
    });

    _updateStagedChild(isFirstTime: true);

    _dispose.add(s.cancel);
  }

  // ...........................................................................
  void _updateStagedChild({bool isFirstTime = false}) {
    // Let's get the visible child
    GgRouteTreeNode? newVisibleNode = _parentNode.stagedChild;

    // ........................
    // Update the child indexes
    int i = 0;
    for (var key in widget.children.keys) {
      final child = _parentNode.findOrCreateChild(key);
      child.widgetIndex = i;
      i++;
    }

    // .......................................................
    // Check if a widget is available for the new visible node
    final routeExists = widget.children.keys.contains;
    bool routeIsValid =
        newVisibleNode == null ||
        routeExists(newVisibleNode.name) ||
        routeExists('*');

    // If no widget is available
    if (!routeIsValid) {
      // Show an error message
      final invalidNode = newVisibleNode;
      _parentNode.setError(
        GgRouteTreeNodeError(
          id: 'GRC008448',
          message:
              'Route "${_parentNode.path}" has no child named "${invalidNode.name}" nor does your GgRouter define a "*" wild card route.',
        ),
      );

      // Remove the node from the node tree
      _parentNode.removeChild(invalidNode);

      // Show the previous visible node
      newVisibleNode = _previousVisibleNode;
      newVisibleNode?.navigateTo('.');
      // _previousVisibleNode?.navigateTo('.');
    }

    // ...................................................
    // If no visible child is defined, take the index route
    newVisibleNode ??= widget.children.containsKey('_INDEX_')
        ? _parentNode.findOrCreateChild('_INDEX_')
        : null;

    // ...................................................
    // If no index child is defined, take the default route
    if (newVisibleNode == null && widget.defaultRoute != null) {
      newVisibleNode = widget.children.containsKey(widget.defaultRoute)
          ? _parentNode.findOrCreateChild(widget.defaultRoute!)
          : null;
      newVisibleNode?.navigateTo('.');
    }

    // ............................................................
    // If no visible child is defined and no index route is defined,
    // create an error and show the previous visible node.
    if (newVisibleNode == null) {
      _parentNode.setError(
        GgRouteTreeNodeError(
          id: 'GRC008505',
          message:
              'Route "${_parentNode.path}" has no "_INDEX_" route and also no defaultRoute set. It cannot be displayed.',
        ),
      );

      newVisibleNode = _previousVisibleNode;
    }

    // ...................
    // Configure animation
    if (_animation.isCompleted || _animation.isDismissed) {
      _animation.forward();

      _animationStatusListener = (AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _nodeToBeFadedIn?.needsFade = false;
          _nodeToBeFadedOut?.needsFade = false;
          _nodeToBeFadedIn = null;
          _nodeToBeFadedOut = null;
          _animation.removeStatusListener(_animationStatusListener);
          _animation.reset();
        }
      };

      _animation.addStatusListener(_animationStatusListener);
    }

    // .............................
    // Activate the node to be shown
    setState(() {
      _previousVisibleNode = newVisibleNode;
      _stagedNode = newVisibleNode;
      _nodeToBeFadedIn = _parentNode.childToBeFadedIn;
      _nodeToBeFadedOut = _parentNode.childToBeFadedOut;
    });
  }

  // ...........................................................................
  GgRouterCore? rootRouterCore;

  // ...........................................................................
  void _initRootRouterCore() {
    if (widget._isRoot) {
      rootRouterCore = GgRouterCore(
        child: widget._rootChild!,
        node: widget._rootNode!,
      );
    }
  }

  // ...........................................................................
  Widget _buildRoot(BuildContext context) {
    return rootRouterCore!;
  }

  // ...........................................................................
  Widget _buildNonRoot(BuildContext context) {
    // ...............................
    // Estimate if animation is needed
    bool animateIn = widget.inAnimation != null && _nodeToBeFadedIn != null;
    bool animateOut = widget.outAnimation != null && _nodeToBeFadedOut != null;

    // ...................................
    // If animation is needed show a stack
    if (animateIn || animateOut) {
      return _animate();
    }
    // .......................................................
    // If no animation is needed, just show the staying widget
    else {
      final child = _content(_stagedNode);

      return _stagedNode != null
          ? GgRouterCore(
              child: Builder(
                builder: (ctx) {
                  return child?.call(ctx) ?? Container();
                },
              ),
              node: _stagedNode!,
            )
          : Container();
    }
  }

  // ...........................................................................
  WidgetBuilder? _content(GgRouteTreeNode? node) {
    // If a widget is defined for the name of the node, take that widget.
    // Otherwise take the wild card route.
    final nodeName = node == null
        ? null
        : widget.children.containsKey(node.name)
        ? node.name
        : '*';

    return nodeName == null ? null : widget.children[nodeName];
  }

  // ...........................................................................
  Widget _animate() {
    return LayoutBuilder(
      builder: (context, layout) {
        final size = Size(layout.maxWidth, layout.maxHeight);

        // .....................................
        // Show the widget belonging to the node
        final childToFadeIn = _content(_nodeToBeFadedIn);
        final childToFadeOut = _content(_nodeToBeFadedOut);

        final stayingWidget = childToFadeIn != null
            ? null
            // coverage:ignore-start
            : (BuildContext context) => GgRouterCore(
                child: Builder(
                  builder: (context) =>
                      widget.children[_stagedNode!.name]?.call(context) ??
                      Container(),
                ),
                node: _stagedNode!,
              );
        // coverage:ignore-end

        // .............
        // Animation in

        final childIn = childToFadeOut == null
            ? null
            : GgRouterCore(
                child: childToFadeIn!(context),
                node: _nodeToBeFadedIn!,
              );

        final inWidget = childIn == null
            ? null
            : () =>
                  widget.inAnimation!.call(context, _animation, childIn, size);

        // .............
        // Animation out

        final childOut = childToFadeOut == null
            ? null
            : GgRouterCore(
                child: childToFadeOut(context),
                node: _nodeToBeFadedOut!,
              );

        final outWidget = childOut == null
            ? null
            : () => widget.outAnimation!.call(
                context,
                _animation,
                childOut,
                size,
              );

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, widget) {
            // By default outWidget is shown in the background
            // In widget is shown in the foreground
            final stack = [
              if (outWidget != null) outWidget(),
              if (inWidget != null) inWidget(),
              // coverage:ignore-start
              if (stayingWidget != null) stayingWidget(context),
              // coverage:ignore-end
            ];

            // But if a widget is wrapped into GgShowInForeground
            // the widget is always put to foreground
            stack.sort((a, b) {
              final showAOnTop = a is GgShowInForeground;
              final showBOnTop = b is GgShowInForeground;

              if (showAOnTop == showBOnTop) {
                return 0;
              } else if (showAOnTop) {
                return 1;
              } else {
                return -1;
              }
            });

            return ClipRect(
              clipBehavior: Clip.hardEdge,
              child: Stack(children: stack),
            );
          },
        );
      },
    );
  }

  // ...........................................................................
  void _initAnimation() {
    _animation = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    listner(status) {
      setState(() {});
    }

    _animation.addStatusListener(listner);
    _dispose.add(() => _animation.removeStatusListener(listner));
    _dispose.add(_animation.dispose);
  }

  // ...........................................................................
  void _updateTree() {
    if (widget._isRoot) {
      return;
    }
    final parentNode = _parentNode;
    _createChildNodes(parentNode);
    _setupDefaultChild(parentNode);
    _setupSemanticLabels(parentNode);
  }

  // ...........................................................................
  void _createChildNodes(GgRouteTreeNode parentNode) {
    for (var routeName in widget.children.keys) {
      parentNode.findOrCreateChild(routeName);
    }
  }

  // ...........................................................................
  void _setupDefaultChild(GgRouteTreeNode parentNode) {
    if (widget.defaultRoute != null) {
      if (!widget.children.containsKey(widget.defaultRoute)) {
        throw ArgumentError(
          'Error GRC008506: The defaultChild "${widget.defaultRoute}" does not exist.',
        );
      }
    }

    parentNode.defaultChildName = widget.defaultRoute;
  }

  // ...........................................................................
  void _setupSemanticLabels(GgRouteTreeNode parentNode) {
    widget.semanticLabels.forEach((key, value) {
      parentNode.findOrCreateChild(key).semanticLabel = value;
    });
  }

  late AnimationController _animation;
  late Function(AnimationStatus) _animationStatusListener;
}
