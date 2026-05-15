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
import 'package:json_annotation/json_annotation.dart';

import 'android.dart';
import 'darwin.dart';

part 'flavor.g.dart';

@JsonSerializable(anyMap: true, createToJson: false)
class Flavor {

	@JsonKey(required: true, disallowNullValue: true)
	final String applicationID;

	@JsonKey(required: true, disallowNullValue: true)
	final String name;

	@JsonKey(fromJson: flavorIconFromJson)
	final FlavorIcon? icon;

	@JsonKey(name: 'debug', fromJson: flavorVariantIconFromJson)
	final FlavorIcon? debugIcon;

	@JsonKey(name: 'beta', fromJson: flavorVariantIconFromJson)
	final FlavorIcon? betaIcon;

	@JsonKey(name: 'profile', fromJson: flavorVariantIconFromJson)
	final FlavorIcon? profileIcon;

	@JsonKey(required: false, disallowNullValue: false, defaultValue: Constants.defaultPlatforms)
	final List<String>? platforms;

	@JsonKey(required: false, disallowNullValue: true)
	Android? android;

	@JsonKey(required: false, disallowNullValue: true)
	Darwin? ios;

	@JsonKey(required: false, disallowNullValue: true)
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
				? Android(applicationId: applicationID)
				: null;
		ios ??= platforms!.contains("ios")
				? Darwin(bundleId: applicationID)
				: null;
		macos ??= platforms!.contains("macos")
				? Darwin(bundleId: applicationID)
				: null;
	}

	factory Flavor.fromJson(Map<String, dynamic> json) => _$FlavorFromJson(json);
}
