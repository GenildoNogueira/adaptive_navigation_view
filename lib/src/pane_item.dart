part of 'navigation_view.dart';

/// A Material Design [NavigationPane] destination.
///
/// Displays an icon with a label, for use in [NavigationPane.children].
class PaneItemDestination extends StatelessWidget {
  /// Creates a pane item destination.
  const PaneItemDestination({
    super.key,
    this.backgroundColor,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.enabled = true,
  });

  /// Sets the color of the [Material] that holds all of the [Pane]'s
  /// contents.
  ///
  /// If this is null, then [PaneThemeData.backgroundColor] is used. If that
  /// is also null, then it falls back to [Material]'s default.
  final Color? backgroundColor;

  /// The [Widget] (usually an [Icon]) that's displayed for this
  /// [PaneItemDestination].
  ///
  /// The icon will use [PaneThemeData.iconTheme]. If this is
  /// null, the default [IconThemeData] would use a size of 24.0 and
  /// [ColorScheme.onSurfaceVariant].
  final Widget icon;

  /// The optional [Widget] (usually an [Icon]) that's displayed when this
  /// [PaneItemDestination] is selected.
  ///
  /// If [selectedIcon] is non-null, the destination will fade from
  /// [icon] to [selectedIcon] when this destination goes from unselected to
  /// selected.
  ///
  /// The icon will use [PaneThemeData.iconTheme] with
  /// [WidgetState.selected]. If this is null, the default [IconThemeData]
  /// would use a size of 24.0 and [ColorScheme.onSecondaryContainer].
  final Widget? selectedIcon;

  /// The text label that appears on the right of the icon
  ///
  /// The accompanying [Text] widget will use
  /// [PaneThemeData.labelTextStyle]. If this are null, the default
  /// text style would use [TextTheme.labelLarge] with [ColorScheme.onSurfaceVariant].
  final Widget label;

  /// Indicates that this destination is selectable.
  ///
  /// Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const Set<WidgetState> selectedState = <WidgetState>{
      WidgetState.selected,
    };
    const Set<WidgetState> unselectedState = <WidgetState>{};
    const Set<WidgetState> disabledState = <WidgetState>{
      WidgetState.disabled,
    };

    final PaneThemeData? paneItemTheme = PaneTheme.of(context);
    final PaneThemeData defaults = _PaneDefaults(context);
    final _NavigationViewScope navigationViewScope =
        _NavigationViewScope.of(context);
    final _PaneControllerScope paneControllerScope =
        _PaneControllerScope.of(context);

    final Animation<double> animation = _PaneInfo.of(context).selectedAnimation;

    return _PaneItemBuilder(
      displayMode: navigationViewScope.displayMode,
      paneActionMoveAnimationProgress:
          paneControllerScope.paneActionMoveAnimationProgress,
      buildIcon: (BuildContext context) {
        final state = enabled
            ? (enabled ? selectedState : unselectedState)
            : disabledState;
        final themeData = paneItemTheme?.iconTheme?.resolve(state);
        final IconThemeData resolvedTheme =
            themeData ?? defaults.iconTheme!.resolve(state)!;

        return IconTheme.merge(
          data: resolvedTheme,
          child: _isForwardOrCompleted(animation) ? selectedIcon ?? icon : icon,
        );
      },
      buildLabel: (BuildContext context) {
        final state = enabled
            ? (enabled ? selectedState : unselectedState)
            : disabledState;
        final resolvedTextStyle =
            (paneItemTheme?.labelTextStyle?.resolve(state) ??
                defaults.labelTextStyle!.resolve(state))!;

        return DefaultTextStyle(
          style: resolvedTextStyle,
          child: label,
        );
      },
      enabled: enabled,
    );
  }
}

/// Returns `true` if this animation is ticking forward, or has completed,
/// based on [status].
bool _isForwardOrCompleted(Animation<double> animation) {
  return animation.status == AnimationStatus.forward ||
      animation.status == AnimationStatus.completed;
}

/// Selection Indicator for the Material 3 [NavigationBar] and [NavigationRail]
/// components.
///
/// When [animation] is 0, the indicator is not present. As [animation] grows
/// from 0 to 1, the indicator scales in on the x axis.
///
/// Used in a [Stack] widget behind the icons in the Material 3 Navigation Bar
/// to illuminate the selected destination.
class PaneIndicator extends StatelessWidget {
  /// Builds an indicator, usually used in a stack behind the icon of a
  /// navigation bar destination.
  const PaneIndicator({
    super.key,
    required this.animation,
    this.color,
    this.width = _kIndicatorWidth,
    this.height = _kIndicatorHeight,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shape,
  });

  /// Determines the scale of the indicator.
  ///
  /// When [animation] is 0, the indicator is not present. The indicator scales
  /// in as [animation] grows from 0 to 1.
  final Animation<double> animation;

  /// The fill color of this indicator.
  ///
  /// If null, defaults to [ColorScheme.secondary].
  final Color? color;

  /// The width of this indicator.
  ///
  /// Defaults to `64`.
  final double width;

  /// The height of this indicator.
  ///
  /// Defaults to `32`.
  final double height;

  /// The border radius of the shape of the indicator.
  ///
  /// This is used to create a [RoundedRectangleBorder] shape for the indicator.
  /// This is ignored if [shape] is non-null.
  ///
  /// Defaults to `BorderRadius.circular(16)`.
  final BorderRadius borderRadius;

  /// The shape of the indicator.
  ///
  /// If non-null this is used as the shape used to draw the background
  /// of the indicator. If null then a [RoundedRectangleBorder] with the
  /// [borderRadius] is used.
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return _StatusTransitionWidgetBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return _SelectableAnimatedBuilder(
          isSelected: _isForwardOrCompleted(animation),
          duration: const Duration(milliseconds: 100),
          builder: (BuildContext context, Animation<double> fadeAnimation) {
            return FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                width: width,
                height: height,
                decoration: ShapeDecoration(
                  shape: shape ??
                      RoundedRectangleBorder(borderRadius: borderRadius),
                  color: color ?? Theme.of(context).colorScheme.secondary,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget that handles the semantics and layout of a navigation drawer
/// destination.
///
/// Prefer [PaneItem] over this widget, as it is a simpler
/// (although less customizable) way to get navigation drawer destinations.
///
/// The icon and label of this destination are built with [buildIcon] and
/// [buildLabel]. They should build the unselected and selected icon and label
/// according to [_PaneInfo.selectedAnimation], where an
/// animation value of 0 is unselected and 1 is selected.
///
/// See [PaneItem] for an example.
class _PaneItemBuilder extends StatelessWidget {
  /// Builds a destination (icon + label) to use in a Material 3 [NavigationDrawer].
  const _PaneItemBuilder({
    required this.displayMode,
    required this.paneActionMoveAnimationProgress,
    required this.buildIcon,
    required this.buildLabel,
    this.enabled = true,
  });

  final DisplayMode displayMode;

  final double paneActionMoveAnimationProgress;

  /// Builds the icon for a destination in a [NavigationDrawer].
  ///
  /// To animate between unselected and selected, build the icon based on
  /// [_PaneInfo.selectedAnimation]. When the animation is 0,
  /// the destination is unselected, when the animation is 1, the destination is
  /// selected.
  ///
  /// The destination is considered selected as soon as the animation is
  /// increasing or completed, and it is considered unselected as soon as the
  /// animation is decreasing or dismissed.
  final WidgetBuilder buildIcon;

  /// Builds the label for a destination in a [NavigationDrawer].
  ///
  /// To animate between unselected and selected, build the icon based on
  /// [_PaneInfo.selectedAnimation]. When the animation is
  /// 0, the destination is unselected, when the animation is 1, the destination
  /// is selected.
  ///
  /// The destination is considered selected as soon as the animation is
  /// increasing or completed, and it is considered unselected as soon as the
  /// animation is decreasing or dismissed.
  final WidgetBuilder buildLabel;

  /// Indicates that this destination is selectable.
  ///
  /// Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final _PaneInfo info = _PaneInfo.of(context);
    final PaneThemeData? paneItemTheme = PaneTheme.of(context);
    final PaneThemeData defaults = _PaneDefaults(context);
    final NavigationViewState navigationView = NavigationView.of(context);

    final isDisplayModeMinimal = displayMode == DisplayMode.minimal;
    final isDisplayModeOpen = displayMode == DisplayMode.expanded;

    final Row destinationBody = Row(
      children: <Widget>[
        const SizedBox(width: 16),
        buildIcon(context),
        if (isDisplayModeMinimal ||
            isDisplayModeOpen ||
            (navigationView.isPaneOpen &&
                paneActionMoveAnimationProgress > 0.5)) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Opacity(
              opacity: isDisplayModeMinimal || isDisplayModeOpen
                  ? 1.0
                  : paneActionMoveAnimationProgress,
              child: buildLabel(context),
            ),
          ),
        ] else
          const SizedBox.shrink(),
      ],
    );

    return Padding(
      padding: info.tilePadding,
      child: _PaneItemSemantics(
        child: InkWell(
          highlightColor: Colors.transparent,
          onTap: enabled ? info.onTap : null,
          customBorder: info.indicatorShape ??
              paneItemTheme?.indicatorShape ??
              defaults.indicatorShape!,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              PaneIndicator(
                animation: info.selectedAnimation,
                color: info.indicatorColor ??
                    paneItemTheme?.indicatorColor ??
                    defaults.indicatorColor!,
                shape: info.indicatorShape ??
                    paneItemTheme?.indicatorShape ??
                    defaults.indicatorShape!,
                width: (paneItemTheme?.indicatorSize ?? defaults.indicatorSize!)
                    .width,
                height:
                    (paneItemTheme?.indicatorSize ?? defaults.indicatorSize!)
                        .height,
              ),
              destinationBody,
            ],
          ),
        ),
      ),
    );
  }
}

/// Semantics widget for a navigation drawer destination.
///
/// Requires a [_PaneInfo] parent (normally provided by the
/// [NavigationDrawer] by default).
///
/// Provides localized semantic labels to the destination, for example, it will
/// read "Home, Tab 1 of 3".
///
/// Used by [_PaneItemBuilder].
class _PaneItemSemantics extends StatelessWidget {
  /// Adds the appropriate semantics for navigation drawer destinations to the
  /// [child].
  const _PaneItemSemantics({
    required this.child,
  });

  /// The widget that should receive the destination semantics.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final _PaneInfo destinationInfo = _PaneInfo.of(context);
    // The AnimationStatusBuilder will make sure that the semantics update to
    // "selected" when the animation status changes.
    return _StatusTransitionWidgetBuilder(
      animation: destinationInfo.selectedAnimation,
      builder: (BuildContext context, Widget? child) {
        return Semantics(
          selected: _isForwardOrCompleted(destinationInfo.selectedAnimation),
          container: true,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          child,
          Semantics(
            label: localizations.tabLabel(
              tabIndex: destinationInfo.index + 1,
              tabCount: destinationInfo.totalNumberOfDestinations,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that listens to an animation, and rebuilds when the animation changes
/// [AnimationStatus].
///
/// This can be more efficient than just using an [AnimatedBuilder] when you
/// only need to rebuild when the [Animation.status] changes, since
/// [AnimatedBuilder] rebuilds every time the animation ticks.
class _StatusTransitionWidgetBuilder extends StatusTransitionWidget {
  /// Creates a widget that rebuilds when the given animation changes status.
  const _StatusTransitionWidgetBuilder({
    required super.animation,
    required this.builder,
    this.child,
  });

  /// Called every time the [animation] changes [AnimationStatus].
  final TransitionBuilder builder;

  /// The child widget to pass to the [builder].
  ///
  /// If a [builder] callback's return value contains a subtree that does not
  /// depend on the animation, it's more efficient to build that subtree once
  /// instead of rebuilding it on every animation status change.
  ///
  /// Using this pre-built child is entirely optional, but can improve
  /// performance in some cases and is therefore a good practice.
  ///
  /// See: [AnimatedBuilder.child]
  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);
}

/// Inherited widget for passing data from the [NavigationPane] to the
/// [NavigationPane.destinations] children widgets.
///
/// Useful for building navigation destinations using:
/// `_PaneInfo.of(context)`.
class _PaneInfo extends InheritedWidget {
  /// Adds the information needed to build a navigation destination to the
  /// [child] and descendants.
  const _PaneInfo({
    required this.index,
    required this.totalNumberOfDestinations,
    required this.selectedAnimation,
    required this.indicatorColor,
    required this.indicatorShape,
    required this.onTap,
    required super.child,
    required this.tilePadding,
  });

  /// Which destination index is this in the navigation pane.
  ///
  /// For example:
  ///
  /// ```dart
  /// const NavigationPane(
  ///   children: <Widget>[
  ///     Text('Headline'), // This doesn't have index.
  ///     PaneItemDestination(
  ///       // This is destination index 0.
  ///       icon: Icon(Icons.surfing),
  ///       label: Text('Surfing'),
  ///     ),
  ///     PaneItemDestination(
  ///       // This is destination index 1.
  ///       icon: Icon(Icons.support),
  ///       label: Text('Support'),
  ///     ),
  ///     PaneItemDestination(
  ///       // This is destination index 2.
  ///       icon: Icon(Icons.local_hospital),
  ///       label: Text('Hospital'),
  ///     ),
  ///   ]
  /// )
  /// ```
  ///
  /// This is required for semantics, so that each destination can have a label
  /// "Tab 1 of 3", for example.
  final int index;

  /// How many total destinations are in this navigation drawer.
  ///
  /// This is required for semantics, so that each destination can have a label
  /// "Tab 1 of 4", for example.
  final int totalNumberOfDestinations;

  /// Indicates whether or not this destination is selected, from 0 (unselected)
  /// to 1 (selected).
  final Animation<double> selectedAnimation;

  /// The color of the indicator.
  ///
  /// This is used by destinations to override the indicator color.
  final Color? indicatorColor;

  /// The shape of the indicator.
  ///
  /// This is used by destinations to override the indicator shape.
  final ShapeBorder? indicatorShape;

  /// The callback that should be called when this destination is tapped.
  ///
  /// This is computed by calling [NavigationDrawer.onDestinationSelected]
  /// with [index] passed in.
  final VoidCallback onTap;

  /// Defines the padding for [PaneItemDestination] widgets (Drawer items).
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12.0)`.
  final EdgeInsetsGeometry tilePadding;

  /// Returns a non null [_PaneInfo].
  ///
  /// This will return an error if called with no [_PaneInfo]
  /// ancestor.
  ///
  /// Used by widgets that are implementing a navigation destination info to
  /// get information like the selected animation and destination number.
  static _PaneInfo of(BuildContext context) {
    final _PaneInfo? result =
        context.dependOnInheritedWidgetOfExactType<_PaneInfo>();
    assert(
      result != null,
      'Navigation destinations need a _PaneInfo parent, '
      'which is usually provided by NavigationDrawer.',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(_PaneInfo oldWidget) {
    return index != oldWidget.index ||
        totalNumberOfDestinations != oldWidget.totalNumberOfDestinations ||
        selectedAnimation != oldWidget.selectedAnimation ||
        onTap != oldWidget.onTap;
  }
}

// Builder widget for widgets that need to be animated from 0 (unselected) to
// 1.0 (selected).
//
// This widget creates and manages an [AnimationController] that it passes down
// to the child through the [builder] function.
//
// When [isSelected] is `true`, the animation controller will animate from
// 0 to 1 (for [duration] time).
//
// When [isSelected] is `false`, the animation controller will animate from
// 1 to 0 (for [duration] time).
//
// If [isSelected] is updated while the widget is animating, the animation will
// be reversed until it is either 0 or 1 again.
//
// Usage:
// ```dart
// _SelectableAnimatedBuilder(
//   isSelected: _isDrawerOpen,
//   builder: (context, animation) {
//     return AnimatedIcon(
//       icon: AnimatedIcons.menu_arrow,
//       progress: animation,
//       semanticLabel: 'Show menu',
//     );
//   }
// )
// ```
class _SelectableAnimatedBuilder extends StatefulWidget {
  /// Builds and maintains an [AnimationController] that will animate from 0 to
  /// 1 and back depending on when [isSelected] is true.
  const _SelectableAnimatedBuilder({
    required this.isSelected,
    this.duration = const Duration(milliseconds: 200),
    required this.builder,
  });

  /// When true, the widget will animate an animation controller from 0 to 1.
  ///
  /// The animation controller is passed to the child widget through [builder].
  final bool isSelected;

  /// How long the animation controller should animate for when [isSelected] is
  /// updated.
  ///
  /// If the animation is currently running and [isSelected] is updated, only
  /// the [duration] left to finish the animation will be run.
  final Duration duration;

  /// Builds the child widget based on the current animation status.
  ///
  /// When [isSelected] is updated to true, this builder will be called and the
  /// animation will animate up to 1. When [isSelected] is updated to
  /// `false`, this will be called and the animation will animate down to 0.
  final Widget Function(BuildContext, Animation<double>) builder;

  ///
  @override
  _SelectableAnimatedBuilderState createState() =>
      _SelectableAnimatedBuilderState();
}

/// State that manages the [AnimationController] that is passed to
/// [_SelectableAnimatedBuilder.builder].
class _SelectableAnimatedBuilderState extends State<_SelectableAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.duration = widget.duration;
    _controller.value = widget.isSelected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(_SelectableAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _controller,
    );
  }
}
