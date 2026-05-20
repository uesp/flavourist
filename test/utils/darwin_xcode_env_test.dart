import 'package:flavourist/src/parser/models/flavors/flavor.dart';
import 'package:flavourist/src/parser/models/flavors/flavor_icon.dart';
import 'package:flavourist/src/utils/darwin_xcode_env.dart';
import 'package:test/test.dart';

void main() {
	group('darwinXcodeToolEnvForLaunchMode', () {
		final flavor = Flavor(
			name: 'UESPWiki',
			applicationID: 'com.uesp.mobile',
			platforms: ['ios', 'macos'],
			icon: const FlavorIcon(foreground: 'fg.png'),
			betaIcon: const FlavorIcon(overlay: 'overlay.png'),
		);

		test('beta launch sets icon and bundle overrides', () {
			final env = darwinXcodeToolEnvForLaunchMode(
				flavorKey: 'uesp',
				flavor: flavor,
				launchMode: 'beta',
			);

			expect(env, isNotNull);
			expect(
				env!['FLUTTER_XCODE_ASSETCATALOG_COMPILER_APPICON_NAME'],
				'uespBetaAppIcon',
			);
			expect(env['FLUTTER_XCODE_ASSET_PREFIX'], 'uespBeta');
			expect(env['FLUTTER_XCODE_BUNDLE_DISPLAY_NAME'], 'UESPWiki (Beta)');
		});

		test('release launch has no overrides', () {
			expect(
				darwinXcodeToolEnvForLaunchMode(
					flavorKey: 'uesp',
					flavor: flavor,
					launchMode: 'release',
				),
				isNull,
			);
		});

		test('beta without beta icon config has no overrides', () {
			final releaseOnly = Flavor(
				name: 'UESPWiki',
				applicationID: 'com.uesp.mobile',
				platforms: ['ios'],
				icon: const FlavorIcon(foreground: 'fg.png'),
			);

			expect(
				darwinXcodeToolEnvForLaunchMode(
					flavorKey: 'uesp',
					flavor: releaseOnly,
					launchMode: 'beta',
				),
				isNull,
			);
		});
	});
}
