import 'package:flavourist/src/processors/commons/string_processor.dart';

class AndroidGenerateIclauncherXmlProcessor extends StringProcessor {
  AndroidGenerateIclauncherXmlProcessor({
    required super.config,
  });

  @override
  String execute() {
    return '<?xml version="1.0" encoding="utf-8"?>'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">'
        '<background android:drawable="@drawable/ic_launcher_background" />'
        '<foreground android:drawable="@drawable/ic_launcher_foreground" />'
        '</adaptive-icon>';
  }

  @override
  String toString() => 'AndroidGenerateIclauncherXmlProcessor';
}
