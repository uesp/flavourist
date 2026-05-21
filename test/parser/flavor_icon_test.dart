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
				'foregroundScale': 1.5,
			});
			expect(icon?.foreground, 'assets/fg.png');
			expect(icon?.background, 'assets/bg.png');
			expect(icon?.monochrome, 'assets/mono.png');
			expect(icon?.overlay, 'assets/overlay.png');
			expect(icon?.foregroundScale, 1.5);
			expect(icon?.effectiveForegroundScale, 1.5);
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
				foregroundScale: 1.0,
			);
			const override = FlavorIcon(
				overlay: 'badge.png',
				foregroundScale: 1.5,
			);
			final merged = base.merge(override);
			expect(merged.foreground, 'fg.png');
			expect(merged.overlay, 'badge.png');
			expect(merged.foregroundScale, 1.5);
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

	group('Platform applicationID', () {
		test('android block accepts applicationID override', () {
			const yaml = '''
flavors:
  uesp:
    name: UESP
    applicationID: com.example.app
    platforms: [android]
    android:
      applicationID: com.example.android
''';
			final config = Flavourist.parse(yaml);
			expect(
				config.androidFlavors['uesp']?.android?.applicationID,
				'com.example.android',
			);
		});

		test('android block inherits flavor applicationID', () {
			const yaml = '''
flavors:
  uesp:
    name: UESP
    applicationID: com.example.app
    platforms: [android]
    android:
      icon:
        foregroundScale: 1.5
''';
			final config = Flavourist.parse(yaml);
			expect(
				config.androidFlavors['uesp']?.android?.applicationID,
				'com.example.app',
			);
		});

		test('ios block accepts applicationID override', () {
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
			expect(config.iosFlavors['uesp']?.ios?.applicationID, 'com.example.ios');
		});

		test('ios block inherits flavor applicationID', () {
			const yaml = '''
flavors:
  uesp:
    name: UESP
    applicationID: com.example.app
    platforms: [ios]
    ios:
      icon:
        foregroundScale: 1.5
''';
			final config = Flavourist.parse(yaml);
			expect(
				config.iosFlavors['uesp']?.ios?.applicationID,
				'com.example.app',
			);
		});

		test('macos block inherits flavor applicationID', () {
			const yaml = '''
flavors:
  uesp:
    name: UESP
    applicationID: com.example.app
    platforms: [macos]
    macos:
      icon:
        foregroundScale: 1.5
''';
			final config = Flavourist.parse(yaml);
			expect(
				config.macosFlavors['uesp']?.macos?.applicationID,
				'com.example.app',
			);
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
				ios: Darwin(
					applicationID: 'com.ios',
					icon: const PlatformIconConfig(flatPath: 'ios_override.png'),
				),
			);
			expect(
				resolver.resolveFlatLauncherSource(
					flavor,
					flavorName: 'test',
					variant: IconVariant.release,
					platform: IconPlatform.ios,
				),
				'ios_override.png',
			);
		});

		test('resolveIcon merges platform foregroundScale', () {
			const resolver = IconResolver();
			final flavor = Flavor(
				applicationID: 'com.app',
				name: 'Test',
				platforms: ['ios', 'macos'],
				icon: const FlavorIcon(
					foreground: 'fg.png',
					background: 'bg.png',
					foregroundScale: 1.0,
				),
				ios: Darwin(
					applicationID: 'com.ios',
					icon: const PlatformIconConfig(
						partial: FlavorIcon(foregroundScale: 1.5),
					),
				),
				macos: Darwin(
					applicationID: 'com.macos',
					icon: const PlatformIconConfig(
						partial: FlavorIcon(foregroundScale: 0.5),
					),
				),
			);
			expect(
				resolver.resolveIcon(
					flavor,
					IconVariant.release,
					platform: IconPlatform.ios,
				)?.foregroundScale,
				1.5,
			);
			expect(
				resolver.resolveIcon(
					flavor,
					IconVariant.release,
					platform: IconPlatform.macos,
				)?.foregroundScale,
				0.5,
			);
		});

		test('resolveIcon merges variant foregroundScale onto base', () {
			const resolver = IconResolver();
			final flavor = Flavor(
				applicationID: 'com.app',
				name: 'Test',
				platforms: ['android'],
				icon: const FlavorIcon(
					foreground: 'fg.png',
					background: 'bg.png',
				),
				betaIcon: const FlavorIcon(foregroundScale: 1.25),
			);
			expect(
				resolver.resolveIcon(flavor, IconVariant.beta)?.foregroundScale,
				1.25,
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
