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

import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/processors/android/android_build_gradle_processor.dart';
import 'package:flavourist/src/processors/android/android_dummy_assets_processor.dart';
import 'package:flavourist/src/processors/android/android_manifest_processor.dart';
import 'package:flavourist/src/processors/android/icons/android_icons_processor.dart';
import 'package:flavourist/src/processors/commons/abstract_processor.dart';
import 'package:flavourist/src/processors/commons/copy_file_processor.dart';
import 'package:flavourist/src/processors/commons/delete_file_processor.dart';
import 'package:flavourist/src/processors/commons/download_file_processor.dart';
import 'package:flavourist/src/processors/commons/dynamic_file_string_processor.dart';
import 'package:flavourist/src/processors/commons/existing_file_string_processor.dart';
import 'package:flavourist/src/processors/commons/queue_processor.dart';
import 'package:flavourist/src/processors/commons/unzip_file_processor.dart';
import 'package:flavourist/src/processors/darwin/darwin_schemas_processor.dart';
import 'package:flavourist/src/processors/darwin/podfile_processor.dart';
import 'package:flavourist/src/processors/flutter/target/flutter_targets_file_processor.dart';
import 'package:flavourist/src/processors/google/firebase/firebase_processor.dart';
import 'package:flavourist/src/processors/huawei/agconnect/agconnect_processor.dart';
import 'package:flavourist/src/processors/ide/ide_processor.dart';
import 'package:flavourist/src/processors/ios/build_configuration/ios_build_configurations_targets_processor.dart';
import 'package:flavourist/src/processors/ios/dummy_assets/ios_dummy_assets_targets_processor.dart';
import 'package:flavourist/src/processors/ios/icons/ios_icons_processor.dart';
import 'package:flavourist/src/processors/ios/ios_plist_processor.dart';
import 'package:flavourist/src/processors/ios/launch_screen/ios_targets_launchscreen_file_processor.dart';
import 'package:flavourist/src/processors/ios/xcconfig/ios_xcconfig_targets_file_processor.dart';
import 'package:flavourist/src/processors/macos/build_configuration/macos_build_configurations_targets_processor.dart';
import 'package:flavourist/src/processors/macos/configs/macos_configs_targets_file_processor.dart';
import 'package:flavourist/src/processors/macos/dummy_assets/macos_dummy_assets_targets_processor.dart';
import 'package:flavourist/src/processors/macos/icons/macos_icons_processor.dart';
import 'package:flavourist/src/processors/macos/macos_plist_processor.dart';
import 'package:flavourist/src/processors/macos/xcconfig/macos_xcconfig_targets_file_processor.dart';
import 'package:flavourist/src/utils/constants.dart';

class Processor extends AbstractProcessor<void> {
	final Map<String, AbstractProcessor<void> Function()> _availableProcessors;

	final Flavourist _flavorizr;
	static const List<String> defaultInstructionSet = [
		// Prepare
		'assets:download',
		'assets:extract',

		// Android
		'android:androidManifest',
		'android:buildGradle',
		'android:dummyAssets',
		'android:icons',
		'android:adaptiveIcons',

		// iOS
		'ios:podfile',
		'ios:xcconfig',
		'ios:buildTargets',
		'ios:schema',
		'ios:dummyAssets',
		'ios:icons',
		'ios:plist',
		'ios:launchScreen',

		// macOS
		'macos:podfile',
		'macos:xcconfig',
		'macos:configs',
		'macos:buildTargets',
		'macos:schema',
		'macos:dummyAssets',
		'macos:icons',
		'macos:plist',

		// Cleanup
		'assets:clean',

		// IDE
		'ide:config'
	];

	Processor(this._flavorizr)
		: _availableProcessors = _initAvailableProcessors(_flavorizr),
			super(_flavorizr);

	@override
	void execute() async {
			final instructions = List.from(
				_flavorizr.instructions ?? defaultInstructionSet)
			..removeWhere((instruction) =>
				!_flavorizr.androidFlavorsAvailable &&
				instruction.startsWith('android'))
			..removeWhere((instruction) =>
				!_flavorizr.iosFlavorsAvailable && instruction.startsWith('ios'))
			..removeWhere((instruction) =>
				!_flavorizr.macosFlavorsAvailable && instruction.startsWith('macos'));

			stdout.writeln('🔵 Generating flavours...\n');

			for (String instruction in instructions) {
			stdout.writeln('⭕️ Executing task $instruction...');

			AbstractProcessor? processor = _availableProcessors[instruction]?.call();
			if (processor == null) stderr.writeln('🔴 Cannot execute processor $instruction');

			await processor?.execute();

			if (processor != null) stdout.writeln('🟢 Task completed! \n');
		}
		stdout.writeln('✅ Files generated!');
	}

	static Map<String, AbstractProcessor<void> Function()>
		_initAvailableProcessors(
		Flavourist flavourist,
	) {
		return {
		// Commons
		'assets:download': () => DownloadFileProcessor(
				K.assetsZipPath,
				config: flavourist,
			),
		'assets:extract': () => UnzipFileProcessor(
				K.assetsZipPath,
				K.tempPath,
				config: flavourist,
			),
		'assets:clean': () => QueueProcessor(
				[
				DeleteFileProcessor(
					K.assetsZipPath,
					config: flavourist,
				),
				DeleteFileProcessor(
					K.tempPath,
					config: flavourist,
				),
				],
				config: flavourist,
			),

		// Android
		'android:androidManifest': () => ExistingFileStringProcessor(
				K.androidManifestPath,
				AndroidManifestProcessor(config: flavourist),
				config: flavourist,
			),
		'android:buildGradle': () => ExistingFileStringProcessor(
				K.androidBuildGradlePath,
				AndroidBuildGradleProcessor(
				config: flavourist,
				),
				config: flavourist,
			),
		'android:dummyAssets': () => AndroidDummyAssetsProcessor(
				K.tempAndroidResPath,
				K.androidSrcPath,
				config: flavourist,
			),
		'android:icons': () => AndroidIconsProcessor(
				config: flavourist,
			),

		//Flutter
		'flutter:app': () => CopyFileProcessor(
				K.tempFlutterAppPath,
				K.flutterAppPath,
				config: flavourist,
			),
		'flutter:main': () => CopyFileProcessor(
				K.tempFlutterMainPath,
				K.flutterMainPath,
				config: flavourist,
			),
		'flutter:targets': () => FlutterTargetsFileProcessor(
				K.tempFlutterMainTargetPath,
				K.flutterPath,
				config: flavourist,
			),

		//iOS
		'ios:podfile': () => DynamicFileStringProcessor(
				K.iOSPodfilePath,
				PodfileProcessor(
				flavors: flavourist.iosFlavors.keys.toList(growable: false),
				config: flavourist,
				),
				config: flavourist,
			),
		'ios:xcconfig': () => IOSXCConfigTargetsFileProcessor(
				'ruby',
				K.tempDarwinAddFileScriptPath,
				K.iOSRunnerProjectPath,
				K.iOSFlutterPath,
				config: flavourist,
			),
		'ios:buildTargets': () => IOSBuildConfigurationsTargetsProcessor(
				'ruby',
				K.tempDarwinAddBuildConfigurationScriptPath,
				K.iOSRunnerProjectPath,
				K.iOSFlutterPath,
				config: flavourist,
			),
		'ios:schema': () => DarwinSchemasProcessor(
				'ruby',
				K.tempDarwinCreateSchemeScriptPath,
				K.iOSRunnerProjectPath,
				config: flavourist,
			),
		'ios:dummyAssets': () => IOSDummyAssetsTargetsProcessor(
				K.tempiOSAssetsPath,
				K.iOSAssetsPath,
				config: flavourist,
			),
		'ios:icons': () => IOSIconsProcessor(
				config: flavourist,
			),
		'ios:plist': () => ExistingFileStringProcessor(
				K.iOSPListPath,
				IOSPListProcessor(config: flavourist),
				config: flavourist,
			),
		'ios:launchScreen': () => IOSTargetsLaunchScreenFileProcessor(
				'ruby',
				K.tempDarwinAddFileScriptPath,
				K.iOSRunnerProjectPath,
				K.tempiOSLaunchScreenPath,
				K.iOSRunnerPath,
				config: flavourist,
			),

		// MacOS
		'macos:podfile': () => DynamicFileStringProcessor(
				K.macOSPodfilePath,
				PodfileProcessor(
				flavors: flavourist.macosFlavors.keys.toList(growable: false),
				config: flavourist,
				),
				config: flavourist,
			),
		'macos:xcconfig': () => MacOSXCConfigTargetsFileProcessor(
				K.macOSFlutterPath,
				config: flavourist,
			),
		'macos:configs': () => MacOSConfigsTargetsFileProcessor(
				'ruby',
				K.tempDarwinAddFileScriptPath,
				K.macOSRunnerProjectPath,
				K.macOSConfigsPath,
				config: flavourist,
			),
		'macos:buildTargets': () => MacOSBuildConfigurationsTargetsProcessor(
				'ruby',
				K.tempDarwinAddBuildConfigurationScriptPath,
				K.macOSRunnerProjectPath,
				K.macOSConfigsPath,
				config: flavourist,
			),
		'macos:schema': () => DarwinSchemasProcessor(
				'ruby',
				K.tempDarwinCreateSchemeScriptPath,
				K.macOSRunnerProjectPath,
				config: flavourist,
			),
		'macos:dummyAssets': () => MacOSDummyAssetsTargetsProcessor(
				K.tempMacOSAssetsPath,
				K.macOSAssetsPath,
				config: flavourist,
			),
		'macos:icons': () => MacOSIconsProcessor(
				config: flavourist,
			),
		'macos:plist': () => ExistingFileStringProcessor(
				K.macOSPlistPath,
				MacOSPListProcessor(config: flavourist),
				config: flavourist,
			),

		// Google
		'google:firebase': () => FirebaseProcessor(
				process: 'ruby',
				androidDestination: K.androidSrcPath,
				iosDestination: K.iOSRunnerPath,
				macosDestination: K.macOSRunnerPath,
				addFileScript: K.tempDarwinAddFileScriptPath,
				iosRunnerProject: K.iOSRunnerProjectPath,
				macosRunnerProject: K.macOSRunnerProjectPath,
				firebaseScript: K.tempDarwinAddFirebaseBuildPhaseScriptPath,
				iosGeneratedFirebaseScriptPath: K.iOSFirebaseScriptPath,
				macosGeneratedFirebaseScriptPath: K.macOSFirebaseScriptPath,
				config: flavourist,
			),

		// Huawei
		'huawei:agconnect': () => AGConnectProcessor(
				destination: K.androidSrcPath,
				config: flavourist,
			),

		// IDE
		'ide:config': () => IDEProcessor(
				config: flavourist,
			),
		};
	}
}
