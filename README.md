# Introduction
A Dart CLI tool for generating code for static resources using a prepare-based workflow.

> Converts the asset file structure into Dart code at an incredibly fast speed by not using build_runner. Even without manually editing pubspec.yaml, running the build automatically updates the necessary asset references. With watch mode enabled, all operations complete in under 🚀 1ms per file.

## Usage

### Build Command
Generates Dart code for all assets once. This will scan your assets directory, generate the corresponding classes, and update `pubspec.yaml` with the necessary asset references.

```bash
dart run resourcegen build
```

### Watch Command
Runs in watch mode, continuously monitoring your assets directory for changes. Any added, removed, or modified assets will trigger an automatic rebuild in under 1ms per file.

```bash
dart run resourcegen watch
```

> [!TIP]
> **Build Integration:** To integrate and manage build processes with tools like [datagen](https://github.com/MTtankkeo/datagen), learn how to use [Prepare](https://github.com/MTtankkeo/prepare) effectively.

### Development
This section demonstrates how to work with static assets in the development environment, including accessing paths, names, and converting assets into widgets.

```dart
/// Refer a static asset `assets/example/svg1.svg`.
final svg = Assets.example.svg1;

// Get the asset path.
svg.path;

// Get the asset name.
svg.name;

/// Extension for instances of `.png` static assets, 
/// providing additional convenience methods or properties.
extension AssetPngExtension on AssetPng {
  Widget widget() {
    return Image.assets(path, ...);
  }
}

// Use the extension method to display the PNG asset as a widget.
svg.widget();
```

### Configuration
You can define your asset source directory and the output file for the generated code in your `pubspec.yaml`. 

> If you don’t provide these, resourcegen will use default values (**assets/** for the assets directory and **lib/gen/assets.dart** for the output file).

```yaml
resourcegen:
  # The directory where your assets are located.
  assets-dir: assets/

  # The output file where the generated Dart code will be written.
  output-dir: lib/gen/assets.dart
```
