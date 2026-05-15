import 'package:flavourist/src/parser/models/flavors/darwin/enums.dart';
import 'package:flavourist/src/utils/flavor_display_name.dart';
import 'package:test/test.dart';

void main() {
	group('displayNameForTarget', () {
		test('release has no suffix', () {
			expect(
				displayNameForTarget('UESPWiki', Target.release),
				'UESPWiki',
			);
		});

		test('debug beta profile append build type', () {
			expect(
				displayNameForTarget('UESPWiki', Target.debug),
				'UESPWiki (Debug)',
			);
			expect(
				displayNameForTarget('UESPWiki', Target.beta),
				'UESPWiki (Beta)',
			);
			expect(
				displayNameForTarget('UESPWiki', Target.profile),
				'UESPWiki (Profile)',
			);
		});
	});

	group('launchBuildModes', () {
		test('order is release beta debug profile', () {
			expect(
				launchBuildModes,
				['release', 'beta', 'debug', 'profile'],
			);
		});

		test('buildScriptFlagForMode prefixes dash', () {
			expect(buildScriptFlagForMode('beta'), '--beta');
		});
	});

	group('launchNameSuffixForMode', () {
		test('release has empty suffix', () {
			expect(launchNameSuffixForMode('release'), '');
		});

		test('non-release modes have suffix', () {
			expect(launchNameSuffixForMode('debug'), ' (Debug)');
			expect(launchNameSuffixForMode('beta'), ' (Beta)');
		});
	});
}
