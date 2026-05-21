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
import 'package:flavourist/src/processors/ios/icons/ios_icon_target_processor.dart';
import 'package:flavourist/src/utils/icon_resolver.dart';
import 'package:flavourist/src/utils/icon_variant.dart';

class IOSIconsProcessor extends AbstractProcessor {
	IOSIconsProcessor(super.config);

	@override
	void execute() {
		const resolver = IconResolver();
		final processors = <AbstractProcessor>[];

		for (final entry in config.iosFlavors.entries) {
			final flavorName = entry.key;
			final flavor = entry.value;
			if (!resolver.hasIconConfig(flavor)) {
				continue;
			}

			for (final variant in IconResolver.variantsToGenerate(flavor)) {
				if (!resolver.iconSourcesReady(
					flavor,
					variant,
					platform: IconPlatform.ios,
				)) {
					stdout.writeln(
						'⚠️  Skipping ios:icons for $flavorName (${variant.name}): icon source files not found',
					);
					continue;
				}

				final source = resolver.resolveFlatLauncherSource(
					flavor,
					flavorName: flavorName,
					variant: variant,
					platform: IconPlatform.ios,
				);
				final assetPrefix = resolver.darwinAssetPrefix(flavorName, variant);
				processors.add(
					IOSIconTargetProcessor(
						source,
						assetPrefix,
						config: config,
					),
				);
			}
		}

		if (processors.isNotEmpty) {
			QueueProcessor(processors, config: config).execute();
		}
	}

	@override
	String toString() => 'IOSIconsProcessor';
}
