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

import 'package:flavourist/src/processors/commons/abstract_processor.dart';
import 'package:flavourist/src/utils/constants.dart';

/// Patches flavorizr Ruby scripts after zip extract (Beta build configuration support).
class DarwinScriptsPatchProcessor extends AbstractProcessor {
	DarwinScriptsPatchProcessor(super.config);

	static const _addBuildConfigurationRuby = '''
require 'xcodeproj'
require 'json'
require 'base64'

if ARGV.length != 5
  puts 'We need exactly five arguments'
  exit
end

project_path = ARGV[0]
file_path = ARGV[1]
flavor = ARGV[2]
mode = ARGV[3]
additional_build_settings = JSON.parse(Base64.decode64(ARGV[4]))

project = Xcodeproj::Project.open(project_path)
config_name = "#{mode}-#{flavor}"
config_mode = mode.downcase == 'debug' ? :debug : :release
file_ref = project.files.detect { |file| file.path == file_path }

base_mode = case mode
            when 'Beta' then 'Release'
            when 'Profile' then 'Profile'
            when 'Debug' then 'Debug'
            when 'Release' then 'Release'
            else 'Release'
            end

base_config = project.build_configuration_list.build_configurations.detect { |config| config.name == base_mode }
if base_config.nil?
  puts "Could not find base configuration '#{base_mode}' in #{project_path}"
  exit 1
end

build_config = project.add_build_configuration(config_name, config_mode)
build_config.base_configuration_reference = file_ref
build_config.build_settings = base_config.build_settings.clone
build_config.build_settings = build_config.build_settings.merge(additional_build_settings)

project.save
''';

	@override
	void execute() {
		final destDir = Directory(Constants.tempDarwinScriptsPath);
		if (!destDir.existsSync()) {
			destDir.createSync(recursive: true);
		}
		File('${destDir.path}/add_build_configuration.rb')
			.writeAsStringSync(_addBuildConfigurationRuby);
	}

	@override
	String toString() => 'DarwinScriptsPatchProcessor';
}
