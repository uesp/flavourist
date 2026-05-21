// ignore_for_file: unnecessary_null_comparison

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

import 'package:flavourist/src/parser/models/flavors/flavor_icon.dart';
import 'package:flavourist/src/utils/constants.dart';

import 'android.dart';
import 'android_json.dart';
import 'darwin.dart';
import 'darwin_json.dart';

class Flavor {

	final String applicationID;

	final String name;

	final FlavorIcon? icon;

	final FlavorIcon? debugIcon;

	final FlavorIcon? betaIcon;

	final FlavorIcon? profileIcon;

	final List<String>? platforms;

	Android? android;

	Darwin? ios;

	Darwin? macos;

	Flavor({
		required this.applicationID,
		required this.name,
		this.icon,
		this.debugIcon,
		this.betaIcon,
		this.profileIcon,
		this.platforms,
		this.android,
		this.ios,
		this.macos,
	}) {
		android ??= platforms!.contains("android")
				? Android(applicationID: applicationID)
				: null;
		ios ??= platforms!.contains("ios")
				? Darwin(applicationID: applicationID)
				: null;
		macos ??= platforms!.contains("macos")
				? Darwin(applicationID: applicationID)
				: null;
	}

	factory Flavor.fromJson(Map<String, dynamic> json) {
		final applicationID = json['applicationID'] as String;
		return Flavor(
			applicationID: applicationID,
			name: json['name'] as String,
			icon: flavorIconFromJson(json['icon']),
			debugIcon: flavorVariantIconFromJson(json['debug']),
			betaIcon: flavorVariantIconFromJson(json['beta']),
			profileIcon: flavorVariantIconFromJson(json['profile']),
			platforms: (json['platforms'] as List<dynamic>?)
					?.map((e) => e as String)
					.toList() ??
				Constants.defaultPlatforms,
			android: json['android'] == null
					? null
					: androidFromJson(
							Map<String, dynamic>.from(json['android'] as Map),
							fallbackApplicationId: applicationID,
						),
			ios: json['ios'] == null
					? null
					: darwinFromJson(
							Map<String, dynamic>.from(json['ios'] as Map),
							fallbackApplicationId: applicationID,
						),
			macos: json['macos'] == null
					? null
					: darwinFromJson(
							Map<String, dynamic>.from(json['macos'] as Map),
							fallbackApplicationId: applicationID,
						),
		);
	}
}
