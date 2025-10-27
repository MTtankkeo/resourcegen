import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:prepare/prepare.dart';
import 'package:prepare/log.dart';

import '../components/resourcegen.dart';
import '../components/resourcegen_builder.dart';

/// A CLI command that triggers the resourcegen watch process.
class WatchCommand extends Command {
  @override
  String get name => "watch";

  @override
  String get description => "Generates files for Dart with watch mode.";

  /// Returns the directory containing the project's assets.
  Directory get directory => Resourcegen.loadByPubspec().assetsDir;

  @override
  Future<void> run() async {
    final debounce = PrepareDebounce();

    try {
      // Start the build process on the current directory.
      log(
        "Starting resourcegen build in watch mode...",
        color: yellow,
      );

      // Watch for changes.
      await for (final _ in directory.watch(recursive: true)) {
        // Run the build after a short debounce, measuring the duration
        // and indicating that changes in assets triggered the build.
        debounce.run(() {
          final stopwatch = Stopwatch()..start();

          ResourcegenBuilder().build();

          stopwatch.stop();
          final elapsedTime = "${stopwatch.elapsedMilliseconds}ms";

          log(
            "Changes detected in assets and starting resourcegen build... ($elapsedTime)",
            color: gray,
          );
        });
      }
    } catch (error) {
      log("Resourcegen Error: $error", color: red);
    }
  }
}
