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

import 'package:flavourist/src/exception/file_not_found_exception.dart';
import 'package:flavourist/src/exception/missing_required_fields_exception.dart';
import 'package:flavourist/src/exception/null_fields_exception.dart';
import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/parser/models/pubspec.dart';
import 'package:json_annotation/json_annotation.dart';

class Parser {
  final String pubspecPath;
  final String flavorizrPath;

  const Parser({
    required this.pubspecPath,
    required this.flavorizrPath,
  });

  Flavourist parse() {
    File pubspecFile = File(pubspecPath);
    File flavorizrFile = File(flavorizrPath);

    final pubspecFileExists = pubspecFile.existsSync();
    final flavorizrFileExists = flavorizrFile.existsSync();

    if (!pubspecFileExists) {
      if (!flavorizrFileExists) {
        throw FileNotFoundException(flavorizrPath);
      } else {
        throw FileNotFoundException(pubspecPath);
      }
    }

    try {
      if (flavorizrFileExists) {
        final yaml = flavorizrFile.readAsStringSync();
        return Flavourist.parse(yaml);
      } else {
        final yaml = pubspecFile.readAsStringSync();
        return Pubspec.parse(yaml).flavorizr;
      }
    } on DisallowedNullValueException catch (e) {
      throw NullFieldsException(e.keysWithNullValues);
    } on MissingRequiredKeysException catch (e) {
      throw MissingRequiredFieldsException(e.missingKeys);
    }
  }
}
