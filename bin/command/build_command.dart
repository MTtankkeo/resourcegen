import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:prepare/log.dart';

import '../components/resourcegen_builder.dart';

/// A CLI command that triggers the resourcegen build process.
class BuildCommand extends Command {
  @override
  String get name => "build";

  @override
  String get description => "Generates files for Dart.";

  @override
  Future<void> run() async {
    try {
      final builder = ResourcegenBuilder();
      await builder.build();

      log(
        "Resourcegen for pre-processing build completed successfully!",
        color: green,
      );
    } catch (error) {
      log("Error: $error", color: red);
    }
  }
}
