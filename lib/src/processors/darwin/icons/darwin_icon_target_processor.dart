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
import 'package:flavourist/src/processors/commons/abstract_processor.dart';
import 'package:flavourist/src/processors/commons/image_resizer_processor.dart';
import 'package:flavourist/src/processors/commons/queue_processor.dart';
import 'package:flavourist/src/processors/darwin/icons/darwin_app_iconset_manifest.dart';
import 'package:sprintf/sprintf.dart';

abstract class DarwinIconTargetProcessor extends AbstractProcessor<void> {
  DarwinIconTargetProcessor(
    String source, {
    required String flavorName,
    required Map<String, Size> iconSet,
    required String appIconPath,
    required Flavourist config,
    required this.ios,
  })  : _assetPrefix = flavorName,
        _appIconPath = appIconPath,
        _resizeQueue = QueueProcessor(
          iconSet
              .map(
                (fileName, size) => MapEntry(
                  fileName,
                  ImageResizerProcessor(
                    source,
                    sprintf(appIconPath, [flavorName, fileName]),
                    size,
                    config: config,
                  ),
                ),
              )
              .values,
          config: config,
        ),
        super(config);

  final QueueProcessor _resizeQueue;
  final String _assetPrefix;
  final String _appIconPath;

  /// When true, writes the iOS marketing / iPhone / iPad manifest; otherwise macOS.
  final bool ios;

  @override
  void execute() {
    _resizeQueue.execute();
    final String contentsPath = sprintf(_appIconPath, [_assetPrefix, 'Contents.json']);
    File(contentsPath).writeAsStringSync(
      ios ? DarwinAppIconsetManifest.ios : DarwinAppIconsetManifest.macos,
    );
  }

  @override
  String toString() => 'DarwinIconProcessor';
}
