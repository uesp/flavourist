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
import 'package:flavourist/src/parser/models/flavors/flavor_icon.dart';
import 'package:flavourist/src/utils/constants.dart';
import 'package:image/image.dart';

/// Composes Android adaptive [foreground] and [background] into a square launcher PNG.
///
/// [foreground] is scaled by [foregroundScale], then composited centered on a
/// [composeSize] canvas. [background] is resized to fill the canvas.
class IconCompose {
	static const int composeSize = 1024;

	static File composeAdaptiveIcon({
		required String foreground,
		required String background,
		String? overlay,
		double foregroundScale = FlavorIcon.DEFAULT_FOREGROUND_SCALE,
		required String flavorName,
		required String outputSuffix,
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

		final scaledForeground = _scaleImage(fgImage, foregroundScale);
		_compositeCentered(canvas, scaledForeground);

		if (overlay != null && overlay.isNotEmpty) {
			_applyOverlayOnImage(canvas, overlay);
		}

		return _writeCanvas(
			canvas,
			'${flavorName}_$outputSuffix',
		);
	}

	/// Scales and optionally overlays [foreground], writing a temp PNG for adaptive layers.
	static File prepareForeground({
		required String foreground,
		String? overlay,
		double foregroundScale = FlavorIcon.DEFAULT_FOREGROUND_SCALE,
		required String flavorName,
		required String outputSuffix,
	}) {
		final foregroundFile = File(foreground);
		if (!foregroundFile.existsSync()) {
			throw FileNotFoundException(foreground);
		}

		final fgImage = decodeImage(foregroundFile.readAsBytesSync());
		if (fgImage == null) {
			throw FileNotFoundException(foreground);
		}

		final scaledForeground = _scaleImage(fgImage, foregroundScale);
		final canvas = Image(
			width: composeSize,
			height: composeSize,
			numChannels: 4,
		);
		fill(canvas, color: ColorRgba8(0, 0, 0, 0));
		_compositeCentered(canvas, scaledForeground);
		if (overlay != null && overlay.isNotEmpty) {
			_applyOverlayOnImage(canvas, overlay);
		}

		return _writeCanvas(canvas, '${flavorName}_fg_$outputSuffix');
	}

	static void _compositeCentered(Image canvas, Image layer) {
		final canvasW = canvas.width;
		final canvasH = canvas.height;
		final layerW = layer.width;
		final layerH = layer.height;

		if (layerW <= canvasW && layerH <= canvasH) {
			compositeImage(
				canvas,
				layer,
				dstX: (canvasW - layerW) ~/ 2,
				dstY: (canvasH - layerH) ~/ 2,
			);
			return;
		}

		final srcX = (layerW - canvasW) ~/ 2;
		final srcY = (layerH - canvasH) ~/ 2;
		compositeImage(
			canvas,
			layer,
			dstX: 0,
			dstY: 0,
			dstW: canvasW,
			dstH: canvasH,
			srcX: srcX,
			srcY: srcY,
			srcW: canvasW,
			srcH: canvasH,
		);
	}

	static Image _scaleImage(Image image, double scale) {
		if (scale == FlavorIcon.DEFAULT_FOREGROUND_SCALE) {
			return image;
		}
		return copyResize(
			image,
			width: (image.width * scale).round(),
			height: (image.height * scale).round(),
			interpolation: Interpolation.average,
		);
	}

	static void _applyOverlayOnImage(Image canvas, String overlayPath) {
		final overlayFile = File(overlayPath);
		if (!overlayFile.existsSync()) {
			throw FileNotFoundException(overlayPath);
		}

		final overlayImage = decodeImage(overlayFile.readAsBytesSync());
		if (overlayImage == null) {
			throw FileNotFoundException(overlayPath);
		}

		final resized = overlayImage.width == canvas.width &&
				overlayImage.height == canvas.height
			? overlayImage
			: copyResize(
					overlayImage,
					width: canvas.width,
					height: canvas.height,
					interpolation: Interpolation.average,
				);

		compositeImage(canvas, resized);
	}

	static File _writeCanvas(Image canvas, String nameStem) {
		final outputDir = Directory(Constants.tempPath);
		if (!outputDir.existsSync()) {
			outputDir.createSync(recursive: true);
		}
		final outputPath = '${Constants.tempPath}/$nameStem.png';
		final encoded = encodePng(canvas);
		return File(outputPath)..writeAsBytesSync(encoded);
	}
}
