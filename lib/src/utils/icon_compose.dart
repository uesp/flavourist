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

import 'package:flavourist/src/exception/file_not_found_exception.dart';
import 'package:flavourist/src/utils/constants.dart';
import 'package:image/image.dart';

/// Composes Android adaptive [foreground] and [background] into a square launcher PNG.
///
/// [foreground] is composited at its source size (already scaled in the asset), centered
/// on a [composeSize] canvas. [background] is resized to fill the canvas.
class IconCompose {
	static const int composeSize = 1024;

	static File composeAdaptiveIcon({
		required String foreground,
		required String background,
		required String flavorName,
	}) {
		final foregroundFile = File(foreground);
		final backgroundFile = File(background);
		if (!foregroundFile.existsSync()) {
			throw FileNotFoundException(foreground);
		}
		if (!backgroundFile.existsSync()) {
			throw FileNotFoundException(background);
		}

		final bgImage = decodeImage(backgroundFile.readAsBytesSync());
		final fgImage = decodeImage(foregroundFile.readAsBytesSync());
		if (bgImage == null) {
			throw FileNotFoundException(background);
		}
		if (fgImage == null) {
			throw FileNotFoundException(foreground);
		}

		final canvas = copyResize(
			bgImage,
			width: composeSize,
			height: composeSize,
			interpolation: Interpolation.average,
		);

		final offsetX = (composeSize - fgImage.width) ~/ 2;
		final offsetY = (composeSize - fgImage.height) ~/ 2;
		compositeImage(canvas, fgImage, dstX: offsetX, dstY: offsetY);

		final outputDir = Directory(Constants.tempPath);
		if (!outputDir.existsSync()) {
			outputDir.createSync(recursive: true);
		}
		final outputPath = '${Constants.tempPath}/${flavorName}_composed_icon.png';
		final encoded = encodePng(canvas);
		return File(outputPath)..writeAsBytesSync(encoded);
	}
}
