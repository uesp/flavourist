import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/processors/commons/image_resizer_processor.dart';
import 'package:flavourist/src/processors/commons/queue_processor.dart';
import 'package:flavourist/src/utils/constants.dart';
import 'package:sprintf/sprintf.dart';

class AndroidAdaptiveIconProcessor extends QueueProcessor {
  String foregroundSource;
  String backgroundSource;
  String flavorName;
  String folder;
  Size size;

  AndroidAdaptiveIconProcessor(
    this.foregroundSource,
    this.backgroundSource,
    this.flavorName,
    this.folder,
    this.size, {
    required Flavourist config,
  }) : super([
          ImageResizerProcessor(
            foregroundSource,
            sprintf(Constants.androidAdaptiveIconForegroundPath, [flavorName, folder]),
            size,
            config: config,
          ),
          ImageResizerProcessor(
            backgroundSource,
            sprintf(Constants.androidAdaptiveIconBackgroundPath, [flavorName, folder]),
            size,
            config: config,
          ),
        ], config: config);

  @override
  String toString() => 'AndroidAdaptiveIconProcessor';
}
