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

import 'package:flavourist/src/parser/models/flavors/android.dart';
import 'package:flavourist/src/parser/models/flavors/android/adaptive_icon.dart';
import 'package:flavourist/src/parser/models/flavors/android/build_config_field.dart';
import 'package:flavourist/src/parser/models/flavors/android/res_value.dart';
import 'package:flavourist/src/parser/models/flavors/flavor_icon.dart';

/// Parses [Android] from YAML. [fallbackApplicationId] is the flavor-level
/// `applicationID` when the platform block omits it.
Android androidFromJson(
	Map<String, dynamic> json, {
	String? fallbackApplicationId,
}) {
	final applicationID = json['applicationID'] as String? ??
			fallbackApplicationId;
	if (applicationID == null || applicationID.isEmpty) {
		throw ArgumentError(
			'Android requires "applicationID" in flavors.yaml or on the flavor.',
		);
	}

	final customConfig = (json['customConfig'] as Map?)?.map(
			(k, e) => MapEntry(k as String, e),
		) ??
		<String, dynamic>{};

	final resValues = (json['resValues'] as Map?)?.map(
			(k, e) => MapEntry(
				k as String,
				ResValue.fromJson(Map<String, dynamic>.from(e as Map)),
			),
		) ??
		<String, ResValue>{};

	final buildConfigFields = (json['buildConfigFields'] as Map?)?.map(
			(k, e) => MapEntry(
				k as String,
				BuildConfigField.fromJson(Map<String, dynamic>.from(e as Map)),
			),
		) ??
		<String, BuildConfigField>{};

	return Android(
		applicationID: applicationID,
		customConfig: Map<String, dynamic>.from(customConfig),
		resValues: resValues,
		buildConfigFields: buildConfigFields,
		generateDummyAssets: json['generateDummyAssets'] as bool? ?? true,
		icon: platformIconConfigFromJson(json['icon']),
		adaptiveIcon: json['adaptiveIcon'] == null
				? null
				: AdaptiveIcon.fromJson(
						Map<String, dynamic>.from(json['adaptiveIcon'] as Map),
					),
	);
}
