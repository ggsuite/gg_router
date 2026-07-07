// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import '../gg_router.dart';

// #############################################################################
/// A single route parameter.
class GgRouteParam<T> {
  // ...........................................................................
  /// Constructor.
  /// - [seed] The initial value of the route parameter.
  GgRouteParam({required this.seed});

  // ...........................................................................
  /// The initial value of the route parameter.
  final T seed;
}

// #############################################################################
/// Use this widget to insert a list of route parameters into the currently
/// visible route.
class GgRouteParams extends StatelessWidget {
  // ...........................................................................
  /// Constructor.
  /// - [key] - The widget's key.

  const GgRouteParams({super.key, required this.child, required this.params});

  // ...........................................................................
  /// The parameters that will be assigned to the current route tree node.
  final Map<String, GgRouteParam> params;

  /// The parameters that will be associated with the route tree node. Important:
  /// The parameters are only assigned the first time. On later instantiations
  /// of this object, the existing parameter instances will be taken.
  final Widget child;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    _checkParams(context);
    _writeParamsToNode(context);
    return child;
  }

  // ######################
  // Private
  // ######################

  // ...........................................................................
  void _checkParams(BuildContext context) {
    // Check if any of the parent route param widgets already contains a
    // parameter with same name.
    context.visitAncestorElements((element) {
      GgRouteParams? parentWidget = element.widget is GgRouteParams
          ? element.widget as GgRouteParams
          : null;

      if (parentWidget != null) {
        final existingParams = parentWidget.params.keys;
        final ownParams = params.keys;
        for (var ownParam in ownParams) {
          if (existingParams.contains(ownParam)) {
            throw ArgumentError(
              'Cannot process route param "$ownParam". '
              'There is already a parent GgRouteParams object, containing a route param with the name "$ownParam". '
              'Make sure you are using unique param names accross a route and its parents.',
            );
          }
        }
      }

      return true;
    });
  }

  // ...........................................................................
  void _writeParamsToNode(BuildContext context) {
    final router = GgRouter.of(context);
    params.forEach((name, value) {
      router.node.findOrCreateParam(name: name, seed: value.seed);
    });
  }
}
