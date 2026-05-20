/*
 * Copyright (c) 2024 Angelo Cassano
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

import 'package:flavourist/src/parser/models/flavors/darwin/enums.dart';
import 'package:flavourist/src/parser/models/flavors/flavor.dart';
import 'package:flavourist/src/utils/flavor_display_name.dart';
import 'package:flavourist/src/utils/icon_resolver.dart';
import 'package:flavourist/src/utils/icon_variant.dart';

/// Launch ``env`` map with ``FLUTTER_XCODE_*`` entries for VS Code / Cursor.
///
/// Use the launch config ``env`` field (not ``toolEnv`` — the Dart-Code extension
/// replaces ``toolEnv`` and the Flutter debug adapter reads ``env``).
///
/// Flutter has no ``--beta`` mode, so beta launches use ``flutterMode: release``
/// and Xcode ``Release-{flavor}``. When [launchMode] is ``beta``, these overrides
/// select the correct app icon catalog and bundle display name.
///
/// Do **not** set ``FLUTTER_XCODE_PRODUCT_NAME``: Flutter forwards ``FLUTTER_XCODE_*``
/// as global ``xcodebuild`` settings, which would override ``PRODUCT_NAME`` on **every**
/// Pod target and break Swift module / framework names (e.g. ``webview_flutter_wkwebview``).
/// Runner already uses ``PRODUCT_NAME=$(BUNDLE_NAME)`` in xcconfig, so overriding
/// ``BUNDLE_NAME`` alone is enough for the app product name.
///
/// ``FLUTTER_XCODE_ASSET_PREFIX`` mirrors ``Beta-{flavor}`` xcconfigs so
/// ``$(ASSET_PREFIX)AppIcon`` matches the beta app icon set when editors pass
/// ``env`` through to ``flutter``/``xcodebuild``.
///
/// When ``env`` is not forwarded (common from some IDE launches), the app
/// ``preLaunchTask`` runs ``dart run flavourist:beta_asset_prefix beta <flavor>`` so
/// ``macos/Flutter/ephemeral/beta_asset_prefix_override.xcconfig`` and
/// ``ios/Flutter/ephemeral/beta_asset_prefix_override.xcconfig`` exist before Xcode
/// merges flavor xcconfigs (``#include?`` to those paths is last in generated configs).
Map<String, String>? darwinXcodeToolEnvForLaunchMode({
	required String flavorKey,
	required Flavor flavor,
	required String launchMode,
}) {
	final Target? target = switch (launchMode) {
		'beta' => Target.beta,
		_ => null,
	};
	if (target == null) {
		return null;
	}

	const resolver = IconResolver();
	final IconVariant? variant = IconVariant.fromTarget(target);
	if (variant == null || flavor.betaIcon == null) {
		return null;
	}

	final String assetPrefix = resolver.assetPrefixForTarget(
		flavorKey,
		flavor,
		target,
	);
	if (assetPrefix == flavorKey) {
		return null;
	}

	final String displayName = displayNameForTarget(flavor.name, target);

	return <String, String>{
		'FLUTTER_XCODE_ASSET_PREFIX': assetPrefix,
		'FLUTTER_XCODE_ASSETCATALOG_COMPILER_APPICON_NAME': '${assetPrefix}AppIcon',
		'FLUTTER_XCODE_BUNDLE_NAME': displayName,
		'FLUTTER_XCODE_BUNDLE_DISPLAY_NAME': displayName,
	};
}
