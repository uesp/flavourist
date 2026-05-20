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

import 'dart:collection';

import 'package:flavourist/src/extensions/extensions_map.dart';
import 'package:flavourist/src/extensions/extensions_string.dart';
import 'package:flavourist/src/parser/models/flavors/darwin/enums.dart';
import 'package:flavourist/src/parser/models/flavors/darwin/variable.dart';
import 'package:flavourist/src/parser/models/flavors/flavor.dart';
import 'package:flavourist/src/processors/commons/string_processor.dart';
import 'package:flavourist/src/utils/flavor_display_name.dart';
import 'package:flavourist/src/utils/icon_resolver.dart';

class MacOSConfigsProcessor extends StringProcessor {
  final String _flavorName;
  final Flavor _flavor;
  final Target _target;

  MacOSConfigsProcessor(
    this._flavorName,
    this._flavor,
    this._target, {
    super.input,
    required super.config,
  });

  @override
  String execute() {
    StringBuffer buffer = StringBuffer();

    _appendIncludes(buffer);
    _appendBody(buffer);
    buffer.writeln('#include "Warnings.xcconfig"');
    return buffer.toString();
  }

  void _appendIncludes(StringBuffer buffer) {
    buffer.writeln(
        '#include "../../Flutter/$_flavorName${_target.name.capitalize}.xcconfig"');
  }

  void _appendBody(StringBuffer buffer) {
    final Map<String, Variable> variables = LinkedHashMap.from({
      'FLUTTER_TARGET': Variable(value: 'lib/res/configs/$_flavorName/main.dart'),
      'ASSET_PREFIX': Variable(
        value: const IconResolver().assetPrefixForTarget(
          _flavorName,
          _flavor,
          _target,
        ),
      ),
      'BUNDLE_NAME': Variable(
        value: displayNameForTarget(_flavor.name, _target),
      ),
      'BUNDLE_DISPLAY_NAME': Variable(
        value: displayNameForTarget(_flavor.name, _target),
      ),
      'PRODUCT_NAME': const Variable(
        value: r'$(BUNDLE_NAME)',
      ),
    })
      ..addAll(
        _flavor.macos?.variables.where((_, variable) =>
                variable.target == null || variable.target == _target) ??
            {},
      );

    buffer.writeln();
    variables.forEach((key, variable) {
      buffer.writeln('$key=${variable.value}');
    });
  }

  @override
  String toString() => 'MacOSConfigsProcessor';
}
