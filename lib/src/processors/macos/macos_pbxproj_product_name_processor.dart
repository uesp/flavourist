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

import 'package:flavourist/src/processors/commons/string_processor.dart';

/// CocoaPods adds per-flavor Runner target configs with ``PRODUCT_NAME = Runner``.
/// The macOS dock label is the ``.app`` bundle name ([PRODUCT_NAME]), not the menu title.
class MacOSPbxprojProductNameProcessor extends StringProcessor {
	MacOSPbxprojProductNameProcessor({
		super.input,
		required super.config,
	});

	static const _runnerProductName = 'PRODUCT_NAME = Runner;';
	static const _bundleProductName = r'PRODUCT_NAME = "$(BUNDLE_NAME)";';

	@override
	String execute() {
		return input!.replaceAll(_runnerProductName, _bundleProductName);
	}

	@override
	String toString() => 'MacOSPbxprojProductNameProcessor';
}
