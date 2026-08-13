// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// .............................................................................
/// This [GgRouteInformationParser] needed when initializing a [Router] or a
/// [MaterialApp.router] instance.
///
/// ```
/// MaterialApp.router(
///   title: "GgRouterExample",
///   routerDelegate: GgRouterDelegate(child: ...),
///   routeInformationParser: GgRouteInformationParser(),
/// );
/// ```
class GgRouteInformationParser
    extends RouteInformationParser<RouteInformation> {
  // ...........................................................................
  @override
  Future<RouteInformation> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    return SynchronousFuture(routeInformation);
  }

  // ...........................................................................
  @override
  RouteInformation restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}
