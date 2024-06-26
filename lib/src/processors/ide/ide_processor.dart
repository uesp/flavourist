import 'package:flavourist/src/parser/models/enums.dart';
import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/processors/commons/abstract_processor.dart';
import 'package:flavourist/src/processors/ide/idea/idea_run_configurations_processor.dart';
import 'package:flavourist/src/processors/ide/vscode/vscode_launch_file_processor.dart';
import 'package:flavourist/src/utils/constants.dart';

class IDEProcessor extends AbstractProcessor {
  final AbstractProcessor? _processor;

  IDEProcessor({
    required Flavourist config,
  })  : _processor = initProcessor(config),
        super(config);

  @override
  void execute() {
    _processor?.execute();
  }

  @override
  String toString() {
    return 'IDEProcessor: ${config.ide == null ? 'Skipping IDE file generation' : super.toString()}';
  }

  static initProcessor(Flavourist config) {
    if (config.ide != null) {
      switch (config.ide) {
        case IDE.idea:
          return IdeaRunConfigurationsProcessor(
            Constants.ideaLaunchpath,
            config: config,
          );
        case IDE.vscode:
          return VSCodeLaunchFileProcessor(config: config);
        default:
          break;
      }
    }
  }
}
