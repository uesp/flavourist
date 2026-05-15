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

import 'package:flavourist/src/parser/models/flavors/darwin.dart';
import 'package:flavourist/src/parser/models/flavors/darwin/variable.dart';

/// Parses [Darwin] from YAML using `applicationID` (wiki_app) or legacy `bundleId`.
Darwin darwinFromJson(Map<String, dynamic> json) {
	final bundleId = json['applicationID'] as String? ??
			json['bundleId'] as String?;
	if (bundleId == null || bundleId.isEmpty) {
		throw ArgumentError(
			'Darwin requires "applicationID" or "bundleId" in flavors.yaml.',
		);
	}

	final variables = (json['variables'] as Map?)?.map(
				(k, e) => MapEntry(
					k as String,
					Variable.fromJson(Map<String, dynamic>.from(e as Map)),
				),
			) ??
			<String, Variable>{};

	final buildSettings = (json['buildSettings'] as Map?)?.map(
			(k, e) => MapEntry(k as String, e),
		) ??
		<String, dynamic>{};

	return Darwin(
		bundleId: bundleId,
		variables: variables,
		buildSettings: Map<String, dynamic>.from(buildSettings),
		generateDummyAssets: json['generateDummyAssets'] as bool? ?? true,
		icon: json['icon'] as String?,
	);
}
