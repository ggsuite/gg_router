// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_en.dart';

final AppLocalizations englishLocalization = AppLocalizationsEn();

AppLocalizations ggl(BuildContext context) =>
    AppLocalizations.of(context) ?? englishLocalization;
