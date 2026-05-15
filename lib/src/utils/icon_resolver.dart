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

import 'dart:io';

import 'package:flavourist/src/parser/models/flavors/darwin/enums.dart';
import 'package:flavourist/src/parser/models/flavors/flavor.dart';
import 'package:flavourist/src/parser/models/flavors/flavor_icon.dart';
import 'package:flavourist/src/utils/icon_compose.dart';
import 'package:flavourist/src/utils/icon_variant.dart';

class AdaptiveLayers {
	final String foreground;
	final String background;

	const AdaptiveLayers({required this.foreground, required this.background});
}

class IconResolver {
	const IconResolver();

	static Iterable<IconVariant> variantsToGenerate(Flavor flavor) sync* {
		if (flavor.icon != null) {
			yield IconVariant.release;
		}
		if (flavor.debugIcon != null) {
			yield IconVariant.debug;
		}
		if (flavor.betaIcon != null) {
			yield IconVariant.beta;
		}
		if (flavor.profileIcon != null) {
			yield IconVariant.profile;
		}
	}

	FlavorIcon? resolveIcon(Flavor flavor, IconVariant variant) {
		final base = flavor.icon;
		if (base == null) {
			return null;
		}
		final override = switch (variant) {
			IconVariant.release => null,
			IconVariant.debug => flavor.debugIcon,
			IconVariant.beta => flavor.betaIcon,
			IconVariant.profile => flavor.profileIcon,
		};
		return base.merge(override);
	}

	String androidSourceSetName(String flavorName, IconVariant variant) =>
			'$flavorName${variant.androidSourceSetSuffix()}';

	String darwinAssetPrefix(String flavorName, IconVariant variant) =>
			'$flavorName${variant.darwinAssetPrefixSuffix()}';

	String assetPrefixForTarget(String flavorName, Flavor flavor, Target target) {
		final variant = IconVariant.fromTarget(target);
		if (variant == null) {
			return flavorName;
		}
		if (!_hasDistinctVariantAssets(flavor, variant)) {
			return flavorName;
		}
		return darwinAssetPrefix(flavorName, variant);
	}

	bool _hasDistinctVariantAssets(Flavor flavor, IconVariant variant) =>
			switch (variant) {
				IconVariant.release => flavor.icon != null,
				IconVariant.debug => flavor.debugIcon != null,
				IconVariant.beta => flavor.betaIcon != null,
				IconVariant.profile => flavor.profileIcon != null,
			};

	bool hasIconConfig(Flavor flavor) => flavor.icon != null;

	bool iconSourcesReady(
		Flavor flavor,
		IconVariant variant, {
		required bool ios,
	}) {
		final icon = resolveIcon(flavor, variant);
		if (icon == null) {
			return false;
		}

		final override = platformIconOverride(flavor, ios: ios);
		if (override != null) {
			return _fileExists(override);
		}

		final layers = adaptiveLayers(flavor, variant);
		if (layers != null) {
			return _fileExists(layers.foreground) && _fileExists(layers.background);
		}

		final foreground = icon.foreground;
		if (foreground != null && foreground.isNotEmpty) {
			return _fileExists(foreground);
		}

		return false;
	}

	bool monochromeSourceReady(Flavor flavor, IconVariant variant) {
		final path = monochromePath(flavor, variant);
		return path != null && _fileExists(path);
	}

	bool _fileExists(String path) => File(path).existsSync();

	bool hasAdaptiveLayers(Flavor flavor, IconVariant variant) =>
			resolveIcon(flavor, variant)?.hasAdaptiveLayers ?? false;

	AdaptiveLayers? adaptiveLayers(Flavor flavor, IconVariant variant) {
		final icon = resolveIcon(flavor, variant);
		if (icon == null || !icon.hasAdaptiveLayers) {
			return null;
		}
		return AdaptiveLayers(
			foreground: icon.foreground!,
			background: icon.background!,
		);
	}

	/// Foreground path for adaptive icons (overlay applied when configured).
	String adaptiveForegroundSource(
		Flavor flavor,
		IconVariant variant, {
		required String flavorName,
	}) {
		final icon = resolveIcon(flavor, variant)!;
		final foreground = icon.foreground!;
		if (!icon.hasOverlay) {
			return foreground;
		}
		return IconCompose.composeForegroundWithOverlay(
			foreground: foreground,
			overlay: icon.overlay!,
			flavorName: flavorName,
			outputSuffix: '${variant.name}_fg',
		).path;
	}

	String? monochromePath(Flavor flavor, IconVariant variant) {
		final path = resolveIcon(flavor, variant)?.monochrome;
		if (path == null || path.isEmpty) {
			return null;
		}
		return path;
	}

	String? platformIconOverride(Flavor flavor, {required bool ios}) {
		final path = ios ? flavor.ios?.icon : flavor.macos?.icon;
		if (path == null || path.isEmpty) {
			return null;
		}
		return path;
	}

	/// Flat PNG for Darwin [AppIcon.appiconset] or Android legacy mipmaps.
	String resolveFlatLauncherSource(
		Flavor flavor, {
		required String flavorName,
		required IconVariant variant,
		required bool ios,
	}) {
		final override = platformIconOverride(flavor, ios: ios);
		if (override != null) {
			return override;
		}

		final icon = resolveIcon(flavor, variant);
		if (icon == null) {
			throw StateError(
				'Flavor "$flavorName" has no icon sources for variant $variant.',
			);
		}

		final layers = adaptiveLayers(flavor, variant);
		if (layers != null) {
			return IconCompose.composeAdaptiveIcon(
				foreground: layers.foreground,
				background: layers.background,
				overlay: icon.hasOverlay ? icon.overlay : null,
				flavorName: flavorName,
				outputSuffix: variant.name,
			).path;
		}

		final foreground = icon.foreground;
		if (foreground != null && foreground.isNotEmpty) {
			if (!icon.hasOverlay) {
				return foreground;
			}
			return IconCompose.composeForegroundWithOverlay(
				foreground: foreground,
				overlay: icon.overlay!,
				flavorName: flavorName,
				outputSuffix: '${variant.name}_flat',
			).path;
		}

		throw StateError(
			'Flavor "$flavorName" has no icon sources for variant $variant.',
		);
	}
}
