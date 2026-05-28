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

import 'package:flavourist/src/parser/models/flavors/darwin/enums.dart';

/// Launch configurations and build-script mode picker order (per flavor).
const List<String> launchBuildModes = [
	'release',
	'debug',
	'beta',
	'profile',
];

/// ``--release``, ``--beta``, etc. for [scripts/build.sh] and VS Code task inputs.
String buildScriptFlagForMode(String mode) => '--$mode';

/// Display name for a flavor, with build-type suffix except [Target.release].
String displayNameForTarget(String baseName, Target target) {
	switch (target) {
		case Target.debug:
			return '$baseName (Debug)';
		case Target.profile:
			return '$baseName (Profile)';
		case Target.beta:
			return '$baseName (Beta)';
		case Target.release:
			return baseName;
	}
}

/// VS Code launch / build-script mode string: debug, profile, beta, release.
String displayNameForMode(String baseName, String mode) {
	switch (mode) {
		case 'debug':
			return '$baseName (Debug)';
		case 'profile':
			return '$baseName (Profile)';
		case 'beta':
			return '$baseName (Beta)';
		default:
			return baseName;
	}
}

/// Suffix for launch configuration names, e.g. `` (Debug) ``; empty for release.
String launchNameSuffixForMode(String mode) {
	switch (mode) {
		case 'debug':
			return ' (Debug)';
		case 'profile':
			return ' (Profile)';
		case 'beta':
			return ' (Beta)';
		default:
			return '';
	}
}
