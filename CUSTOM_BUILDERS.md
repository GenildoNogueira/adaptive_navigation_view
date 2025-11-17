# Complete Customization of PaneItemDestination Through Theme

The `PaneItemDestination` widget is now completely customizable through the `PaneThemeData` system. This allows you to create unique navigation experiences while maintaining consistency across your application and following Flutter's theming patterns.

## Table of Contents

- [Overview](#overview)
- [Theme Properties](#theme-properties)
- [Basic Usage](#basic-usage)
- [Advanced Examples](#advanced-examples)
- [Complete Theme Examples](#complete-theme-examples)
- [Best Practices](#best-practices)
- [Migration Guide](#migration-guide)

## Overview

The expanded `PaneThemeData` provides comprehensive control over every aspect of `PaneItemDestination` appearance and behavior:

- **Background and Colors**: Control background colors, gradients, and state-specific colors
- **Shape and Borders**: Customize shapes, border radius, and borders for different states
- **Layout and Spacing**: Control padding, margins, heights, and spacing between elements
- **Icons and Labels**: Customize icon sizes, colors, and label styles for different states
- **Animations**: Control animation duration and curves
- **Elevation and Shadows**: Add elevation and custom shadow effects
- **Hierarchical Items**: Customize chevron appearance and children indentation

## Theme Properties

### Background and Visual Effects

```dart
// Basic background colors
Color? itemBackgroundColor              // Default background
Color? itemSelectedBackgroundColor      // Selected state background
Color? itemHoverBackgroundColor         // Hover state background
Color? itemPressedBackgroundColor       // Pressed state background

// Advanced background effects
WidgetStateProperty<Gradient?>? itemGradient     // State-based gradients
Gradient? itemSelectedGradient                   // Selected gradient
Gradient? itemHoverGradient                      // Hover gradient

// Elevation and shadows
WidgetStateProperty<double?>? itemElevation      // State-based elevation
WidgetStateProperty<Color?>? itemShadowColor     // Shadow colors
```

### Shape and Borders

```dart
// Shape and border radius
WidgetStateProperty<ShapeBorder?>? itemShape           // Custom shapes
WidgetStateProperty<BorderRadiusGeometry?>? itemBorderRadius  // Border radius

// Borders for different states
WidgetStateProperty<BorderSide?>? itemBorder     // State-based borders
BorderSide? itemSelectedBorder                   // Selected border
BorderSide? itemHoverBorder                      // Hover border
```

### Layout and Dimensions

```dart
// Padding and margins
WidgetStateProperty<EdgeInsetsGeometry?>? itemPadding   // Internal padding
WidgetStateProperty<EdgeInsetsGeometry?>? itemMargin    // External margins

// Height constraints
double? itemHeight        // Fixed height
double? itemMinHeight     // Minimum height
double? itemMaxHeight     // Maximum height

// Spacing
double? itemSpacing       // Space between icon and label
```

### Icons

```dart
// Icon properties
WidgetStateProperty<double?>? itemIconSize    // State-based icon sizes
Color? itemIconColor                          // Default icon color
Color? itemSelectedIconColor                  // Selected icon color
Color? itemHoverIconColor                     // Hover icon color
Color? itemDisabledIconColor                  // Disabled icon color
```

### Labels

```dart
// Label text styles for different states
TextStyle? itemLabelStyle              // Default label style
TextStyle? itemSelectedLabelStyle      // Selected label style
TextStyle? itemHoverLabelStyle         // Hover label style
TextStyle? itemDisabledLabelStyle      // Disabled label style
```

### Chevron (Expandable Items)

```dart
// Chevron customization
double? itemChevronSize                // Chevron icon size
Color? itemChevronColor               // Default chevron color
Color? itemChevronHoverColor          // Hover chevron color
Color? itemSelectedChevronColor       // Selected chevron color
```

### Children (Hierarchical Navigation)

```dart
// Children layout
double? itemChildrenIndent      // Indentation for child items
double? itemChildrenSpacing     // Spacing between child items
```

### Animations

```dart
// Animation customization
Duration? itemAnimationDuration     // Animation duration
Curve? itemAnimationCurve          // Animation curve
```

## Basic Usage

### Simple Color Customization

```dart
PaneTheme(
  data: PaneThemeData(
    itemSelectedBackgroundColor: Colors.blue.withOpacity(0.1),
    itemHoverBackgroundColor: Colors.grey.withOpacity(0.05),
    itemSelectedIconColor: Colors.blue,
    itemSelectedLabelStyle: const TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    ),
  ),
  child: NavigationView(
    // Your navigation view content
  ),
)
```

### State-Based Customization

```dart
PaneTheme(
  data: PaneThemeData(
    itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.blue.withOpacity(0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return Colors.grey.withOpacity(0.05);
      }
      return Colors.transparent;
    }),
    itemPadding: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const EdgeInsets.all(16);
      }
      return const EdgeInsets.all(12);
    }),
  ),
  child: NavigationView(
    // Your navigation view content
  ),
)
```

## Advanced Examples

### Card-Style Navigation

```dart
PaneThemeData(
  itemBackgroundColor: WidgetStateProperty.all(Colors.white),
  itemSelectedBackgroundColor: Colors.blue.withOpacity(0.1),
  itemHoverBackgroundColor: Colors.grey.withOpacity(0.05),
  itemShape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  itemBorder: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const BorderSide(color: Colors.blue, width: 2);
    }
    return BorderSide(color: Colors.grey.withOpacity(0.2));
  }),
  itemPadding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  itemMargin: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  itemElevation: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return 4.0;
    if (states.contains(WidgetState.hovered)) return 2.0;
    return 1.0;
  }),
  itemShadowColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.2)),
  itemAnimationDuration: const Duration(milliseconds: 300),
  itemAnimationCurve: Curves.easeOutCubic,
)
```

### Gradient Theme

```dart
PaneThemeData(
  itemGradient: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }),
  itemShape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  itemPadding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  ),
  itemMargin: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  itemIconColor: Colors.white,
  itemSelectedIconColor: Colors.white,
  itemLabelStyle: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  ),
  itemAnimationDuration: const Duration(milliseconds: 350),
)
```

## Complete Theme Examples

### Neumorphism Theme

```dart
PaneThemeData(
  itemBackgroundColor: WidgetStateProperty.all(const Color(0xFFE0E5EC)),
  itemSelectedBackgroundColor: const Color(0xFFE0E5EC),
  itemHoverBackgroundColor: const Color(0xFFE8EAED),
  itemShape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  itemPadding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  itemMargin: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  // Custom shadow implementation would need additional container wrapper
  itemIconColor: const Color(0xFF6C7B7F),
  itemSelectedIconColor: const Color(0xFF4A90E2),
  itemLabelStyle: const TextStyle(
    color: Color(0xFF6C7B7F),
    fontWeight: FontWeight.w500,
  ),
  itemSelectedLabelStyle: const TextStyle(
    color: Color(0xFF4A90E2),
    fontWeight: FontWeight.bold,
  ),
  itemAnimationDuration: const Duration(milliseconds: 250),
)
```

### Glassmorphism Theme

```dart
PaneThemeData(
  itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.white.withOpacity(0.2);
    }
    return Colors.white.withOpacity(0.1);
  }),
  itemHoverBackgroundColor: Colors.white.withOpacity(0.15),
  itemShape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  itemBorder: WidgetStateProperty.all(
    BorderSide(color: Colors.white.withOpacity(0.2)),
  ),
  itemPadding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
  itemMargin: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  ),
  itemIconColor: Colors.white.withOpacity(0.8),
  itemSelectedIconColor: Colors.white,
  itemLabelStyle: TextStyle(
    color: Colors.white.withOpacity(0.8),
    fontWeight: FontWeight.w500,
  ),
  itemSelectedLabelStyle: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
  itemChevronColor: Colors.white.withOpacity(0.6),
  itemSelectedChevronColor: Colors.white,
  itemSpacing: 16.0,
  itemAnimationDuration: const Duration(milliseconds: 400),
  itemAnimationCurve: Curves.easeOutCubic,
)
```

### Minimal Theme

```dart
PaneThemeData(
  itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.black.withOpacity(0.05);
    }
    return Colors.transparent;
  }),
  itemHoverBackgroundColor: Colors.black.withOpacity(0.02),
  itemPadding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  itemMargin: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  ),
  itemIconSize: WidgetStateProperty.all(20.0),
  itemIconColor: Colors.grey[600],
  itemSelectedIconColor: Colors.black87,
  itemLabelStyle: TextStyle(
    color: Colors.grey[600],
    fontSize: 14,
    fontWeight: FontWeight.w400,
  ),
  itemSelectedLabelStyle: const TextStyle(
    color: Colors.black87,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  ),
  itemSpacing: 8.0,
  itemChevronSize: 16.0,
  itemChevronColor: Colors.grey[500],
  itemSelectedChevronColor: Colors.black54,
  itemAnimationDuration: const Duration(milliseconds: 200),
  itemAnimationCurve: Curves.easeInOut,
)
```

## Best Practices

### 1. Consistency

- Use consistent spacing and sizing across all theme properties
- Maintain visual hierarchy with appropriate text styles and icon sizes
- Keep animation durations consistent for a cohesive experience

### 2. Accessibility

- Ensure sufficient color contrast between text and backgrounds
- Provide clear visual feedback for different states (hover, selected, disabled)
- Use semantic colors that convey meaning

### 3. Performance

- Use `WidgetStateProperty.all()` when the same value applies to all states
- Avoid complex calculations in state resolvers
- Cache theme data when possible

### 4. Responsive Design

- Consider different display modes (expanded, compact, minimal)
- Test themes across different screen sizes
- Use appropriate spacing and sizing for touch targets

### 5. Theme Hierarchy

- Define base themes and extend them for variations
- Use theme inheritance to maintain consistency
- Consider creating theme presets for common use cases

## Migration Guide

### From Basic PaneThemeData

If you're currently using basic `PaneThemeData` properties:

```dart
// Before
PaneThemeData(
  indicatorColor: Colors.blue,
  indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  iconTheme: WidgetStateProperty.all(IconThemeData(color: Colors.blue)),
  labelTextStyle: WidgetStateProperty.all(TextStyle(color: Colors.blue)),
)

// After (enhanced customization)
PaneThemeData(
  // Keep existing properties for compatibility
  indicatorColor: Colors.blue,
  indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  iconTheme: WidgetStateProperty.all(IconThemeData(color: Colors.blue)),
  labelTextStyle: WidgetStateProperty.all(TextStyle(color: Colors.blue)),
  
  // Add new customizations
  itemSelectedBackgroundColor: Colors.blue.withOpacity(0.1),
  itemHoverBackgroundColor: Colors.blue.withOpacity(0.05),
  itemPadding: WidgetStateProperty.all(EdgeInsets.all(12)),
  itemMargin: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 4, vertical: 2)),
  itemAnimationDuration: Duration(milliseconds: 250),
)
```

### Gradual Enhancement

You can gradually enhance your themes:

1. Start with basic color customization
2. Add shape and border customization
3. Implement state-based properties
4. Add advanced effects (gradients, elevation)
5. Fine-tune animations and spacing

### Testing Themes

Test your themes with:

- Different navigation structures (flat vs hierarchical)
- All interaction states (hover, selected, pressed, disabled)
- Different display modes
- Light and dark color schemes
- Various screen sizes

## Common Patterns

### Material 3 Style

```dart
itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
  if (states.contains(WidgetState.selected)) {
    return Theme.of(context).colorScheme.secondaryContainer;
  }
  return Colors.transparent;
}),
itemShape: WidgetStateProperty.all(
  RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
),
itemPadding: WidgetStateProperty.all(
  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
),
```

### iOS Style

```dart
itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
  if (states.contains(WidgetState.selected)) {
    return CupertinoColors.systemBlue.withOpacity(0.1);
  }
  return Colors.transparent;
}),
itemShape: WidgetStateProperty.all(
  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
),
itemPadding: WidgetStateProperty.all(
  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
),
itemAnimationCurve: Curves.easeInOut,
```

### Windows 11 Style

```dart
itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
  if (states.contains(WidgetState.selected)) {
    return Color(0xFF0078D4).withOpacity(0.1);
  }
  if (states.contains(WidgetState.hovered)) {
    return Colors.grey.withOpacity(0.1);
  }
  return Colors.transparent;
}),
itemShape: WidgetStateProperty.all(
  RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
),
itemPadding: WidgetStateProperty.all(
  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
),
```

This comprehensive theming system allows you to create any navigation style while maintaining the full functionality of `PaneItemDestination`. The theme-based approach ensures consistency and makes it easy to maintain and update your navigation appearance across your entire application.