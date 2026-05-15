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

import 'package:flavourist/src/parser/models/flavors/flavor.dart';
import 'package:flavourist/src/utils/icon_compose.dart';

class AdaptiveLayers {
	final String foreground;
	final String background;

	const AdaptiveLayers({required this.foreground, required this.background});
}

class IconResolver {
	const IconResolver();

	bool hasIconConfig(Flavor flavor) => flavor.icon != null;

	/// True when launcher icon source files exist for [flavor] on the given platform.
	bool iconSourcesReady(Flavor flavor, {required bool ios}) {
		final override = platformIconOverride(flavor, ios: ios);
		if (override != null) {
			return _fileExists(override);
		}

		final layers = adaptiveLayers(flavor);
		if (layers != null) {
			return _fileExists(layers.foreground) && _fileExists(layers.background);
		}

		final foreground = flavor.icon?.foreground;
		if (foreground != null && foreground.isNotEmpty) {
			return _fileExists(foreground);
		}

		return false;
	}

	bool monochromeSourceReady(Flavor flavor) {
		final path = monochromePath(flavor);
		return path != null && _fileExists(path);
	}

	bool _fileExists(String path) => File(path).existsSync();

	bool hasAdaptiveLayers(Flavor flavor) =>
			flavor.icon?.hasAdaptiveLayers ?? false;

	AdaptiveLayers? adaptiveLayers(Flavor flavor) {
		final icon = flavor.icon;
		if (icon == null || !icon.hasAdaptiveLayers) {
			return null;
		}
		return AdaptiveLayers(
			foreground: icon.foreground!,
			background: icon.background!,
		);
	}

	String? monochromePath(Flavor flavor) {
		final path = flavor.icon?.monochrome;
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
		required bool ios,
	}) {
		final override = platformIconOverride(flavor, ios: ios);
		if (override != null) {
			return override;
		}

		final layers = adaptiveLayers(flavor);
		if (layers != null) {
			return IconCompose.composeAdaptiveIcon(
				foreground: layers.foreground,
				background: layers.background,
				flavorName: flavorName,
			).path;
		}

		final foreground = flavor.icon?.foreground;
		if (foreground != null && foreground.isNotEmpty) {
			return foreground;
		}

		throw StateError(
			'Flavor "$flavorName" has no icon sources for launcher generation.',
		);
	}
}
