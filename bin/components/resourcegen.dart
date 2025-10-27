import 'dart:io';

import 'package:prepare/log.dart';
import 'package:yaml_magic/yaml_magic.dart';

/// Handles the initialization and configuration loading for Resourcegen.
class Resourcegen {
  const Resourcegen({
    required this.assetsDir,
    required this.outputDir,
    required this.pubspecFile,
    required this.pubspecYaml,
  });

  final Directory assetsDir;
  final Directory outputDir;
  final File pubspecFile;
  final YamlMagic pubspecYaml;

  /// Loads and initializes [Resourcegen] using configuration from `pubspec.yaml`.
  factory Resourcegen.loadByPubspec() {
    final pubspecFile = File("pubspec.yaml");
    if (!pubspecFile.existsSync()) {
      error(
        "Could not find 'pubspec.yaml' in the current directory.\n"
        "Please run this command from your project's root directory.",
      );
    }

    final pubspecYaml = YamlMagic.load(pubspecFile.path);

    final config = pubspecYaml["resourcegen"];
    final assetsDirPath = config?["assets-dir"] ?? "./assets";
    final outputDirPath = config?["output-dir"] ?? "./lib/gen/assets.dart";

    final assetsDir = Directory(assetsDirPath);
    final outputDir = Directory(outputDirPath);

    if (!assetsDir.existsSync()) {
      error(
        "Could not find the assets directory at '${assetsDir.path}'.\n"
        "Please create it or update 'resourcegen.assets-dir' in pubspec.yaml.",
      );
    }

    return Resourcegen(
      assetsDir: assetsDir,
      outputDir: outputDir,
      pubspecFile: pubspecFile,
      pubspecYaml: pubspecYaml,
    );
  }
}
