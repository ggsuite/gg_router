# GgRouter - Easy Routing for Flutter

`GgRouter` is a simple _and_ powerful routing package for Flutter. Just define
your nested routes. Add query parameters. Define the route transitions. GgRouter
will do the rest for you:

- GgRouter selects the right widgets for rendering
- GgRouter restores the previous route state.
- GgRouter performs only necessary animations.
- GgRouter parses the URI and applies it to your application state.
- GgRouter synchronizes route tree changes to the browser URI.

Additionally, GgRouter allows you to create index routes, default routes,
wildcard routes, assign semantic labels to routes. With `GgNavigationPage` a page
based hierarchical navigation system is provided. And finally, it can backup
and restore the complete route tree as JSON.

## Demo Video

Klick [here](https://www.youtube.com/watch?v=b9wYtl0eySU) to watch a YouTube
demo of GgRouter.

![Features](https://github.com/inlavigo/gg_router/raw/master/img/gg_router_short.gif)

## Content

- [GgRouter - Easy Routing for Flutter](#ggrouter---easy-routing-for-flutter)
  - [Demo Video](#demo-video)
  - [Initialize GgRouter](#initialize-ggrouter)
  - [Define routes](#define-routes)
    - [Page routes](#page-routes)
    - [Popover routes](#popover-routes)
    - [Nested routes](#nested-routes)
  - [Handling fallbacks](#handling-fallbacks)
    - [Index route](#index-route)
    - [Default route](#default-route)
    - [Wildcard routes](#wildcard-routes)
  - [Navigation](#navigation)
    - [Navigate absolutely](#navigate-absolutely)
    - [Navigate relatively](#navigate-relatively)
    - [Navigate to last route](#navigate-to-last-route)
    - [Navigation Bars](#navigation-bars)
  - [URI query params](#uri-query-params)
    - [Define query params](#define-query-params)
    - [Access query params](#access-query-params)
  - [Animations](#animations)
    - [Animate route transitions](#animate-route-transitions)
    - [Route specific animations](#route-specific-animations)
  - [Page Navigation](#page-navigation)
  - [More stuff](#more-stuff)
    - [Save and restore route state](#save-and-restore-route-state)
    - [Rebuild widget on route changes](#rebuild-widget-on-route-changes)
    - [Add semantic labels to routes](#add-semantic-labels-to-routes)
    - [Error handling](#error-handling)
  - [State on the supply chain](#state-on-the-supply-chain)
  - [Migrate from 3.x](#migrate-from-3x)
  - [Example](#example)
  - [Features and bugs](#features-and-bugs)

## Initialize GgRouter

To initialize `GgRouter`, create a `MaterialApp.router(...)` instance
and provide it with an instance of `GgRouterDelegate` and
`GgRouterInformationParser`.

~~~dart
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: GgRouterDelegate(
        child: Scaffold(
          body: GgRouterExample(),
        ),
      ),
      routeInformationParser: GgRouteInformationParser(),
    );
  }
}
~~~

## Define routes

### Page routes

Use the `GgRouter` widget to add routes to your application structure:

~~~dart
@override
Widget build(BuildContext context){
  return GgRouter(
    {
      'sports':         _sports,
      'transportation': _transportation,
      'places':         _places
    }
  );
}
~~~

Each of these routes will replace its siblings when being selected.

### Popover routes

To show a route in front of existing content, create a popover route:

~~~dart
GgPopoverRoute(
  // ...
  name: 'popover',          // The route which will open the popover
  base: _myWidget,          // The regular content
  popover: _myDialog,       // The popover
  inAnimation: _rotateIn,   // The appearing animation
  outAnimation: _rotateOut, // The disappearing animation
),
~~~

### Nested routes

You can arbitrarily nest these routes. Just place another `GgRouter` widget
within one of the routes. Child `GgRouter` widgets do not need to be direct
children.

## Handling fallbacks

### Index route

To define a default route which is shown when none of the routes is selected,
add a route with name `'_INDEX_'`:

~~~dart
GgRouter(
  {
    '_INDEX_': _index,
    'sports': _sports,
    // ...
  }
);
~~~

### Default route

Chose a default route when no `_INDEX` route is defined by using the
`defaultRoute` parameter.

~~~dart
GgRouter(
  {
    'sports': _sports,
    // ...
  },
  defaultRoute: 'sports'
);
~~~

### Wildcard routes

If you want to handle arbitrary route names, e.g., parsing an ID from the URI,
you can setup a wild card route using `*` as route name:

~~~dart
return GgRouter(
  {
    // ...
    '*': _wildCardPage,
  },
  /// ...
);
~~~

To get the name of the actual route, use `GgRouter.of(context).routeName`:

~~~dart
Widget _wildCardPage(BuildContext context) {
  final routeName = GgRouter.of(context).routeName;
  // ... do something with the routeName
}
~~~

## Navigation

### Navigate absolutely

Use `GgRouter.of(context).navigateTo('/sports/football')` to absolutely navigate
to the football page, no matter where you currently are in your application.

### Navigate relatively

- Use `GgRouter.of(context).navigateTo('./dialog/')` to navigate to the direct child.
- Use `GgRouter.of(context).navigateTo('..')` to navigate to the parent.
- Use `GgRouter.of(context).navigateTo('../../')` to navigate to the grand parent.
- Use `GgRouter.of(context).navigateTo('../transportation/')` to navigate to a sibling.

### Navigate to last route

When you switch to a route, you might want to open the child route that was
opened when you left the route the last time. Use the `_LAST_` keyword to
activate this route:

~~~dart
GgRouter.of(context).navigateTo('/sports/_LAST_');
~~~

### Navigation Bars

Navigation buttons and `GgRouter` widgets can be used side by side. Navigation
elements can use `GgRouter.of(context)` to perform various routing operations:

- Use `GgRouter.of(context).navigateTo('...')` to navigate to a route.
- Use `GgRouter.of(context).routeNameOfActiveChild` to find out which child
  route is currently visible.
- Use `GgRouter.of(context).indexOfActiveChild` to find out which of the items
  in a `BottomNavigationBar` need to be styled as visible elements.
- Use `GgRouter.of(context).onActiveChildChange` to rebuild the navigation bar,
  when the visible child changes.

## URI query params

### Define query params

Use `GgRouteParams` to define a list of query params that are shown in the URI.

~~~dart
GgRouteParams(
  params: {
    'a': GgRouteParam<bool>(seed: false),
    'b': GgRouteParam<int>(seed: 5),
    'c': GgRouteParam<String>(seed: 'hello'),
  },
  child: // ...
}
~~~

The param names `a`, `b`, and `c` must only be used one time in a route path.
Different route paths can define the same parameter names. When switching a
route, also the route parameters will change.

### Access query params

To use the value of a query param in a widget, use these method:

- Use `GgRouter.of(context).param('a')?.value` to get or set the value of the
  query param `a`.
- Use `GgRouter.of(context).param('a')?.stream` to observe value changes of
  query param `a`.
- Use `GgRouter.of(context).param('a')?.node` to read or write the input node
  of the query param on the supply chain.

## Animations

### Animate route transitions

`GgRouter` offers a simple way to animate route transitions. Use `inAnimation`
and `outAnimation` to define animations that are applied to the appearing and
the disappearing route:

~~~dart
builder: (context) {
  return GgRouter(
    // ...
    inAnimation: (context, animation, child, size)
      => Transform.scale(scale: animation.value, child: child),
    outAnimation: (context, animation, child, size)
      => Transform.scale(scale: 1.0 - animation.value, child: child),
  );
},
~~~

With the possibility to define separate in and out animations, you can create
advanced transitions. E.g., move an appearing widget in from the left side and
out from the right side. Use the provided `size` parameter to define how far
animated widgets should be moved.

### Route specific animations

To find out which route is currently fading in or fading out, use the following
methods within your animation callback:

- `GgRouter.of(context).indexOfChildAnimatingOut`
- `GgRouter.of(context).nameOfChildAnimatingOut`
- `GgRouter.of(context).indexOfChildAnimatingIn`
- `GgRouter.of(context).nameOfChildAnimatingIn`

~~~dart
Widget _moveOut(
  BuildContext context,
  Animation animation,
  Widget child,
) {
  final w = MediaQuery.of(context).size.width;
  final h = MediaQuery.of(context).size.height;
  final index = GgRouter.of(context).indexOfChildAnimatingOut;

  final toRight = Offset(w * (animation.value), 0);
  final toBottom = Offset(0, h * (animation.value));
  final toLeft = Offset(w * (-animation.value), 0);

  Offset offset = index == 0
      ? toLeft
      : index == 1
          ? toBottom
          : toRight;

  return Transform.translate(
    offset: offset,
    child: child,
  );
}
~~~

## Page Navigation

With `GgNavigationPage` we provide a simple way to create nested navigation
pages:

![Features](img/gg_navigation_page.gif)

To create pages as shown in the animation, just nest instances of
`GgNavigationPage` inside each other:

~~~dart
Widget build(context){
  return GgNavigationPageRoot(
    pageContent: (context) => _parentPage;
    children: {
      'child': (context) => GgNavigationPage(
        pageContent: (_) => Container(
          color: Color(0xFF555555),
          child: _childPage,
        children: {
          'grand-child': (_) => GgNavigationPage(
                pageContent: _grandChildPage
        },
      )
    },
  );
}
~~~

The code above will create the following page hierarchy:

~~~txt
  |-root
    |-child
      |-grand-child
~~~

These things are done by the package for you:

- Setup `GgRouter` to match the page hierarchy.
- Show a navigation bar at the top of your pages
- Configure back and close button on the navigation page
- Sync browser URL and page position

To see an example, launch `example/lib/main.dart`, click on "Sports" at the
top, click on "Basketball" at the bottom, and then click on the "basketball" in
the center of the screen.

## More stuff

### Save and restore route state

`GgRouter` constructor offers a `saveState` and `restorState` callback:

- `saveState` will be called with a JSON string when the route state changes.
- `restoreState` will be called at the very first beginning and allows you
  to restore a previously defined state.

### Rebuild widget on route changes

If you want to rebuild a widget each time the active route is changing,
use `GgRouteChangeBuilder`.

~~~dart
int buildNumber;

final widget = GgRouter.root(
        child: GgRouteChangeBuilder(
            key: key, builder: (_) => Text('${buildNumber++}')),
        node: rootNode,
      );
~~~

### Add semantic labels to routes

The `semanticLabels` constructor parameter of `GgRouter` allows you to specify a
semantic label for each route:

~~~dart
@override
 GgRouter(

  // ...

  semanticLabels: {
    'sports':         'Navigate to sports page',
    'transportation': 'Navigate to transportations page',
    'places':         'Navigate to places page',
  }
);
~~~

To retrieve the semantic label for a given route, use `GgRouter`'s the
`semanticLabelForPath(...)` property:

~~~dart
final semanticLabel = GgRouter.of(context).semanticLabelForPath(route);
~~~

By doing so, you can now assign semantic labels to buttons that perform route
operations.

If you need to specify a semantic label for a child router in advance, you
can use `GgRouter.of(context).setSemanticLabelForPath(path, label)`.

### Error handling

If you open a URI in the browser that is not defined using `GgRouter(...)`, an
error is thrown. To handle that error, assign an error handler to
`GgRouter.of(context).node.errorHandler = (error){/* Handle Error**/}`.

## State on the supply chain

`gg_router` keeps the route state in a scope of
[supply_chain](https://pub.dev/packages/supply_chain). The root route creates
the scope `router` in the scope you pass, each route a child scope:

~~~text
router                 (scope)
  path                 input  '/settings/sounds'
  settings             (scope, one per route)
    isStaged           input  true while the route is staged
    stagedChild        input  the name of the (last) staged child
    sounds             (scope)
      volume           input, one per parameter
~~~

~~~dart
final root = GgRouteNode.newRoot(scope: appScope);

// Navigate without a BuildContext
root.pathNode.product = '/settings/sounds';

// Observe the navigation
appScope.findNode<String>('router/path');
appScope.findNode<bool>('router/settings/isStaged');
~~~

Without a scope, `GgRouteNode.newRoot()` creates a supply chain of its own.
Route names that are not lower camel case get encoded keys, see
`GgRouteNode.keyForName`.

`GgRoutePathBuilder` rebuilds with the staged path through a `NodeBuilder`
of [supply_chain_flutter](https://pub.dev/packages/supply_chain_flutter).
Mount a `ScmTickDriver` near the app root, so the `NodeBuilder` is updated
every frame.

## Migrate from 3.x

- Rename `GgRouteTreeNode` to `GgRouteNode` and `GgRouteTreeNodeError` to
  `GgRouteNodeError`.
- Parameters are `GgParam` instead of `GgValue`. `value`, `stringValue` and
  `stream` work as before; `node` is the input node on the supply chain.
- Pass the scope of your app to `GgRouteNode.newRoot(scope: ...)` to put the
  router state into your supply chain.
- Instead of `GgRouter.of(context).navigateTo(path)` packages may write the
  node `router/path`. `GgRouter.of(context)` keeps working.
- The JSON written by `saveState` keeps the format of 3.x. A saved route
  state loads unchanged.
- Remove `gg_value` and `gg_once_per_cycle` from your dependencies if you only
  used them for the router.

## Example

An example demonstrating all of the features above can be found in `example/main.dart`.

## Features and bugs

Please file feature requests and bugs at [GitHub](https://github.com/inlavigo/gg_router).
