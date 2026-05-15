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

import 'package:flavourist/src/processors/android/icons/android_adaptive_icon_xml_processor.dart';
import 'package:flavourist/src/processors/android/icons/android_adaptive_icons_processor.dart';
import 'package:flavourist/src/processors/android/icons/android_icon_processor.dart';
import 'package:flavourist/src/processors/android/icons/android_monochrome_processor.dart';
import 'package:flavourist/src/processors/commons/abstract_processor.dart';
import 'package:flavourist/src/processors/commons/queue_processor.dart';
import 'package:flavourist/src/utils/icon_resolver.dart';

class AndroidIconsProcessor extends AbstractProcessor {
	AndroidIconsProcessor(super.config);

	@override
	void execute() {
		const resolver = IconResolver();

		for (final entry in config.androidFlavors.entries) {
			final flavorName = entry.key;
			final flavor = entry.value;
			if (!resolver.hasIconConfig(flavor)) {
				continue;
			}
			if (!resolver.iconSourcesReady(flavor, ios: false)) {
				stdout.writeln(
					'⚠️  Skipping android:icons for $flavorName: icon source files not found',
				);
				continue;
			}

			final layers = resolver.adaptiveLayers(flavor);
			final legacySource = resolver.resolveFlatLauncherSource(
				flavor,
				flavorName: flavorName,
				ios: false,
			);

			final processors = <AbstractProcessor>[
				AndroidIconProcessor(
					legacySource,
					flavorName,
					config: config,
				),
			];

			if (layers != null) {
				processors.addAll([
					AndroidAdaptiveIconXmlProcessor(
						flavorName,
						includeMonochrome: resolver.monochromeSourceReady(flavor),
						config: config,
					),
					AndroidAdaptiveIconsProcessor(
						layers.foreground,
						layers.background,
						flavorName,
						config: config,
					),
				]);
			}

			final monochrome = resolver.monochromePath(flavor);
			if (monochrome != null && resolver.monochromeSourceReady(flavor)) {
				processors.add(
					AndroidMonochromeProcessor(
						monochrome,
						flavorName,
						config: config,
					),
				);
			}

			QueueProcessor(processors, config: config).execute();
		}
	}

	@override
	String toString() => 'AndroidIconsProcessor';
}
