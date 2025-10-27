import 'dart:io';
import 'package:prepare/log.dart';
import 'package:recase/recase.dart';

import 'resourcegen.dart';

/// A builder that generates Dart classes for referencing assets in a directory structure.
/// It scans folders and files under [assetsDir] and produces a Dart file in [outputDir].
class ResourcegenBuilder {
  /// Keeps track of all file extensions found in the scanned assets.
  final List<String> markedExtensions = [];

  /// Returns a list of all directories under [dir], including [dir] itself.
  /// All paths are normalized to use forward slashes ("/").
  /// Traverses directories recursively
  static List<Directory> getAllDirectories(Directory dir) {
    final dirs = <Directory>[];

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is Directory) {
        dirs.add(entity);
      }
    }

    dirs.insert(0, dir);
    return dirs;
  }

  /// Normalizes [path] for pubspec.yaml: uses forward slashes,
  /// removes leading "./", and ensures trailing "/"
  static String ensurePubspecFormat(String path) {
    return "${ResourcegenBuilder.normalizePath(path)}/";
  }

  /// Normalizes a file path to use forward slashes and removes a leading `./`.
  static String normalizePath(String path) {
    return path.replaceAll("\\", "/").replaceFirst("./", "");
  }

  /// Converts a file or folder name to a camelCase variable name.
  /// e.g. 'home-filled.svg' → 'homeFilled'.
  static String toVariableName(String path) {
    final name = path.split("/").last.split(".").first;
    var variable = ReCase(name).camelCase;

    // Prefix with 'n' if it starts with a digit.
    if (RegExp(r'^[0-9]').hasMatch(variable)) {
      variable = 'n$variable';
    }

    return variable;
  }

  /// Converts a folder path to a PascalCase class name.
  /// e.g. 'assets/test_a' → 'AssetsTestA'.
  static String toClassName(String path) {
    return path.split("/").map((part) => ReCase(part).pascalCase).join();
  }

  /// Creates a Dart class string representing a directory [dir].
  String createAssetClass(Directory dir) {
    final normalizedPath = normalizePath(dir.path);
    final isRootDir = normalizedPath.split("/").length == 1;
    final className = toClassName(normalizedPath);
    final entities = dir.listSync();
    final children = entities.map((file) {
      final fieldNormalizedPath = normalizePath(file.path);
      final fieldVariableName = toVariableName(fieldNormalizedPath);

      // Throws an error if the asset's variable name conflicts with reserved names.
      if (fieldVariableName == "path") {
        error(
          "The field name '$fieldVariableName' is reserved and cannot be used for an asset."
          "Please choose a different name.",
        );
      }

      final String field;

      // Generates nested asset class for directories and Asset
      // instances for files with their name and path.
      if (file is Directory) {
        final fieldClassName = toClassName(fieldNormalizedPath);

        field = "final $fieldVariableName = $fieldClassName();";
      } else {
        final fileName = fieldNormalizedPath.split("/").last;
        final extension = fieldNormalizedPath.split(".").last;
        final fieldClassName =
            "Asset${extension[0].toUpperCase()}${extension.substring(1)}";

        // Added to track extensions for which classes need to be generated.
        if (!markedExtensions.contains(extension)) {
          markedExtensions.add(extension);
        }

        field =
            "final $fieldVariableName = $fieldClassName('$fileName', '$fieldNormalizedPath');";
      }

      return "${isRootDir ? "static " : ""}$field";
    });

    final fields = children.map((e) => "\t$e");

    return [
      "/// A class represents the assets in the '$normalizedPath' directory.",
      "class $className {${isRootDir ? "\n\tconst $className._();\n" : ""}",
      "\t${isRootDir ? "static const" : "final"} String path = '$normalizedPath';",
      "${fields.isEmpty ? "" : "\n${fields.join("\n")}\n"}}",
    ].join("\n");
  }

  String createExtensionClass(String extension) {
    final className = "Asset${ReCase(extension).pascalCase}";

    return [
      "/// A class represents a static asset file with the '.$extension' extension.",
      "class $className {",
      "\tconst $className(this.name, this.path);",
      "",
      "\tfinal String name;",
      "\tfinal String path;",
      "",
      "\t@override",
      "\tString toString() {",
      "\t\treturn '$className(name: \$name, path: \$path)';",
      "\t}",
      "}",
    ].join("\n");
  }

  /// Builds the Dart code representation of the asset structure.
  /// Scans the asset directory, generates corresponding Dart classes,
  /// and updates the `pubspec.yaml` file with required asset references.
  Future<void> build() async {
    final config = Resourcegen.loadByPubspec();
    final pubspecFile = config.pubspecFile;
    final pubspecYaml = config.pubspecYaml;

    pubspecYaml["flutter"] ??= {};
    pubspecYaml["flutter"]["assets"] ??= [];

    final assetsFolders = getAllDirectories(config.assetsDir);
    final pubspecAssets =
        assetsFolders.map((dir) => dir.path).map(ensurePubspecFormat);

    pubspecYaml["flutter"]["assets"] = pubspecAssets;
    pubspecFile.writeAsStringSync(pubspecYaml.toString());

    final classes = <String>[];

    // Generate a Dart class for each directory in [assetsFolders].
    for (final dir in assetsFolders) {
      classes.add(createAssetClass(dir));
    }

    // Generate helper classes for each file extension encountered in the assets.
    for (final extension in markedExtensions) {
      classes.add(createExtensionClass(extension));
    }

    final resultCode = classes.join("\n\n");
    final outputFile = File(config.outputDir.path);
    outputFile.createSync(recursive: true);
    outputFile.writeAsStringSync("$resultCode\n");
  }
}
