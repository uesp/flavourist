import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/processors/commons/image_resizer_processor.dart';
import 'package:flavourist/src/processors/commons/queue_processor.dart';
import 'package:flavourist/src/utils/constants.dart';
import 'package:sprintf/sprintf.dart';

class AndroidAdaptiveIconProcessor extends QueueProcessor {
  String foregroundSource;
  String backgroundSource;
  String sourceSetName;
  String folder;
  Size size;

  AndroidAdaptiveIconProcessor(
    this.foregroundSource,
    this.backgroundSource,
    this.sourceSetName,
    this.folder,
    this.size, {
    required Flavourist config,
  }) : super([
          ImageResizerProcessor(
            foregroundSource,
            sprintf(Constants.androidAdaptiveIconForegroundPath, [
              sourceSetName,
              folder,
            ]),
            size,
            config: config,
          ),
          ImageResizerProcessor(
            backgroundSource,
            sprintf(Constants.androidAdaptiveIconBackgroundPath, [
              sourceSetName,
              folder,
            ]),
            size,
            config: config,
          ),
        ], config: config);

  @override
  String toString() => 'AndroidAdaptiveIconProcessor';
}
