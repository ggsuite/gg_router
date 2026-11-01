// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:supply_chain_flutter/supply_chain_flutter.dart';

import '../gg_router.dart';

/// Rebuilds [builder] with the staged path whenever the router navigates.
///
/// Reads the node `path` of the scope `router` with a [NodeBuilder]. The
/// supply chain must be ticked, e.g. by a `ScmTickDriver` near the app root.
class GgRoutePathBuilder extends StatelessWidget {
  /// Constructor
  const GgRoutePathBuilder({super.key, required this.builder});

  /// Builds the subtree for the staged path, e.g. `/settings/sounds`
  final Widget Function(BuildContext context, String path) builder;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    final pathNode = GgRouter.of(context).pathNode;

    return NodeBuilder<String>(
      scope: pathNode.scope,
      suppliers: [pathNode.key],
      combine: (components) => components.first as String,
      initialValue: pathNode.product,
      builder: builder,
    );
  }
}
