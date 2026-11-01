// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'dart:convert';

import 'package:supply_chain/supply_chain.dart';

// #############################################################################
/// An error that is reported when a URI cannot be assigned to a route path
class GgRouteNodeError extends Error {
  // ...........................................................................
  GgRouteNodeError({required this.id, required this.message, this.node});

  // ...........................................................................
  final String message;
  final String id;
  final GgRouteNode? node;

  // ...........................................................................
  GgRouteNodeError withNode(GgRouteNode node) {
    return GgRouteNodeError(id: id, message: message, node: node);
  }

  // ...........................................................................
  @override
  String toString() => 'Error $id: $message';
}

// #############################################################################
/// Calls [task] once per microtask cycle, no matter how often it is triggered
class _Trigger {
  _Trigger(this.task);

  final void Function() task;

  void trigger() {
    if (_isTriggered || _isDisposed) {
      return;
    }
    _isTriggered = true;
    scheduleMicrotask(() {
      _isTriggered = false;
      if (!_isDisposed) {
        task();
      }
    });
  }

  void dispose() => _isDisposed = true;

  bool _isTriggered = false;
  bool _isDisposed = false;
}

// #############################################################################
/// A route parameter. Its value is the product of an input node in the scope
/// of the route.
class GgParam<T> {
  GgParam._({
    required this.name,
    required this.node,
    this.parse,
    this.stringify,
  });

  // ...........................................................................
  /// The name of the parameter
  final String name;

  /// The input node holding the value of the parameter
  final Node<T> node;

  /// Parses a string into the value
  final T Function(String)? parse;

  /// Converts the value into a string
  final String Function(T)? stringify;

  // ...........................................................................
  /// The value of the parameter
  T get value => node.product;

  /// Writes the value into the node
  set value(T value) {
    if (value != node.product) {
      node.product = value;
    }
  }

  // ...........................................................................
  /// Informs about changes of the value, once per supply chain production
  Stream<T> get stream => _stream.stream;

  // ...........................................................................
  /// The value as string
  String get stringValue {
    final v = value;
    if (stringify != null) {
      return stringify!(v);
    } else if (v is String) {
      return v;
    } else if (v is bool) {
      return v ? 'true' : 'false';
    } else if (v is num) {
      return v.toString();
    } else {
      throw ArgumentError(
        'Missing "stringify" method for unknown type "${T.toString()}".',
      );
    }
  }

  /// Parses [str] and writes it into the value
  set stringValue(String str) {
    final v = value;
    if (parse != null) {
      value = parse!(str);
    } else if (v is int) {
      value = int.parse(str) as T;
    } else if (v is double) {
      value = double.parse(str) as T;
    } else if (v is bool) {
      value = _parseBool(str) as T;
    } else if (v is String) {
      value = str as T;
    } else {
      throw ArgumentError(
        'Missing "parse" method for unknown type "${T.toString()}".',
      );
    }
  }

  // ...........................................................................
  /// Values of type bool, num and String as they are, others as string
  dynamic get jsonDecodedValue {
    final v = value;
    return (v is bool || v is num || v is String) ? v : stringValue;
  }

  // ######################
  // Private
  // ######################

  final _stream = StreamController<T>.broadcast();

  late final Node<Object?> _observer;

  void _initObserver() {
    Object? lastValue = value;
    _observer = NodeBluePrint<Object?>(
      key: '${node.key}Observer',
      initialProduct: value,
      suppliers: [node.key],
      produce: (components, previousProduct, _) {
        final v = components.first;
        if (v != lastValue) {
          lastValue = v;
          if (_stream.hasListener) {
            _stream.add(v as T);
          }
        }
        return v;
      },
    ).instantiate(scope: node.scope);

    // Inform without waiting for the next frame
    _observer.ownPriority = Priority.realtime;
  }

  void _dispose() {
    _observer.dispose();
    node.dispose();
    _stream.close();
  }

  static bool _parseBool(String str) {
    switch (str.toLowerCase()) {
      case 'false':
      case '0':
      case 'no':
        return false;
      case 'true':
      case '1':
      case 'yes':
        return true;
      default:
        throw ArgumentError('Cannot parse "$str" as bool.');
    }
  }
}

// #############################################################################
/// Internal management of route parameters
class _Params {
  _Params() {
    _onChangeTrigger = _Trigger(() {
      if (!_onChange.isClosed && _onChange.hasListener) {
        _onChange.add(null);
      }
    });
  }

  // ...........................................................................
  GgParam<T> findOrCreateParam<T>({
    required Scope scope,
    required T seed,
    required dynamic uriParam,
    required String name,
    T Function(String)? parse,
    String Function(T)? stringify,
  }) {
    // Find existing parameter
    var result = _params[name];

    // If param does not already exist, create it.
    if (result == null) {
      final node = _createNode<T>(
        key: GgRouteNode.keyForName(name),
        seed: seed,
        scope: scope,
      )..ownPriority = Priority.realtime;

      final param = GgParam<T>._(
        name: name,
        node: node,
        parse: parse,
        stringify: stringify,
      );

      if (uriParam != null) {
        try {
          if (uriParam is String) {
            param.stringValue = uriParam;
          } else {
            param.value = uriParam as T;
          }
        } catch (e) {
          print('Was not able to write uriParam $uriParam to param $name');
        }
      }

      param._initObserver();
      final s = param.stream.listen((_) => _onChangeTrigger.trigger());
      _dispose.add(s.cancel);
      _onChangeTrigger.trigger();

      _params[name] = param;
      result = param;
    } else {
      _checkType<T>(result);
    }

    // Return existing or created parameter
    return result as GgParam<T>;
  }

  // ...........................................................................
  /// Supply chain nodes need a concrete type. Untyped params get the type of
  /// their seed.
  static Node<T> _createNode<T>({
    required String key,
    required T seed,
    required Scope scope,
  }) {
    if (T != dynamic && T != Object) {
      return NodeBluePrint<T>(
        key: key,
        initialProduct: seed,
      ).instantiate(scope: scope);
    }

    final Node<dynamic> result = switch (seed) {
      bool v => NodeBluePrint<bool>(key: key, initialProduct: v),
      int v => NodeBluePrint<int>(key: key, initialProduct: v),
      double v => NodeBluePrint<double>(key: key, initialProduct: v),
      String v => NodeBluePrint<String>(key: key, initialProduct: v),
      _ => NodeBluePrint<Object?>(key: key, initialProduct: seed),
    }.instantiate(scope: scope);

    return result as Node<T>;
  }

  // ...........................................................................
  void dispose() {
    for (var element in _dispose.reversed) {
      element();
    }
    _dispose.clear();
    for (var element in _params.values) {
      element._dispose();
    }
    _params.clear();
    _onChangeTrigger.dispose();
    _onChange.close();
  }

  // ...........................................................................
  /// Returns own param
  GgParam<T>? param<T>(String name) {
    final result = _params[name];
    if (result != null) {
      _checkType<T>(result);
    }

    return _params[name] as GgParam<T>?;
  }

  // ...........................................................................
  /// Returns true when a param with [name] is available.
  bool hasParam(String name) => _params.keys.contains(name);

  // ...........................................................................
  /// A stream that informs if any of the parameter changes
  Stream<void> get onChange => _onChange.stream;

  // ...........................................................................
  final List<Function()> _dispose = [];

  // ...........................................................................
  void _checkType<T>(GgParam<dynamic> param) {
    if (param is! GgParam<T>) {
      throw ArgumentError(
        'Error while retrieving param with name "${param.name}". '
        'The existing param has type "${param.value.runtimeType.toString()}" and not "${T.toString()}".',
      );
    }
  }

  // ...........................................................................
  final _params = <String, GgParam<dynamic>>{};

  // ...........................................................................
  final _onChange = StreamController<void>.broadcast();
  late _Trigger _onChangeTrigger;
}

// #############################################################################
/// GgRouteNode represents a node in a route tree.
class GgRouteNode {
  // ########################
  // Constructor & Destructor
  // ########################

  /// The node's constructor.
  ///
  /// A root node creates the scope `router` within [scope]. Without [scope]
  /// a new supply chain is created. Child nodes create their scope within
  /// the scope of their parent.
  GgRouteNode({required this.name, this.parent, Scope? scope}) {
    _checkConsistency();
    _initScope(scope);
    _initOnChange();
    _initParent();
    _initParams();
    _initPath();
    _initChildren();
    _initIsStaged();
    _initStagedChild();
    _initOwnOrChildParamChange();
    _initSubscriptions();
    _initPathNode();
  }

  /// Create a root node. Its scope `router` is created within [scope].
  factory GgRouteNode.newRoot({Scope? scope}) =>
      GgRouteNode(name: '_ROOT_', scope: scope);

  // ...........................................................................
  /// Call this function when the node is about to be disposed.
  void dispose() {
    for (var d in _dispose.reversed) {
      d();
    }
    _dispose.clear();
  }

  // ...........................................................................
  /// Returns true, once dispose was called
  bool get isDisposed => _dispose.isEmpty;

  // ...........................................................................
  /// A string representation of the node outputting the path of the node.
  @override
  String toString() {
    return path;
  }

  // ############################
  // Name & Parent & Index & Root
  // ############################

  // ...........................................................................
  /// The name of the node. The name will appear as path segment in the URI.
  final String name;

  /// ..........................................................................
  /// Returns true if name only contains letters, numbers, minus and underscore
  static bool isValidName(String name) {
    return name == '*' || _nameRegEx.allMatches(name).isNotEmpty;
  }

  // ...........................................................................
  /// The parent node.
  final GgRouteNode? parent;

  // ...........................................................................
  ///  The root parent of this node or the node itself, when it is a node.
  GgRouteNode get root {
    var result = this;
    while (result.parent != null) {
      result = result.parent!;
    }

    return result;
  }

  // ...........................................................................
  /// Returns true, if this node is root.
  bool get isRoot => parent == null;

  // ...........................................................................
  /// Returns the index in the parent's children array.
  int? widgetIndex;

  // ############################
  // onChange
  // ############################

  /// Informs about any changes of the node itself as well as its children.
  Stream<void> get onChange => _onChange.stream;

  // ######################
  // isStaged
  // ######################

  // ...........................................................................
  /// Returns true if this node is staged.
  bool get isStaged => _isStaged.product;

  /// ...........................................................................
  /// Sets back staging for the node and it's children
  void resetStaging({bool recursive = false}) {
    _setIsStaged(false);
    if (recursive) {
      for (var child in children) {
        child.resetStaging(recursive: recursive);
      }
    }
  }

  // ######################
  // Children
  // ######################

  // ...........................................................................
  /// Returns the node's children.
  Iterable<GgRouteNode> get children => _children.values;

  // ...........................................................................
  /// Returns a child node with [name]. If none exists, one is created.
  GgRouteNode findOrCreateChild(String name) {
    if (isIndexChild) {
      throw ArgumentError(
        'The route "$path" is an index routes and must not have children.',
      );
    }

    var child = _children[name];
    if (child == null) {
      child = GgRouteNode(name: name, parent: this);
      _children[name] = child;
      _reportChange();
    }
    return child;
  }

  // ...........................................................................
  /// Returns a child node with [name]. If none exists, null is returned
  GgRouteNode? child(String name) => _children[name];

  // ...........................................................................
  /// The default child is chosen, when you want to navigate to _LAST_ and
  /// no child is already staged.
  String? defaultChildName;

  // ...........................................................................
  /// Returns the default child if some exists
  GgRouteNode? get defaultChild =>
      (defaultChildName != null) ? child(defaultChildName!) : null;

  // ...........................................................................
  /// Returns true if the node has a child with [name].
  bool hasChild({required String name}) {
    return _children.containsKey(name);
  }

  // ...........................................................................
  /// Removes the [child].
  void removeChild(GgRouteNode child) {
    if (identical(_children[child.name], child)) {
      _unlistenNode(child);
      child.dispose();
      _reportChange();
    } else {
      throw ArgumentError(
        'The child to be remove is not a child of this node.',
      );
    }
  }

  // ...........................................................................
  bool get isIndexChild => name == '_INDEX_';

  // ...........................................................................
  /// Returns descendant that matches the path. Creates the node when needed.
  /// - `.` addresses node itself
  /// - `..` addresses parent node
  /// - '_LAST_' - addresses child that was last staged or the defaultChild
  GgRouteNode descendants({required List<String> path}) {
    var result = (isIndexChild ? parent : this)!;

    for (var element in path) {
      if (element == '.' || element == '') {
        result = result;
      } else if (element == '..') {
        if (result.parent == null) {
          throw ArgumentError('Invalid path "${path.join('/')}"');
        }
        result = result.parent!;
      } else if (element == '_LAST_') {
        GgRouteNode? stagedChild = result.stagedChild ?? result.defaultChild;

        while (stagedChild != null) {
          result = stagedChild;
          stagedChild = stagedChild.stagedChild ?? result.defaultChild;
        }
      } else {
        result = result.findOrCreateChild(element);
      }
    }

    return result;
  }

  // ...........................................................................
  List<GgRouteNode> get ancestors {
    List<GgRouteNode> result = [];
    GgRouteNode? node = this;
    while (node != null) {
      result.add(node);
      node = node.parent;
    }
    return result;
  }

  // ...........................................................................
  GgRouteNode nodeForPath(String path) {
    return _startElement(path).descendants(path: path.split('/'));
  }

  // ######################
  // Staged child
  // ######################

  // ...........................................................................
  /// Returns the staged child or null if no child is staged.
  GgRouteNode? get stagedChild {
    final name = _stagedChild.product;
    return name == null ? null : _children[name];
  }

  // ...........................................................................
  /// Informs if the staged child did change.
  Stream<GgRouteNode?> get stagedChildDidChange => _stagedChildDidChange.stream;

  // ######################
  // Visible Route
  // ######################

  // ...........................................................................
  /// Returns a list containing all staged descendants.
  List<GgRouteNode> get stagedDescendants {
    GgRouteNode? stagedChild = this.stagedChild;

    final List<GgRouteNode> result = [];
    while (stagedChild != null) {
      result.add(stagedChild);
      stagedChild = stagedChild.stagedChild;
    }

    return result;
  }

  // ...........................................................................
  /// Returns a list containing all staged descendants inkl. the node itself.
  List<GgRouteNode> get stagedDescendantsInklSelf {
    final result = <GgRouteNode>[];
    GgRouteNode? node = this;
    while (node != null) {
      if (node.isStaged) {
        result.add(node);
        node = node.stagedChild;
      } else {
        break;
      }
    }

    return result;
  }

  // ######################
  // Fade in and out
  // ######################

  // ...........................................................................
  /// Returns true if this node needs to be faded in when staged
  /// or faded out when not staged. The value is reset by GgRouterWidget
  /// after the node has been faded in or out.
  bool needsFade = false;

  // ...........................................................................
  /// Returns the child that needs to be faded in
  GgRouteNode? get childToBeFadedIn {
    GgRouteNode? result;
    for (var child in children) {
      if (child.needsFade && child.isStaged) {
        result = child;
      }
    }

    return result;
  }

  // ...........................................................................
  /// Returns the child that needs to be faded out
  GgRouteNode? get childToBeFadedOut {
    GgRouteNode? result;
    for (var child in children) {
      if (child.needsFade && !child.isStaged) {
        result = child;
      }
    }

    return result;
  }

  // ...........................................................................
  /// Returns a stream informing when isStaged changes.
  Stream<bool> get onIsStaged => _onIsStaged.stream;

  // ######################
  // Params
  // ######################

  // ...........................................................................
  /// Finds or route param with [name].
  /// If no param exists, one is created and initialized with [seed].
  /// - [stringify] is used to convert the value of the parameter to string.
  /// - [parse] is used parse a string into the value
  GgParam<T> findOrCreateParam<T>({
    required String name,
    required T seed,
    T Function(String)? parse,
    String Function(T)? stringify,
  }) {
    final es = uriParamForName(name);

    if (hasChild(name: name)) {
      throw GgRouteNodeError(
        id: 'GRC008478',
        message:
            'Error: Cannot create param with name "$name". '
            'There is already a child node with the same name.',
      );
    }

    if (es != null) {
      _removeUriParamForParam(name);
    }

    var result = _params.findOrCreateParam<T>(
      scope: scope,
      seed: seed,
      uriParam: es,
      name: name,
      parse: parse,
      stringify: stringify,
    );

    return result;
  }

  // ...........................................................................
  /// Returns the parameter with [name] or null if no parameter with name exists.
  GgParam<T>? param<T>(String name) => _params.param(name);

  // ...........................................................................
  /// Returns the param from this node or its parents.
  GgParam<T>? ownOrParentParam<T>(String name) {
    GgParam<T>? result;
    GgRouteNode? node = this;
    while (node != null && result == null) {
      result = node.param<T>(name);
      node = node.parent;
    }

    return result;
  }

  // ...........................................................................
  /// Returns all parameters of the staged path.
  Map<String, GgParam<dynamic>> get stagedParams {
    Map<String, GgParam<dynamic>> result = {};
    GgRouteNode? node = this;
    while (node != null) {
      result.addAll(node._params._params);
      node = node.stagedChild;
    }

    return result;
  }

  // ...........................................................................
  /// Returns true if param with [name] exists, otherwise false is returned.
  bool hasParam(String name) => _params.hasParam(name);

  // ...........................................................................
  /// A stream that informs when the node's parameters change.
  Stream<void> get onOwnParamChange => _params.onChange;

  // ...........................................................................
  /// A stream that informs when the node's own or its child parameters change.
  Stream<void> get onOwnOrChildParamChange => _ownOrChildParamChange.stream;

  // ######################
  // Path
  // ######################

  // ...........................................................................
  /// Returns the path of this node as a list of segments.
  late List<String> pathSegments;

  // ...........................................................................
  /// Returns the path of this node as a string.
  late String path;

  // ...........................................................................
  /// Returns the hash of the own path.
  late int pathHashCode;

  // ######################
  // Navigation
  // ######################

  // ...........................................................................
  /// Returns the path of staged children as a list of path segments.
  List<String> get stagedChildPathSegments =>
      stagedDescendants.map((e) => e.name).toList();

  // ...........................................................................
  /// Creates and activates children according to the segments in [path]
  /// - `..` addresses parent node
  /// - `.` addresses node itself
  set stagedChildPathSegments(List<String> path) {
    var node = descendants(path: path);
    if (node.hasChild(name: '_INDEX_')) {
      node = node.child('_INDEX_')!;
    }

    final newStagedNodes = node.ancestors.reversed;
    final oldStagedNodes = root.stagedDescendantsInklSelf;

    bool isFaded = false;
    bool isUnstaged = false;

    // Compare old and new staged nodes
    int index = 0;
    while (true) {
      final newStagedNode = newStagedNodes.length > index
          ? newStagedNodes.elementAt(index)
          : null;

      final oldStagedNode = oldStagedNodes.length > index
          ? oldStagedNodes.elementAt(index)
          : null;

      index++;

      // Break, if no more nodes to be staged or unstaged are available
      if (newStagedNode == null && oldStagedNode == null) {
        break;
      }

      // If the new node was staged before, nothing needs to be done
      bool stagedChildHasChanged = newStagedNode != oldStagedNode;
      if (!stagedChildHasChanged) {
        continue;
      }

      // Only the first staged or unstaged children in the tree are
      // faded.
      if (!isFaded) {
        newStagedNode?.needsFade = true;
        oldStagedNode?.needsFade = true;
      }
      isFaded = true;

      // All new nodes are staged
      newStagedNode?._setIsStaged(true);

      // But only the first unstaged node is unstaged.
      // Thus staging the old node again will restore the children
      if (!isUnstaged) {
        oldStagedNode?._setIsStaged(false);
      }
      isUnstaged = true;
    }

    // Reset staging for the node's children
    node.stagedChild?.resetStaging(recursive: false);
  }

  // ...........................................................................
  String get stagedChildPath {
    final result = stagedChildPathSegments;
    if (result.isNotEmpty && result.last == '_INDEX_') {
      result.remove('_INDEX_');
    }

    return result.join('/');
  }

  // ...........................................................................
  /// Activates the path in the node hierarchy.
  /// - [path] can be absolute, e.g. `/a/b/c`
  /// - [path] can be relative, e.g. `b/c` or `./b/c`
  /// - [path] can address parent element, e.g. `../`
  /// - [path] can address root, e.g. `/`
  void navigateTo(String path) => _navigateTo(path);

  // ######################
  // Uri parameters
  // ######################

  /// Use [uriParams] to apply parameters taken from a URI to the staged tree.
  /// These parameters are used to initialize node parameters.
  Map<String, dynamic> uriParams = {};

  // ...........................................................................
  /// Returns the URI parameter for a given parameter [name].
  /// Returns null, if no URI parameter exists for that name.
  dynamic uriParamForName(String name) {
    GgRouteNode? node = this;
    dynamic seed;
    while (node != null && seed == null) {
      seed = node.uriParams[name];
      node = node.parent;
    }

    return seed;
  }

  // ######################
  // Error Handling
  // ######################

  // ...........................................................................
  /// Handle error or propagate it up the tree.
  void setError(GgRouteNodeError error) {
    final err = error.node == null ? error.withNode(this) : error;
    _errorHandler?.call(err);
    if (_errorHandler == null) {
      if (parent != null) {
        parent?.setError(err);
      } else {
        throw Exception(
          '$err \n'
          'Please set an error handler using "node.errorHandler = ...", to capture routing errors.',
        );
      }
    }
  }

  // ...........................................................................
  /// Set an [errorHandler] which informs about errors. E.g., if a URI cannot be
  /// applied to the node tree, this error handler will be called.
  /// You can set an error handler only one time.
  set errorHandler(void Function(GgRouteNodeError)? errorHandler) {
    if (errorHandler != null && _errorHandler != null) {
      throw ArgumentError(
        'This node already has an error handler. Please remove previous error handler.',
      );
    }

    _errorHandler = errorHandler;
  }

  // ...........................................................................
  /// Returns the error handler.
  void Function(GgRouteNodeError)? get errorHandler => _errorHandler;

  // ######################
  // JSON handling
  // ######################

  // ...........................................................................
  /// This key is used to store the staged child name to JSON
  static const stagedChildJsonKey = '__stagedChild';
  static const semanticLabelJsonKey = '__semanticLabel';

  // ...........................................................................
  /// Reads the JSON string and creates routes and  parameters. Parameters that
  /// are not still existing in the route tree are safed in the right nodes for
  /// later use.
  set json(String json) {
    parseJson(json: json, parseAllParamsDirectly: false);
  }

  // ...........................................................................
  /// Reads the JSON string and creates routes and  parameters. Parameters that
  /// are not still existing in the route tree are safed in the right nodes for
  /// later use, but only if parseAllParamsDirectly is false.
  void parseJson({required String json, parseAllParamsDirectly = false}) {
    late Object object;
    try {
      object = jsonDecode(json);
    } catch (e) {
      throw GgRouteNodeError(
        id: 'GRC008475',
        message: 'Error while decoding JSON: $e',
      );
    }

    _parseJson(object, parseAllParamsDirectly);
  }

  // ...........................................................................
  /// Converts the route tree into a JSON string
  String get json {
    final json = _generateJson();
    return jsonEncode(json);
  }

  // ######################
  // Semantics
  // ######################

  // ...........................................................................
  /// Assigns a semantic label to the node
  set semanticLabel(String label) {
    _semanticLabel = label;
  }

  // ...........................................................................
  /// Returns the semantic label of the node or the node when none has
  /// been set.
  String get semanticLabel {
    return _semanticLabel ?? (name == '_INDEX_' ? parent!.semanticLabel : name);
  }

  // ...........................................................................
  String semanticLabelForPath(String path) {
    final node = nodeForPath(path);
    return node.semanticLabel;
  }

  // ...........................................................................
  void setSemanticLabelForPath({required String path, required String label}) {
    final node = nodeForPath(path);
    node.semanticLabel = label;
  }

  // ######################
  // Supply chain
  // ######################

  // ...........................................................................
  /// The scope holding the state of this route. The root route owns the scope
  /// `router`, each child route a child scope named after the route.
  late final Scope scope;

  // ...........................................................................
  /// The input node of the root route holding the staged path, e.g.
  /// `/settings/sounds`. Write it to navigate, read it to observe the
  /// navigation.
  Node<String> get pathNode => root._pathNode!;

  // ...........................................................................
  /// Returns the key of the scope or node representing [name].
  ///
  /// Lower camel case names are kept, unless they are used by the router
  /// itself (`isStaged`, `stagedChild`, `path`, `...Observer`). `_INDEX_`
  /// becomes `§index`, `*` becomes `§any`. Other names are encoded as `§r`
  /// followed by their character codes.
  static String keyForName(String name) {
    // Names ending with "Observer" would collide with the observer nodes
    final isReserved =
        _reservedKeys.contains(name) || name.endsWith('Observer');
    if (name.isCamelCase && !isReserved) {
      return name;
    }
    if (name == '_INDEX_') {
      return '§index';
    }
    if (name == '*') {
      return '§any';
    }
    final codes = name.codeUnits
        .map((c) => c.toRadixString(36).padLeft(2, '0'))
        .join();
    return '§r$codes';
  }

  // ######################
  // Private
  // ######################

  final List<Function()> _dispose = [];

  static const _reservedKeys = {'isStaged', 'stagedChild', 'path'};

  // ...........................................................................
  void _initScope(Scope? parentScope) {
    if (parent != null) {
      scope = ScopeBluePrint(key: keyForName(name))
          .instantiate(scope: parent!.scope);
    } else {
      final parent = parentScope ?? Scope.root(key: 'root', scm: _defaultScm());
      scope = const ScopeBluePrint(key: 'router').instantiate(scope: parent);
    }

    _dispose.add(scope.dispose);
  }

  // ...........................................................................
  /// The supply chain manager of a router created without a scope. The route
  /// nodes produce trivially, so no production timeout is needed.
  static Scm _defaultScm() => Scm()..shouldTimeOut = false;

  // ...........................................................................
  Node<String>? _pathNode;
  Node<String>? _pathObserver;

  void _initPathNode() {
    if (!isRoot) {
      return;
    }

    _pathNode = const NodeBluePrint<String>(
      key: 'path',
      initialProduct: '/',
    ).instantiate(scope: scope)..ownPriority = Priority.realtime;

    // Navigate when the path node is written from outside
    _pathObserver = NodeBluePrint<String>(
      key: 'pathObserver',
      initialProduct: '/',
      suppliers: ['path'],
      produce: (components, previousProduct, _) {
        final path = components.first as String;
        if (path != _stagedPath) {
          navigateTo(path);
        }
        return path;
      },
    ).instantiate(scope: scope);

    // Navigate without waiting for the next frame
    _pathObserver!.ownPriority = Priority.realtime;

    _dispose.add(() {
      _pathObserver?.dispose();
      _pathNode?.dispose();
    });
  }

  // ...........................................................................
  String get _stagedPath => '/$stagedChildPath';

  // ...........................................................................
  void _writePath() {
    final pathNode = _pathNode;
    if (pathNode == null || pathNode.isDisposed) {
      return;
    }

    final path = _stagedPath;
    if (pathNode.product != path) {
      pathNode.product = path;
    }
  }

  static final _nameRegEx = RegExp(
    r'^[\w\d_-]+$',
    caseSensitive: false,
    multiLine: false,
  );

  // ########
  // Checks
  void _checkConsistency() {
    if (isRoot && name != '_ROOT_') {
      throw GgRouteNodeError(
        id: 'GRC008501',
        message: 'Root nodes must have name "_ROOT_".',
      );
    }

    if (name == '_ROOT_' && parent != null) {
      throw GgRouteNodeError(
        id: 'GRC008503',
        message: 'Nodes with name "_ROOT_" are root nodes and must not have a parent.',
      );
    }

    if (!isValidName(name)) {
      throw GgRouteNodeError(
        id: 'GRC008502',
        message:
            'The name "$name" is not a valid node name. Node names must only contain letters, numbers, underscore or minus.',
      );
    }
  }

  // ########
  // parent
  void _initParent() {
    parent?._children[name] = this;
    parent?._listenToNode(this);
  }

  // ...........................................................................
  void _initPath() {
    pathSegments = parent == null
        ? []
        : [...parent!.pathSegments, if (name.isNotEmpty) name];
    path = '/${pathSegments.join('/')}';
    pathHashCode = path.hashCode;
  }

  // ########
  // children

  // ...........................................................................
  /// Returns a list with the node's children.
  final _children = <String, GgRouteNode>{};
  void _initChildren() {
    _dispose.add(() {
      for (var child in List.from(_children.values)) {
        child.dispose();
      }
      parent?._removeChild(this);
    });
  }

  // ...........................................................................
  void _removeChild(GgRouteNode child) {
    _children.remove(child.name);
  }

  // ########
  // params

  // ...........................................................................
  final _params = _Params();
  void _initParams() {
    _dispose.add(() => _params.dispose());

    // Inform about parameter changes
    final s = _params.onChange.listen((event) {
      _reportChange();
    });
    _dispose.add(s.cancel);
  }

  // ...........................................................................
  final _ownOrChildParamChange = StreamController<void>.broadcast();
  late _Trigger _triggerOwnOrChildParamChange;

  void _initOwnOrChildParamChange() {
    _dispose.add(() => _ownOrChildParamChange.close());

    _triggerOwnOrChildParamChange = _Trigger(() {
      if (!_ownOrChildParamChange.isClosed &&
          _ownOrChildParamChange.hasListener) {
        _ownOrChildParamChange.add(null);
      }
    });
    _dispose.add(_triggerOwnOrChildParamChange.dispose);

    final s = onOwnParamChange.listen(
      (_) => _triggerOwnOrChildParamChange.trigger(),
    );
    _dispose.add(s.cancel);
  }

  // ...........................................................................
  final Map<GgRouteNode, StreamSubscription> _subscriptions = {};
  void _initSubscriptions() {
    _dispose.add(() {
      for (var element in _subscriptions.values) {
        element.cancel();
      }
    });
  }

  // ...........................................................................
  void _listenToNode(GgRouteNode node) {
    _subscriptions[node] = node.onOwnOrChildParamChange.listen(
      (event) => _triggerOwnOrChildParamChange.trigger(),
    );
  }

  // ...........................................................................
  void _unlistenNode(GgRouteNode node) {
    _subscriptions[node]!.cancel();
    _subscriptions.remove(node);
  }

  // # URI Params

  // ...........................................................................
  String? _removeUriParamForParam(String name) {
    // Early seed is only used the first time
    GgRouteNode? node = this;
    String? seed;
    while (node != null && seed == null) {
      if (node.uriParams.containsKey(name)) {
        node.uriParams.remove(name);
      }
      seed = node.uriParams[name];
      node = node.parent;
    }

    return seed;
  }

  // ########
  // onChange

  // ...........................................................................
  final _onChange = StreamController<void>.broadcast();
  late _Trigger _onChangeTrigger;

  // ...........................................................................
  void _initOnChange() {
    _dispose.add(_onChange.close);
    _onChangeTrigger = _Trigger(() {
      if (_onChange.hasListener) {
        _onChange.add(null);
        parent?._reportChange();
      }
    });
    _dispose.add(_onChangeTrigger.dispose);
  }

  // ...........................................................................
  void _reportChange() {
    _onChangeTrigger.trigger();
    parent?._reportChange();
  }

  // ########
  // isStaged

  // ...........................................................................
  late final Node<bool> _isStaged;
  final _onIsStaged = StreamController<bool>.broadcast();
  late _Trigger _onIsStagedTrigger;

  // ...........................................................................
  void _initIsStaged() {
    _isStaged = const NodeBluePrint<bool>(
      key: 'isStaged',
      initialProduct: false,
    ).instantiate(scope: scope)..ownPriority = Priority.realtime;

    _onIsStagedTrigger = _Trigger(() {
      if (_onIsStaged.hasListener) {
        _onIsStaged.add(isStaged);
      }
    });

    _dispose.add(() {
      if (isStaged) {
        _setIsStaged(false);
      }
    });
    _dispose.add(() {
      _onIsStagedTrigger.dispose();
      _onIsStaged.close();
    });
  }

  // ...........................................................................
  void _setIsStaged(bool b) {
    if (_isStaged.product != b) {
      _isStaged.product = b;
      _onIsStagedTrigger.trigger();
    }

    if (b && parent?.stagedChild != this) {
      parent?._setStagedChild(this);
    } else if (!b && parent?.stagedChild == this) {
      parent?._setStagedChild(null);
    }

    _reportChange();
    root._writePath();
  }

  // ###########
  // stagedChild
  // ...........................................................................
  late final Node<String?> _stagedChild;
  final _stagedChildDidChange = StreamController<GgRouteNode?>.broadcast();
  late _Trigger _stagedChildDidChangeTrigger;

  void _initStagedChild() {
    _stagedChild = const NodeBluePrint<String?>(
      key: 'stagedChild',
      initialProduct: null,
    ).instantiate(scope: scope)..ownPriority = Priority.realtime;

    _stagedChildDidChangeTrigger = _Trigger(() {
      if (_stagedChildDidChange.hasListener) {
        _stagedChildDidChange.add(stagedChild);
      }
    });

    _dispose.add(() {
      _stagedChildDidChangeTrigger.dispose();
      _stagedChildDidChange.close();

      if (parent?.stagedChild == this) {
        parent?._setStagedChild(null);
      }
    });
  }

  // ...........................................................................
  void _setStagedChild(GgRouteNode? child) {
    if (_stagedChild.product == child?.name) {
      return;
    }
    _stagedChild.product = child?.name;
    _stagedChildDidChangeTrigger.trigger();
    _reportChange();
  }

  // ################
  // navigate

  // ...........................................................................
  GgRouteNode _startElement(String path) {
    final startElement = path.startsWith('/') ? root : this;
    return startElement;
  }

  // ...........................................................................
  void _navigateTo(String path) {
    path = path.replaceAll('_INDEX_/', '').replaceAll('/_INDEX_', '');

    final pathComponents = path == '/' ? <String>[] : path.split('/');

    // route/_INDEX_ is treated as route/ when navigating
    if (isIndexChild) {
      parent!._navigateTo(path);
    } else {
      _startElement(path).stagedChildPathSegments = pathComponents;
    }
  }

  // ##############
  // Error handling

  Function(GgRouteNodeError)? _errorHandler;

  // ##############
  // JSON handling

  // ...........................................................................
  void _parseJson(Object json, bool parseAllParamsDirectly) {
    if (json is Map) {
      final map = json as Map<String, dynamic>;
      map.forEach((key, value) {
        // ......................................
        // Read children.
        // If the value is a map, create a child.
        if (value is Map) {
          findOrCreateChild(key)._parseJson(value, parseAllParamsDirectly);
        } else {
          // .................
          // Read staged child
          if (key == stagedChildJsonKey) {
            final childNode = findOrCreateChild(value);
            childNode._setIsStaged(true);
            _setStagedChild(childNode);
          }

          // ...................
          // Read semantic label
          if (key == semanticLabelJsonKey) {
            _semanticLabel = value;
          }

          // ...........
          // Read params
          // If an param exists, parse the value into the param
          try {
            if (hasParam(key)) {
              if (value is num || value is bool) {
                param(key)!.value = value;
              } else {
                param(key)!.stringValue = value;
              }
            } else if (parseAllParamsDirectly) {
              if (value is bool) {
                findOrCreateParam<bool>(name: key, seed: value);
              } else if (value is num) {
                findOrCreateParam<num>(name: key, seed: value);
              } else {
                findOrCreateParam<String>(name: key, seed: value);
              }
            } else {
              uriParams[key] = value;
            }
          } catch (e) {
            throw GgRouteNodeError(
              id: 'GRC008477',
              message:
                  'Error while parsing value "$value" for attribute with name "$key" on path "$path": $e',
            );
          }
        }
      });
    } else {
      throw GgRouteNodeError(
        id: 'GRC008476',
        message:
            'Error while reading JSON path "$path". Expected object of type Map, but got ${json.runtimeType}.',
        node: this,
      );
    }
  }

  // ...........................................................................
  Object _generateJson() {
    final result = {};

    // Write staged child
    if (_stagedChild.product != null) {
      result[stagedChildJsonKey] = _stagedChild.product;
    }

    // Write semantic labels
    if (_semanticLabel != null) {
      result[semanticLabelJsonKey] = _semanticLabel;
    }

    // Write parameters
    _params._params.forEach((name, value) {
      result[name] = value.jsonDecodedValue;
    });

    // Write children
    _children.forEach((name, child) {
      result[name] = child._generateJson();
    });
    return result;
  }

  // #########
  // Semantics

  String? _semanticLabel;

  // ...........................................................................
}

// #############################################################################
/// Creates an lite route sample node.
GgRouteNode exampleRouteNode({String? name, GgRouteNode? parent}) =>
    GgRouteNode(name: name ?? '_ROOT_', parent: parent);
