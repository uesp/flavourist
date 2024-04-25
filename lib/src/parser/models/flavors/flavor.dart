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

import 'package:flavourist/src/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

import 'android.dart';
import 'darwin.dart';

part 'flavor.g.dart';

@JsonSerializable(anyMap: true, createToJson: false)
class Flavor {

	@JsonKey(required: true, disallowNullValue: true) // required
  	final String applicationID; // applicationID, used for identifying app

	@JsonKey(required: true, disallowNullValue: true) // required
	final String name; // flavour display name

	@JsonKey(required: false, disallowNullValue: false) //optional
	final String? icon; // flavour app icon path

	@JsonKey(required: false, disallowNullValue: false, defaultValue: Constants.defaultPlatforms) // optional
	final List<String>? platforms; // which platforms to generate for this flavour

	// platform-specific properties
	@JsonKey(required: false, disallowNullValue: true)
	Android? android;

	@JsonKey(required: false, disallowNullValue: true)
	Darwin? ios;

	@JsonKey(required: false, disallowNullValue: true)
	Darwin? macos;

	// constructor
	Flavor({required this.applicationID, required this.name, this.icon, this.platforms, this.android, this.ios, this.macos, } ) {
		android  ??= platforms!.contains("android") ? Android(applicationId: applicationID) : null;
		ios 	 ??= platforms!.contains("ios") ? Darwin(bundleId: applicationID) : null;
		macos 	 ??= platforms!.contains("macos") ? Darwin(bundleId: applicationID) : null;
	}

	factory Flavor.fromJson(Map<String, dynamic> json) => _$FlavorFromJson(json);

}
