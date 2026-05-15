import 'package:flavourist/src/parser/models/enums.dart';
import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/processors/commons/abstract_processor.dart';
import 'package:flavourist/src/processors/commons/queue_processor.dart';
import 'package:flavourist/src/processors/ide/idea/idea_run_configurations_processor.dart';
import 'package:flavourist/src/processors/ide/vscode/vscode_ide_config_processor.dart';
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
    return 'IDEProcessor: ${config.hasIdeTargets ? super.toString() : 'Skipping IDE file generation'}';
  }

  static AbstractProcessor? initProcessor(Flavourist config) {
    final ides = config.ide;
    if (ides == null || ides.isEmpty) {
      return null;
    }

    final processors = <AbstractProcessor>[];

    if (ides.contains(IDE.idea)) {
      processors.add(IdeaRunConfigurationsProcessor(
        Constants.ideaLaunchpath,
        config: config,
      ));
    }
    if (ides.contains(IDE.vscode) || ides.contains(IDE.cursor)) {
      processors.add(VSCodeIDEConfigProcessor(config: config));
    }

    if (processors.isEmpty) {
      return null;
    }
    if (processors.length == 1) {
      return processors.first;
    }
    return QueueProcessor(processors, config: config);
  }
}
