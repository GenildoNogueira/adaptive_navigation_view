# [2.0.0] - 2025-08-07

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
