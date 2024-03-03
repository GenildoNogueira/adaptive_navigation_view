# Adaptive Navigation View

This package provides an adaptive navigation view for Flutter applications. The navigation view adapts to different platforms and devices, offering a consistent and customizable user experience.

## Features

- **Platform Adaptability:** Seamlessly adapts to different platforms like Android, iOS, macOS, Linux, and Windows.
- **Responsive Design:** Offers a responsive design that works well on various screen sizes and orientations.
- **Customizable:** Easily customize the appearance and behavior of the navigation view to suit your application's needs.

<p align="center">
  <a href="#preview-images">Preview Images</a>
</p>

## Installation

To get started with `adaptive_navigation_view`, follow these simple steps:

1. Add the package to your `pubspec.yaml` file:

    ```yaml
    dependencies:
      adaptive_navigation_view: ^version_number
    ```

    <p align="center">OR</p>

    ```yaml
    dependencies:
    adaptive_navigation_view:
        git: https://github.com/GenildoNogueira/adaptive_navigation_view.git
    ```

1. Run `flutter pub get` in your terminal.

2. Import the package in your Dart code:

    ```dart
    import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';
    ```

3. Start using the adaptive navigation view in your application!

## Usage

Here's a quick example of how to integrate the `AdaptiveNavigationView` into your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavigationView(
        appBar: NavigationAppBar(
          title: const Text('Navigation View Example'),
        ),
        pane: NavigationPane(
          onDestinationSelected: (value) => setState(() {
            _selectedIndex = value;
          }),
          selectedIndex: _selectedIndex,
          children: const [
            PaneItemDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            PaneItemDestination(
              icon: Icon(Icons.person),
              label: Text('Profile'),
            ),
          ],
        ),
        body: [
          const Center(
            child: Text('Home'),
          ),
          const Center(
            child: Text('Profile'),
          ),
        ][_selectedIndex],
      ),
    );
  }
}
```

# Theming

### Pane Theme

The `PaneThemeData` class defines default property values for descendant NavigationPane widgets. It includes various properties for customizing the appearance of PaneItemDestination elements.

Example of creating a PaneItemThemeData:
```dart
PaneThemeData myPaneTheme = const PaneThemeData(
  elevation: 0,
  openWidth: 250,
  compactWidth: 60,
  indicatorSize: Size.fromHeight(40.0),
);
```

## Right-to-Left Language Support (RTL)

The `NavigationView` provides support for right-to-left (RTL) languages, ensuring a consistent and intuitive user experience for users who use RTL languages.

### Enabling RTL Support

To enable RTL language support in the NavigationView, follow these steps:

1. Ensure that your application's texts and resources are prepared for RTL languages, with appropriate layouts.

2. In your Flutter application, configure the supported locales to include RTL languages. For example:

```dart
MaterialApp(
  supportedLocales: [
    const Locale('en', 'US'), // English (left to right)
    const Locale('ar', 'AR'), // Arabic (right to left)
  ],
)
```
3. The NavigationView will automatically detect the current language of the device and adjust its layout to support RTL when necessary.

# Preview Images

### Painel Minimal
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/1.png" width="456px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/2.png" width="456px" />

### Painel Medium
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/3.png" width="947px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/4.png" width="947px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/5.png" width="887px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/6.png" width="887px" />

### Painel Expanded
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/7.png" width="1342px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/8.png" width="1342px" />

# Acknowledgements

This package is based on the principles and guidelines outlined in the [Material 3 Documentation](https://m3.material.io/).