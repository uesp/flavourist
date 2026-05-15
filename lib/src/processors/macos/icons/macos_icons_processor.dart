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

import 'package:flavourist/src/processors/commons/abstract_processor.dart';
import 'package:flavourist/src/processors/commons/queue_processor.dart';
import 'package:flavourist/src/processors/macos/icons/macos_icon_target_processor.dart';
import 'package:flavourist/src/utils/icon_resolver.dart';

class MacOSIconsProcessor extends AbstractProcessor {
	MacOSIconsProcessor(super.config);

	@override
	void execute() {
		const resolver = IconResolver();
		final processors = <AbstractProcessor>[];

		for (final entry in config.macosFlavors.entries) {
			final flavorName = entry.key;
			final flavor = entry.value;
			if (!resolver.hasIconConfig(flavor)) {
				continue;
			}
			if (!resolver.iconSourcesReady(flavor, ios: false)) {
				stdout.writeln(
					'⚠️  Skipping macos:icons for $flavorName: icon source files not found',
				);
				continue;
			}

			final source = resolver.resolveFlatLauncherSource(
				flavor,
				flavorName: flavorName,
				ios: false,
			);
			processors.add(
				MacOSIconTargetProcessor(
					source,
					flavorName,
					config: config,
				),
			);
		}

		if (processors.isNotEmpty) {
			QueueProcessor(processors, config: config).execute();
		}
	}

	@override
	String toString() => 'MacOSIconsProcessor';
}
