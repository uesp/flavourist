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

import 'dart:convert';

import 'package:flavourist/src/processors/commons/string_processor.dart';
import 'package:flavourist/src/utils/flavor_display_name.dart';

class VSCodeTasksProcessor extends StringProcessor {
	VSCodeTasksProcessor({required super.config});

	static const _presentation = {
		'echo': true,
		'reveal': 'always',
		'focus': false,
		'panel': 'new',
	};

	@override
	execute() {
		final flavorKeys = config.flavors.keys.toList();
		final flavorOptions = [...flavorKeys, 'all'];
		final defaultFlavor = flavorKeys.isNotEmpty ? flavorKeys.first : 'uesp';
		final buildModeOptions =
				launchBuildModes.map(buildScriptFlagForMode).toList();

		final tasks = {
			'version': '2.0.0',
			'inputs': [
				{
					'id': 'buildMode',
					'type': 'pickString',
					'description': 'Which release mode?',
					'options': buildModeOptions,
					'default': buildScriptFlagForMode('release'),
				},
				{
					'id': 'platformFlags',
					'type': 'pickString',
					'description': 'Which platform?',
					'options': [
						{'label': 'Android', 'value': '--android'},
						{'label': 'iOS', 'value': '--ios'},
						{'label': 'macOS', 'value': '--macos'},
						{'label': 'Web', 'value': '--web'},
						{
							'label': 'Mobile (iOS + Android)',
							'value': '--android --ios',
						},
						{
							'label': 'All (android, ios, web, macos)',
							'value': '--android --ios --web --macos',
						},
					],
					'default': '--android',
				},
				{
					'id': 'flavor',
					'type': 'pickString',
					'description': 'Which flavor?',
					'options': flavorOptions,
					'default': defaultFlavor,
				},
			],
			'tasks': [
				_shellTask(
					'Build Runner',
					'./scripts/build_runner.sh',
				),
				_shellTask(
					'Build (default)',
					'./scripts/build.sh',
				),
				_shellTask(
					'Build (Interactive)',
					'./scripts/build.sh \${input:buildMode} \${input:platformFlags} --flavor=\${input:flavor}',
				),
				_shellTask(
					'Build Android release (all flavors)',
					'./scripts/build.sh --release --android --flavor=all',
				),
				_shellTask(
					'Build Android beta (all flavors)',
					'./scripts/build.sh --beta --android --flavor=all',
				),
			],
		};

		return const JsonEncoder.withIndent('	').convert(tasks);
	}

	Map<String, dynamic> _shellTask(String label, String command) => {
			'label': label,
			'type': 'shell',
			'command': command,
			'group': 'build',
			'presentation': _presentation,
		};

	@override
	String toString() => 'VSCodeTasksProcessor';
}
