# Adaptive Navigation View

A Flutter package that provides a fully adaptive navigation view, inspired by the [Fluent Design Navigation View](https://learn.microsoft.com/en-us/windows/apps/design/controls/navigationview) and built on [Material 3](https://m3.material.io/) principles. The layout automatically adapts between **Minimal**, **Medium**, and **Expanded** display modes based on screen width.

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#display-modes">Display Modes</a> •
  <a href="#usage">Usage</a> •
  <a href="#navigation-controller">Navigation Controller</a> •
  <a href="#hierarchical-destinations">Hierarchical Destinations</a> •
  <a href="#theming">Theming</a> •
  <a href="#keyboard-shortcuts">Keyboard Shortcuts</a> •
  <a href="#rtl-support">RTL Support</a> •
  <a href="#migrating-from-v1">Migrating from v1</a> •
  <a href="#preview">Preview</a>
</p>

---

## Features

- **Three Adaptive Display Modes** — Minimal (mobile), Medium (tablet), and Expanded (desktop), with customizable breakpoints
- **Smooth Transitions** — Animated pane transitions between display modes, no abrupt layout jumps
- **Index or Path Navigation** — Select destinations by position index or named path (compatible with GoRouter, Navigator 2.0, FlutterModular)
- **Navigation History** — Full navigation history stack with `goBack()` support and duplicate-aware tracking
- **Hierarchical Destinations** — Expandable parent items with collapsible children. In Medium mode, children appear in a floating popup menu.
- **Fully Themeable** — Fine-grained control over every visual aspect via `NavigationThemeData`
- **RTL Support** — Full right-to-left language support
- **Keyboard Shortcuts** — `Ctrl+B` / `Cmd+B` to toggle the pane, `Escape` to dismiss
- **Drag Gesture** — Swipe to open/close the pane on mobile with fling support
- **Resize Handle** — Drag the pane edge on desktop to resize

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_navigation_view: ^version_number
```

Or install directly from GitHub:

```yaml
dependencies:
  adaptive_navigation_view:
    git: https://github.com/GenildoNogueira/adaptive_navigation_view.git
```

Then run:

```bash
flutter pub get
```

Import in your Dart code:

```dart
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';
```

---

## Display Modes

The navigation pane switches between three modes based on available screen width:

| Mode | Default Width | Behavior |
|---|---|---|
| **Minimal** | `< 600px` | Only a menu button is shown. The pane slides in as an overlay. |
| **Medium** | `600px – 840px` | Icons only when closed. Opens to show icons + labels. |
| **Expanded** | `> 840px` | Pane is always visible and fully expanded. |

You can customize the breakpoints per-instance:

```dart
NavigationView(
  compactBreakpoint: const WidthBreakpoint(end: 600),
  mediumBreakpoint: const WidthBreakpoint(start: 600, end: 840),
  expandedBreakpoint: const WidthBreakpoint(start: 840),
  // ...
)
```

Or force a specific mode regardless of screen width:

```dart
NavigationView(
  preferredDisplayMode: DisplayMode.expanded,
  // ...
)
```
---

## Usage

### Basic Setup

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late final NavigationViewController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = NavigationViewController(
      length: 3,
      initialIndex: 0,
      destinationType: DestinationTypes.byIndex,
      onDestinationIndex: (index) {
        setState(() => _selectedIndex = index ?? 0);
      },
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavigationView(
        controller: _controller,
        appBar: NavigationAppBar(
          title: const Text('My App'),
        ),
        pane: NavigationPane(
          destinations: const [
            PaneItemDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('Home'),
            ),
            PaneItemDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: Text('Explore'),
            ),
            PaneItemDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        body: [
          const Center(child: Text('Home')),
          const Center(child: Text('Explore')),
          const Center(child: Text('Settings')),
        ][_selectedIndex],
      ),
    );
  }
}
```

---

## Navigation Controller

`NavigationViewController` is the central controller for managing navigation state, pane open/close animations, and navigation history.

### Index-Based Navigation

Best for simple, ordered navigation where destinations are identified by position.

```dart
final controller = NavigationViewController(
  length: 3,
  initialIndex: 0,
  destinationType: DestinationTypes.byIndex,
  onDestinationIndex: (index) {
    // Called whenever a destination is selected
  },
  vsync: this,
);

// Navigate programmatically
controller.selectDestinationByIndex(2);

// Read current state
print(controller.selectedIndex);   // 2
print(controller.previousIndices); // [0, 2]
```

### Path-Based Navigation

Best when integrating with named route systems like GoRouter, Navigator 2.0, or FlutterModular.

```dart
final controller = NavigationViewController(
  initialPath: '/home',
  destinationType: DestinationTypes.byPath,
  onDestinationPath: (path) {
    // Trigger your router navigation here
    context.go(path!);
  },
  vsync: this,
);

// Navigate programmatically
controller.selectDestinationByPath('/settings');

// Read current state
print(controller.selectedPath);  // '/settings'
print(controller.previousPaths); // ['/home', '/settings']
```

### Navigation History

The controller maintains a full history stack. Navigation by index and by path both support duplicate entries, correctly reflecting how the user actually traversed the app.

```dart
// Navigate A → B → A → B
controller.selectDestinationByIndex(1); // history: [0, 1]
controller.selectDestinationByIndex(0); // history: [0, 1, 0]
controller.selectDestinationByIndex(1); // history: [0, 1, 0, 1]

// Go back step by step
controller.goBack(); // history: [0, 1, 0], current: 0
controller.goBack(); // history: [0, 1],    current: 1

// Check if back is available
if (controller.canGoBack) {
  controller.goBack();
}

// Clear history without changing selection
controller.clearHistory();
```

### Pane Control

```dart
controller.open();       // animate open
controller.close();      // animate close
controller.toggle();     // toggle between open/closed
controller.snapOpen();   // instantly open, no animation
controller.snapClosed(); // instantly close, no animation

// Fling (e.g., after a drag gesture)
controller.fling(velocity: 1.0);  // positive = open
controller.fling(velocity: -1.0); // negative = close

// Read state
print(controller.isPaneOpen);  // bool
print(controller.isAnimating); // bool
print(controller.offset);      // 0.0 to 1.0
```

---

## Hierarchical Destinations

Parent destinations with children are **not directly selectable** — tapping them expands or collapses their sub-items. Only leaf items (those without children) are navigable.

In **Medium** mode with the pane closed, parent items show their children in a floating popup menu instead.

```dart
NavigationViewController(
  length: 4, // count only leaf (selectable) destinations
  initialPath: '/',
  destinationType: DestinationTypes.byPath,
  vsync: this,
)

NavigationPane(
  destinations: [
    PaneItemDestination(
      icon: const Icon(Icons.folder_outlined),
      selectedIcon: const Icon(Icons.folder),
      label: const Text('Documents'),
      initialExpanded: true, // expanded on first render
      children: [
        PaneItemDestination(
          icon: const Icon(Icons.insert_drive_file_outlined),
          label: const Text('Files'),
          path: '/documents/files',
        ),
        PaneItemDestination(
          icon: const Icon(Icons.image_outlined),
          label: const Text('Images'),
          path: '/documents/images',
        ),
      ],
    ),
    PaneItemDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings),
      label: const Text('Settings'),
      path: '/settings',
    ),
  ],
)
```

### Footer Items

Items placed in `footers` are pinned to the bottom of the pane and do not scroll with the main destinations:

```dart
NavigationPane(
  destinations: [ /* main items */ ],
  footers: [
    PaneItemDestination(
      icon: const Icon(Icons.help_outline),
      label: const Text('Help'),
      path: '/help',
    ),
  ],
)
```

---

### Accessing the Controller from a Child Widget

```dart
// From anywhere in the subtree
final state = NavigationView.of(context);
state.openPane();
state.closePane();

// Or nullable version
NavigationView.maybeOf(context)?.openPane();
```

---

## Theming

Apply a theme to the entire navigation via `NavigationTheme`:

```dart
NavigationTheme(
  data: NavigationThemeData(
    openWidth: 280,
    compactWidth: 72,
    indicatorColor: Colors.blue.shade100,
    indicatorShape: const StadiumBorder(),
    indicatorSize: const Size.fromHeight(40),
    itemAnimationDuration: const Duration(milliseconds: 250),
    itemAnimationCurve: Curves.easeInOutCubic,
    itemMargin: const EdgeInsets.symmetric(horizontal: 12),
    itemContentPadding: const EdgeInsets.symmetric(horizontal: 8),
    itemShape: WidgetStateProperty.all(const StadiumBorder()),
    itemSelectedBackgroundColor: Colors.blue.shade50,
    itemHoverBackgroundColor: Colors.black.withValues(alpha: 0.04),
    itemChevronColor: Colors.grey,
    itemChildrenIndent: 20,
  ),
  child: NavigationView(/* ... */),
)
```

All `NavigationThemeData` properties support `lerp` for smooth theme transitions. You can also use `copyWith` to override only specific values:

```dart
final myTheme = NavigationThemeData(
  openWidth: 300,
).copyWith(
  indicatorColor: Colors.purple,
  itemAnimationDuration: const Duration(milliseconds: 300),
);
```

### Available Theme Properties

| Category | Properties |
|---|---|
| **Pane** | `backgroundColor`, `elevation`, `shadowColor`, `surfaceTintColor`, `shape`, `minimalShape`, `scrimColor` |
| **Sizes** | `openWidth`, `compactWidth`, `itemSize`, `indicatorSize`, `itemChevronSize`, `itemChildrenIndent`, `itemChildrenSpacing` |
| **Indicator** | `indicatorColor`, `indicatorShape` |
| **Item Background** | `itemBackgroundColor`, `itemSelectedBackgroundColor`, `itemHoverBackgroundColor`, `itemPressedBackgroundColor` |
| **Item Shape** | `itemShape`, `itemMargin`, `itemContentPadding`, `itemSpacing`, `itemElevation`, `itemShadowColor` |
| **Icons** | `iconTheme`, `itemIconColor`, `itemSelectedIconColor`, `itemHoverIconColor`, `itemDisabledIconColor`, `itemIconSize` |
| **Labels** | `labelTextStyle`, `itemLabelStyle`, `itemSelectedLabelStyle`, `itemHoverLabelStyle`, `itemDisabledLabelStyle` |
| **Chevron** | `itemChevronColor`, `itemChevronHoverColor`, `itemSelectedChevronColor` |
| **Animation** | `itemAnimationDuration`, `itemAnimationCurve` |

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl+B` / `Cmd+B` (macOS) | Toggle pane open/closed |
| `Escape` | Close/dismiss the pane |
| `↑` / `↓` | Navigate between items when focused |

---

## RTL Support

The navigation pane automatically mirrors its layout for right-to-left languages. No extra configuration is needed beyond setting up your app's locale:

```dart
MaterialApp(
  supportedLocales: const [
    Locale('en', 'US'), // LTR
    Locale('ar', 'AR'), // RTL — pane appears on the right
    Locale('he', 'IL'), // RTL
  ],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: NavigationView(/* ... */),
)
```

---

## Migrating from v1

### Controller is now required

In v1, navigation state was handled internally by `NavigationPane` via `selectedIndex` and `onDestinationSelected`. In v2, you must create and manage a `NavigationViewController` yourself and pass it to `NavigationView`.

```dart
// v1
NavigationView(
  pane: NavigationPane(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (i) => setState(() => _selectedIndex = i),
    children: [ /* ... */ ],
  ),
)

// v2
NavigationView(
  controller: _controller, // required
  pane: NavigationPane(
    destinations: [ /* ... */ ], // renamed from children
  ),
)
```

### Rename `PaneTheme` → `NavigationTheme`

```dart
// v1
PaneTheme(
  data: PaneThemeData(openWidth: 280),
  child: NavigationView(/* ... */),
)

// v2
NavigationTheme(
  data: NavigationThemeData(openWidth: 280),
  child: NavigationView(/* ... */),
)
```

### `NavigationPane.children` renamed to `destinations`

```dart
// v1
NavigationPane(children: [ PaneItemDestination(/* ... */) ])

// v2
NavigationPane(destinations: [ PaneItemDestination(/* ... */) ])
```

### Path-based navigation

If you use GoRouter or any named-route system, you can now replace index tracking with path-based navigation entirely — no need to manually sync `_selectedIndex` with your router state:

```dart
final controller = NavigationViewController(
  initialPath: '/home',
  destinationType: DestinationTypes.byPath,
  onDestinationPath: (path) => context.go(path!),
  vsync: this,
);
```

---

## Preview

### Minimal (Mobile)

<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/1.png" width="456px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/2.png" width="456px" />

### Medium (Tablet)

<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/3.png" width="947px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/4.png" width="947px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/5.png" width="887px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/6.png" width="887px" />

### Expanded (Desktop)

<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/7.png" width="1342px" />
<img src="https://raw.githubusercontent.com/GenildoNogueira/adaptive_navigation_view/master/screenshot/8.png" width="1342px" />

---

## Acknowledgements

Built on the principles and guidelines of [Material 3](https://m3.material.io/) and inspired by the [Fluent Design Navigation View](https://learn.microsoft.com/en-us/windows/apps/design/controls/navigationview).
