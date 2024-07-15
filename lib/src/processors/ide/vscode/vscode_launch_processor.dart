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
import 'package:flavourist/src/processors/commons/string_processor.dart';
import 'package:flavourist/src/processors/ide/vscode/models/configuration.dart';
import 'package:flavourist/src/processors/ide/vscode/models/launch.dart';

class VSCodeLaunchProcessor extends StringProcessor {
	VSCodeLaunchProcessor({ required super.config });

	@override
  	execute() {
		final flavors = config.flavors.entries;
		return Launch(configurations: flavors.expand(
			(flavor) => Target.values.map(
				(target) => Configuration(
					name: '${flavor.value.name} ${target.name == "debug" ? "(Dev)" : ""}',
					flutterMode: target.name,
					request: 'launch',
					type: 'dart',
					program: 'lib/res/configs/${flavor.key}/main.dart',
					args: [ '--flavor', flavor.key, "--target", "lib/res/configs/${flavor.key}/main.dart" ],
				)
		)).toList()).toString();
	}

	@override
	String toString() => "VSCodeLaunchProcessor";
}
