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

import 'package:json_annotation/json_annotation.dart';

part 'flavor_icon.g.dart';

/// Per-flavor launcher icon sources from [flavors.yaml] `icon:` block.
@JsonSerializable(anyMap: true, createToJson: false)
class FlavorIcon {
	final String? foreground;
	final String? background;
	final String? monochrome;
	final String? overlay;

	const FlavorIcon({
		this.foreground,
		this.background,
		this.monochrome,
		this.overlay,
	});

	factory FlavorIcon.fromJson(Map<String, dynamic> json) =>
			_$FlavorIconFromJson(json);

	bool get hasAdaptiveLayers =>
			foreground != null &&
			foreground!.isNotEmpty &&
			background != null &&
			background!.isNotEmpty;

	bool get hasForeground =>
			foreground != null && foreground!.isNotEmpty;

	bool get hasOverlay => overlay != null && overlay!.isNotEmpty;

	/// Field-wise merge: non-null [override] fields replace this icon's fields.
	FlavorIcon merge(FlavorIcon? override) {
		if (override == null) {
			return this;
		}
		return FlavorIcon(
			foreground: override.foreground ?? foreground,
			background: override.background ?? background,
			monochrome: override.monochrome ?? monochrome,
			overlay: override.overlay ?? overlay,
		);
	}
}

/// Parses `icon:` as a map or legacy single path (treated as [FlavorIcon.foreground]).
FlavorIcon? flavorIconFromJson(Object? json) {
	if (json == null) {
		return null;
	}
	if (json is String) {
		return FlavorIcon(foreground: json);
	}
	if (json is Map) {
		return FlavorIcon.fromJson(Map<String, dynamic>.from(json));
	}
	return null;
}

/// Parses `debug:` / `beta:` / `profile:` blocks with nested `icon:`.
FlavorIcon? flavorVariantIconFromJson(Object? json) {
	if (json == null || json is! Map) {
		return null;
	}
	return flavorIconFromJson(json['icon']);
}
