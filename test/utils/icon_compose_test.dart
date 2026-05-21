import 'dart:io';

import 'package:flavourist/src/utils/constants.dart';
import 'package:flavourist/src/utils/icon_compose.dart';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
	group('IconCompose', () {
		late Directory tempDir;

		setUp(() {
			tempDir = Directory.systemTemp.createTempSync('flavourist_icon_compose_');
			Constants.tempPath = tempDir.path;
		});

		tearDown(() {
			if (tempDir.existsSync()) {
				tempDir.deleteSync(recursive: true);
			}
		});

		test('composeAdaptiveIcon centers oversized scaled foreground', () {
			final backgroundPath = '${tempDir.path}/bg.png';
			final foregroundPath = '${tempDir.path}/fg.png';
			_writeSolidImage(backgroundPath, 1024, color: ColorRgba8(255, 0, 0, 255));
			_writeMarkerImage(foregroundPath, 1024);

			final output = IconCompose.composeAdaptiveIcon(
				foreground: foregroundPath,
				background: backgroundPath,
				foregroundScale: 1.5,
				flavorName: 'test',
				outputSuffix: 'release',
			);

			final composed = decodeImage(output.readAsBytesSync())!;
			expect(composed.width, IconCompose.composeSize);
			expect(composed.height, IconCompose.composeSize);

			final center = composed.getPixel(512, 512);
			final corner = composed.getPixel(32, 32);
			expect(center.g, 255);
			expect(corner.g, 0);
			expect(corner.r, 255);
			expect(center.r, lessThan(corner.r));
		});
	});
}

void _writeSolidImage(String path, int size, {required Color color}) {
	final image = Image(width: size, height: size, numChannels: 4);
	fill(image, color: color);
	File(path).writeAsBytesSync(encodePng(image));
}

void _writeMarkerImage(String path, int size) {
	final image = Image(width: size, height: size, numChannels: 4);
	fill(image, color: ColorRgba8(0, 0, 0, 0));
	fillRect(
		image,
		x1: size ~/ 2 - 64,
		y1: size ~/ 2 - 64,
		x2: size ~/ 2 + 64,
		y2: size ~/ 2 + 64,
		color: ColorRgba8(0, 255, 0, 255),
	);
	File(path).writeAsBytesSync(encodePng(image));
}
