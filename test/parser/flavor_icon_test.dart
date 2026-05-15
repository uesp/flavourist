import 'package:flavourist/src/parser/models/flavors/darwin.dart';
import 'package:flavourist/src/parser/models/flavors/flavor.dart';
import 'package:flavourist/src/parser/models/flavors/flavor_icon.dart';
import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/utils/icon_resolver.dart';
import 'package:flavourist/src/utils/icon_variant.dart';
import 'package:test/test.dart';

void main() {
	group('FlavorIcon', () {
		test('parses map from json', () {
			final icon = flavorIconFromJson({
				'foreground': 'assets/fg.png',
				'background': 'assets/bg.png',
				'monochrome': 'assets/mono.png',
				'overlay': 'assets/overlay.png',
			});
			expect(icon?.foreground, 'assets/fg.png');
			expect(icon?.background, 'assets/bg.png');
			expect(icon?.monochrome, 'assets/mono.png');
			expect(icon?.overlay, 'assets/overlay.png');
			expect(icon?.hasAdaptiveLayers, isTrue);
			expect(icon?.hasOverlay, isTrue);
		});

		test('legacy string icon becomes foreground only', () {
			final icon = flavorIconFromJson('assets/legacy.png');
			expect(icon?.foreground, 'assets/legacy.png');
			expect(icon?.hasAdaptiveLayers, isFalse);
		});

		test('merge applies override fields', () {
			const base = FlavorIcon(
				foreground: 'fg.png',
				background: 'bg.png',
			);
			const override = FlavorIcon(overlay: 'badge.png');
			final merged = base.merge(override);
			expect(merged.foreground, 'fg.png');
			expect(merged.overlay, 'badge.png');
		});
	});

	group('Flavor variant blocks', () {
		test('parses debug beta profile icon blocks', () {
			const yaml = '''
flavors:
  test:
    name: Test
    applicationID: com.test
    icon:
      foreground: fg.png
    debug:
      icon:
        overlay: debug.png
    beta:
      icon:
        overlay: beta.png
    profile:
      icon:
        overlay: profile.png
''';
			final config = Flavourist.parse(yaml);
			final flavor = config.flavors['test']!;
			expect(flavor.debugIcon?.overlay, 'debug.png');
			expect(flavor.betaIcon?.overlay, 'beta.png');
			expect(flavor.profileIcon?.overlay, 'profile.png');
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
					variant: IconVariant.release,
					ios: true,
				),
				'ios_override.png',
			);
		});

		test('variantsToGenerate lists configured variants', () {
			final flavor = Flavor(
				applicationID: 'com.app',
				name: 'Test',
				platforms: ['android'],
				icon: const FlavorIcon(foreground: 'fg.png'),
				debugIcon: const FlavorIcon(overlay: 'd.png'),
				profileIcon: const FlavorIcon(overlay: 'p.png'),
			);
			expect(
				IconResolver.variantsToGenerate(flavor).toList(),
				[
					IconVariant.release,
					IconVariant.debug,
					IconVariant.profile,
				],
			);
		});

		test('androidSourceSetName and darwinAssetPrefix', () {
			const resolver = IconResolver();
			expect(
				resolver.androidSourceSetName('uesp', IconVariant.debug),
				'uespDebug',
			);
			expect(
				resolver.darwinAssetPrefix('uesp', IconVariant.profile),
				'uespProfile',
			);
		});

		test('resolveIcon merges variant onto base', () {
			const resolver = IconResolver();
			final flavor = Flavor(
				applicationID: 'com.app',
				name: 'Test',
				platforms: ['android'],
				icon: const FlavorIcon(
					foreground: 'fg.png',
					background: 'bg.png',
				),
				debugIcon: const FlavorIcon(overlay: 'debug.png'),
			);
			final merged = resolver.resolveIcon(flavor, IconVariant.debug)!;
			expect(merged.foreground, 'fg.png');
			expect(merged.overlay, 'debug.png');
		});
	});
}
