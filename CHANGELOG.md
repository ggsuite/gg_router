# Changelog

## [Unreleased]

### Changed

- Switch to swift package manager

## [3.1.8] - 2024-09-04

### Added

- Add localization

### Changed

- Adjust some color things

## [3.1.7] - 2024-09-03

### Changed

- Update flutter SDK version + Fix some issues in the example

## [3.1.6] - 2024-04-13

### Changed

- Rework changelog + repository URL in pubspec.yaml
- 'Github Actions Pipeline'
- 'Github Actions Pipeline: Add SDK file containing flutter into .github/workflows to make github installing flutter and not dart SDK'

### Fixed

- ChangeLog

### Removed

- 'Pipline: Disable cache'

## [3.1.5] - 2024-04-13

### Changed

- ignore pubspec.lock

### Removed

- dependency to gg\_install\_gg, remove ./check script
- dependency to pana

## [3.1.4] - 2024-04-10

## 3.1.2 - 2024-01-01

- Update latest dependencies

## 3.1.1 - 2024-01-01

- Update library dependencies

## 3.1.0 - 2023-03-21

- Performance improvements for animations
- `GgNavigationPage`: Allow to overwrite back and close button

## 3.0.2 - 2023-02-23

- Breaking change: `GgNavigationPageRoot` takes a `GgNavigationPage` instead of `pageContent`,
`children` and `semanticLabels`.
- Breaking change: Renamed `visibleRoute` -> `stagedDescendants`
- Hand these parameters over to `GgNavigationPage` constructor.
- Use `showBackButton` constructor parameter of `GgNavigation` to show or hide back button.
- Fix an issue with updating the route tree
- Add `onShow`, `onNavigateToParent`, `onNavigateToChild` to `GgNavigationPage`
- Add `showCloseButton` to `GgNavigationPage`
- Handle over size for popover routes
- Fix `nameOfChildAnimatingOut` was null when popover was closed.
- Add a bunch of animations

## 2.0.0 - 2022-01-22

- Background color of `NavigationBar` can be null to allow clicks going widgets behind
- Added `parseJson(...)`
- Added `typedef GgNavigationPageBuilder`
- Simplified widget structure
- Use `GgShowInForeground` to define which widgets should be shown in the
foreground: a) the widget animated in or b) the widget animated out.
- Added `GgNavigationPage` to create deeply nested navigation pages similar
to `CupertinoPageScaffold` and `CupertinoNavigationBar`.
- Breaking changes:
- Animation callbacks are provided with the size of the enclosing widget

## 1.2.1 - 2022-01-22

- Upgraded dependencies
- Removed warnings
- Works on Flutter 2.10

## 1.2.0 - 2021-06-29

- Introduced `GgRouteChangeBuilder`
- Allow to set semantics label for a given route
- Allow to specify semantic labels for a given route path
- Store semantic label into JSON

## 1.1.0 - 2021-03-24

- Fixed issues with disposing the route tree
- Renamed `GgRouteTreeNode:child` into `GgRouteTreeNode:findOrCreateChild`
- Reintroduced `GgRouteTreeNode:child`
- Refined handling when a root and a default path is submitted to
GgRouterDelegate.
- `GgRouterDelegate` can take a pre-configured root node, which helps the route
tree be managed outside the widget hierarchy.
- `GgRouteTreeNode.newRoot()` was introduced to create root nodes.

## 1.0.1 - 2021-03-20

- Fixed a bug braking semantic labels

## 1.0.0 - 2021-03-19

- Added the option to define wild card routes using '\*' as route name.

## 1.0.0-beta.5 - 2021-03-18

- Animations

- Route transitions can be animated now.

- Create a separate in and out animation

- Create different animations for different routes

- `GgPopoverRoute`

- was renamed in `GgPopoverRoute`

- Interface was changed slightly

- Index routes

- Index routes must not be named with empty name.

- They must get the name `*INDEX*.

- Renamed several identifiers.


## 1.0.0-beta.4 - 2021-03-13

- Save and restore route tree

## 1.0.0-beta.3 - 2021-03-11

- Added an index route example

## 1.0.0-beta.2 - 2021-03-10

- Fixed the unit tests for the example.

## 1.0.0-beta.1 - 2021-03-10

- The first public version of GgRouter.

[Unreleased]: https://github.com/inlavigo/gg_router/compare/3.1.8...HEAD
[3.1.8]: https://github.com/inlavigo/gg_router/compare/3.1.7...3.1.8
[3.1.7]: https://github.com/inlavigo/gg_router/compare/3.1.6...3.1.7
[3.1.6]: https://github.com/inlavigo/gg_router/compare/3.1.5...3.1.6
[3.1.5]: https://github.com/inlavigo/gg_router/compare/3.1.4...3.1.5
[3.1.4]: https://github.com/inlavigo/gg_router/compare/3.1.2...3.1.4
