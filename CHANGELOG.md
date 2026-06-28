# [2.0.1]
 
## Fixed
 
- Fixed a visual glitch (jitter/tremor) in the navigation pane when opening in RTL languages (e.g. Arabic, Hebrew). The pane now uses `SlideTransition` instead of `widthFactor` + `Align` to animate, eliminating the coordinate conflict between `PaneController` and `_NavigationLayout` that caused the shaking.
- Fixed `SizeTransition` in `_buildChildrenSection` using a hardcoded `alignment: Alignment.centerLeft`, which caused child items to shift horizontally during expand/collapse in RTL mode. Replaced with `axisAlignment: -1.0` to animate along the vertical axis only.
- Fixed the expand/collapse chevron in RTL mode: rotation direction is now inverted and the icon is mirrored (`keyboard_arrow_left`) so it correctly animates from ← to ↓ instead of → to ↓.
- Fixed `Stack` alignment in `PaneItem` resolving `AlignmentDirectional.centerStart` to `Alignment.centerRight` in RTL contexts, preventing item jitter during pane expansion.
- Fixed children section being removed from the widget tree immediately when collapsing (via `if (_isExpanded)`), which cut off the closing animation. The section is now always present in the tree and `SizeTransition` handles visibility via `sizeFactor`.

## Changed
 
- Reorganized README: moved *Display Modes* section after *Installation*, added *Hierarchical Destinations* and *Migrating from v1* sections, and relocated *Accessing the Controller* under *Hierarchical Destinations*.
- Updated feature description for hierarchical destinations to document the floating popup menu behavior in Medium (compact) mode.
- Added `formatter: trailing_commas: preserve` to `analysis_options.yaml`.

# [2.0.0]

## Feat

- Support for navigation by index or by named path in `PaneItemDestination`. You can now use named paths for navigation in your pane destinations:

```dart
NavigationPane(
  controller: controller,
  children: [
    PaneItemDestination(
      icon: Icon(Icons.home),
      label: Text('Home'),
      path: '/',
    ),
    PaneItemDestination(
      icon: Icon(Icons.person),
      label: Text('Profile'),
      path: '/profile',
    ),
  ],
)
```

- Support for hierarchical (nested) navigation using `children` in `PaneItemDestination`.
- Documentation and examples for using children (sub-items) in navigation menus.

## Changed

- `NavigationView` now requires a `NavigationViewController` to be passed via the `controller` parameter. The controller is now responsible for handling all navigation state and pane animations.
- If a `PaneItemDestination` has children, it is now only expandable/collapsible and not directly navigable/selectable. Only its children are considered navigable destinations.
- Rename `PaneTheme` for `NavigationTheme`, `PaneThemeData` for `NavigationThemeData`.

# [1.1.1]

## Fixed

- Fixed a bug in the `NavigationView`, `PaneController` and `PaneItemDestination`.
- Fixed memory leak `PaneController`.

# [1.1.0]

## Feat

- Added `footers` property to Navigation Pane for displaying additional widgets after the main navigation items.
- Added `additionalLending` feature to Navigation App Bar.

## Fixed

- Fixed a bug in the `PaneController`.
- Migrates deprecated `MaterialState` and `MaterialStateProperty` to `WidgetState` and `WidgetStateProperty`.

# [1.0.1]

## Fixed

- Fixed a bug in the **Navigation App Bar** that affected layout in Compact mode.
- Fixed a bug in the **Navigation Pane** that prevented correct operation in Compact mode.

# [1.0.0]

- Initial **release**
