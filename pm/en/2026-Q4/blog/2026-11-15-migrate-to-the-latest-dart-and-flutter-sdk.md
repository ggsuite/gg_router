<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Migrate to the latest Dart and Flutter SDK

## Motivation

- gg_router should build and test on the current toolchain:
  Dart 3.14 and Flutter 3.50
- Flutter 3.50 deprecates `package:flutter/material.dart`; the material
  widgets now come from the package `material_ui`
- The generated DNA files of the repo should match the current DNA

## Strategy

- Raise the SDK constraints of the package and of the example
- Let `dart migrate --apply` and `dart fix --apply` do the mechanical
  part
- Regenerate the DNA with `gg dna upgrade`
- Fix the rest by hand until analyze and the tests are clean

## SDK constraints

- `pubspec.yaml` and `example/pubspec.yaml` require
  `sdk: ">=3.14.0 <4.0.0"` and `flutter: ">=3.50.0"`

## Material imports

- `dart fix --apply` replaced `package:flutter/material.dart` by
  `package:material_ui/material_ui.dart` in `lib/`, the tests and the
  example
- `lib/` uses material widgets, so `material_ui: ^1.11.0` is a regular
  dependency, not a dev dependency
- The example depends on `material_ui: ^1.11.0` as well

## DNA

- `gg dna upgrade` regenerated the DNA files and removed the skills the
  DNA no longer produces

## Dependency updates

- `helix` raised to `^1.15.1` and `dna_ggsuite` to `^2.0.0`, the
  versions the current DNA needs

## Open Points

- None
