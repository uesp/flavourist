import 'package:flavourist/src/parser/models/flavors/darwin.dart';
import 'package:flavourist/src/parser/models/flavors/flavor.dart';
import 'package:flavourist/src/parser/models/flavors/flavor_icon.dart';
import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/utils/icon_resolver.dart';
import 'package:test/test.dart';

void main() {
	group('FlavorIcon', () {
		test('parses map from json', () {
			final icon = flavorIconFromJson({
				'foreground': 'assets/fg.png',
				'background': 'assets/bg.png',
				'monochrome': 'assets/mono.png',
			});
			expect(icon?.foreground, 'assets/fg.png');
			expect(icon?.background, 'assets/bg.png');
			expect(icon?.monochrome, 'assets/mono.png');
			expect(icon?.hasAdaptiveLayers, isTrue);
		});

		test('legacy string icon becomes foreground only', () {
			final icon = flavorIconFromJson('assets/legacy.png');
			expect(icon?.foreground, 'assets/legacy.png');
			expect(icon?.hasAdaptiveLayers, isFalse);
		});
	});

	group('Darwin applicationID', () {
		test('ios block accepts applicationID', () {
			const yaml = '''
flavors:
  uesp:
    name: UESP
    applicationID: com.example.app
    platforms: [ios]
    ios:
      applicationID: com.example.ios
''';
			final config = Flavourist.parse(yaml);
			expect(config.iosFlavors['uesp']?.ios?.bundleId, 'com.example.ios');
		});
	});

	group('IconResolver', () {
		test('resolveFlatLauncherSource uses ios override', () {
			const resolver = IconResolver();
			final flavor = Flavor(
				applicationID: 'com.app',
				name: 'Test',
				platforms: ['ios'],
				icon: const FlavorIcon(
					foreground: 'fg.png',
					background: 'bg.png',
				),
				ios: Darwin(bundleId: 'com.ios', icon: 'ios_override.png'),
			);
			expect(
				resolver.resolveFlatLauncherSource(
					flavor,
					flavorName: 'test',
					ios: true,
				),
				'ios_override.png',
			);
		});
	});
}
