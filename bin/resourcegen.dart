import 'package:args/command_runner.dart';

import 'command/build_command.dart';
import 'command/watch_command.dart';

void main(List<String> arguments) {
  final runner = CommandRunner(
    "resourcegen",
    "A Dart CLI tool for generating code for static resources using a prepare-based workflow.",
  );

  runner.addCommand(BuildCommand());
  runner.addCommand(WatchCommand());
  runner.run(arguments);
}
