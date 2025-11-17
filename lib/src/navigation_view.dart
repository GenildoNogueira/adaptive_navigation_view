import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemMouseCursor, SystemUiOverlayStyle, LogicalKeyboardKey;

part 'navigation_pane.dart';
part 'navigation_view_controller.dart';
part 'navigation_app_bar.dart';
part 'pane_item.dart';
part 'navigation_pane_theme.dart';

const double _kIndicatorHeight = 36;
const double _kItemHeight = 36;

/// The width of the Compact Navigation Pane
const double kCompactNavigationPaneWidth = 80.0;

/// The width of the Open Navigation Pane
const double kOpenNavigationPaneWidth = 320.0;

/// You can use the PaneDisplayMode property to configure different
/// navigation styles, or display modes, for the NavigationView
enum DisplayMode {
  /// The pane is expanded and positioned to the left of the content.
  ///
  /// Use open navigation when:
  ///   * You have 5-10 equally important top-level navigation categories.
  ///   * You want navigation categories to be very prominent, with less
  ///     space for other app content.
  expanded,

  /// The pane shows only icons until opened and is positioned to the left
  /// of the content.
  medium,

  /// Only the menu button is shown until the pane is opened. When opened,
  /// it's positioned to the left of the content.
  minimal,
}

class WidthBreakpoint {
  final double? start;
  final double? end;

  const WidthBreakpoint({this.start, this.end})
      : assert(
          (start != null || end != null),
          'At least one of the parameters (start/end) must be provided.',
        ),
        assert(
          (start == null || end == null) || (start <= end),
          'Breakpoints must be sequential!',
        );

  // Construtor para breakpoints do tipo "start até infinito"
  const WidthBreakpoint.startFrom(double start) : this(start: start, end: null);

  // Construtor para breakpoints do tipo "até end"
  const WidthBreakpoint.endAt(double end) : this(start: null, end: end);

  // Verifica se um valor está dentro do intervalo
  bool contains(double value) {
    final isAboveStart = (start == null) || (value >= start!);
    final isBelowEnd = (end == null) || (value <= end!);
    return isAboveStart && isBelowEnd;
  }

  @override
  String toString() => 'WidthBreakpoint(start: $start, end: $end)';
}

enum _NavigationViewSlot {
  body,
  appBar,
  navigationPane,
  statusBar,
}

// Used to communicate the height of the Navigation's bottomNavigationBar and
// persistentFooterButtons to the LayoutBuilder which builds the Navigation's body.
//
// Navigation expects a _BodyBoxConstraints to be passed to the _BodyBuilder
// widget's LayoutBuilder, see _NavigationLayout.performLayout(). The BoxConstraints
// methods that construct new BoxConstraints objects, like copyWith() have not
// been overridden here because we expect the _BodyBoxConstraintsObject to be
// passed along unmodified to the LayoutBuilder. If that changes in the future
// then _BodyBuilder will assert.
class _BodyBoxConstraints extends BoxConstraints {
  const _BodyBoxConstraints({
    super.maxWidth,
    super.maxHeight,
    required this.appBarHeight,
    required this.contentPaneWidth,
  }) : assert(appBarHeight >= 0);

  final double appBarHeight;
  final double contentPaneWidth;

  // RenderObject.layout() will only short-circuit its call to its performLayout
  // method if the new layout constraints are not == to the current constraints.
  // If the height of the bottom widgets has changed, even though the constraints'
  // min and max values have not, we still want performLayout to happen.
  @override
  bool operator ==(Object other) {
    if (super != other) {
      return false;
    }
    return other is _BodyBoxConstraints &&
        other.appBarHeight == appBarHeight &&
        other.contentPaneWidth == contentPaneWidth;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        appBarHeight,
        contentPaneWidth,
      );
}

// Used when NavigationView.extendBody is true to wrap the NavigationView's body in a MediaQuery
// whose padding accounts for the height of the bottomNavigationBar and/or the
// persistentFooterButtons.
//
// The bottom widgets' height is passed along via the _BodyBoxConstraints parameter.
// The constraints parameter is constructed in_NavigationViewLayout.performLayout().
class _BodyBuilder extends StatelessWidget {
  const _BodyBuilder({
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final MediaQueryData metrics = MediaQuery.of(context);

        final double bottom = metrics.padding.bottom;

        final double top = metrics.padding.top;

        return MediaQuery(
          data: metrics.copyWith(
            padding: metrics.padding.copyWith(
              top: top,
              bottom: bottom,
            ),
          ),
          child: body,
        );
      },
    );
  }
}

class _NavigationLayout extends MultiChildLayoutDelegate {
  _NavigationLayout({
    required this.minInsets,
    required this.minViewPadding,
    required this.textDirection,
    required this.displayMode,
    required this.isOpenPane,
    required this.paneWidth,
    required this.paneActionMoveAnimationProgress,
  });

  final EdgeInsets minInsets;
  final EdgeInsets minViewPadding;
  final TextDirection textDirection;
  final DisplayMode displayMode;
  final bool isOpenPane;
  final double paneWidth;
  final double paneActionMoveAnimationProgress;

  @override
  void performLayout(Size size) {
    final BoxConstraints looseConstraints = BoxConstraints.loose(size);

    // This part of the layout has the same effect as putting the app bar and
    // body in a column and making the body flexible. What's different is that
    // in this case the app bar appears _after_ the body in the stacking order,
    // so the app bar's shadow is drawn on top of the body.

    final BoxConstraints fullWidthConstraints =
        looseConstraints.tighten(width: size.width);
    final double height = size.height;

    final isDisplayModeMinimal = displayMode == DisplayMode.minimal;

    final paddingLeft = math.max(minViewPadding.left, 0.0);
    final paddingRight = math.max(minViewPadding.right, 0.0);

    double contentTop = 0.0;
    double appBarHeight = 0.0;

    if (hasChild(_NavigationViewSlot.appBar)) {
      final appBarWidth = fullWidthConstraints.maxWidth;

      final BoxConstraints appBarConstraints = BoxConstraints(
        maxWidth: appBarWidth,
        maxHeight: fullWidthConstraints.maxHeight,
      );

      appBarHeight =
          layoutChild(_NavigationViewSlot.appBar, appBarConstraints).height;
      contentTop = appBarHeight;
      positionChild(_NavigationViewSlot.appBar, Offset.zero);
    }

    final paneDirectionRTL = textDirection == TextDirection.rtl;
    final offsetSafeAreaForPane = paneDirectionRTL ? paddingLeft : paddingRight;

    if (hasChild(_NavigationViewSlot.navigationPane)) {
      final BoxConstraints paneConstraints = BoxConstraints(
        maxWidth: isDisplayModeMinimal ? size.width : paneWidth,
        maxHeight: math.max(0.0, height - contentTop),
      );
      if (isDisplayModeMinimal) {
        layoutChild(
          _NavigationViewSlot.navigationPane,
          paneConstraints,
        );

        positionChild(
          _NavigationViewSlot.navigationPane,
          Offset(0.0, contentTop),
        );
      } else {
        final double panePositionX = paneDirectionRTL
            ? size.width - paneWidth - offsetSafeAreaForPane
            : offsetSafeAreaForPane;

        layoutChild(
          _NavigationViewSlot.navigationPane,
          paneConstraints,
        );

        positionChild(
          _NavigationViewSlot.navigationPane,
          Offset(panePositionX, contentTop),
        );
      }
    }

    // Set the content bottom to account for the greater of the height of any
    // bottom-anchored material widgets or of the keyboard or other
    // bottom-anchored system UI.
    final double contentBottom = math.max(
      0.0,
      height - math.max(minInsets.bottom, 0.0),
    );

    // Set the content pane to account for the greater of the width
    final double contentPane = math.max(
      isDisplayModeMinimal ? 0.0 : paneWidth + offsetSafeAreaForPane,
      0.0,
    );

    if (hasChild(_NavigationViewSlot.body)) {
      final bodyMaxWidth = fullWidthConstraints.maxWidth - contentPane;
      final double bodyMaxHeight = math.max(0.0, contentBottom - contentTop);

      final BoxConstraints bodyConstraints = _BodyBoxConstraints(
        maxWidth: bodyMaxWidth,
        maxHeight: bodyMaxHeight,
        appBarHeight: appBarHeight,
        contentPaneWidth: paneWidth,
      );

      layoutChild(_NavigationViewSlot.body, bodyConstraints);
      positionChild(
        _NavigationViewSlot.body,
        Offset(paneDirectionRTL ? 0.0 : contentPane, contentTop),
      );
    }

    if (hasChild(_NavigationViewSlot.statusBar)) {
      layoutChild(
        _NavigationViewSlot.statusBar,
        fullWidthConstraints.tighten(height: minInsets.top),
      );
      positionChild(_NavigationViewSlot.statusBar, Offset.zero);
    }
  }

  @override
  bool shouldRelayout(_NavigationLayout oldDelegate) {
    return oldDelegate.minInsets != minInsets ||
        oldDelegate.minViewPadding != minViewPadding ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.displayMode != displayMode ||
        oldDelegate.paneWidth != paneWidth ||
        oldDelegate.isOpenPane != isOpenPane;
  }
}

/// The NavigationView control provides top-level navigation for your app. It
/// adapts to a variety of screen sizes and supports both top and left
/// navigation styles.
class NavigationView extends StatefulWidget {
  const NavigationView({
    super.key,
    this.length = 0,
    this.initialIndex,
    this.initialPath,
    this.animationDuration,
    required this.controller,
    required this.appBar,
    required this.pane,
    this.body,
    this.onPaneChanged,
    this.preferredDisplayMode,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.paneDragStartBehavior = DragStartBehavior.start,
    this.paneScrimColor,
    this.paneEdgeDragWidth,
    this.paneEnableOpenDragGesture = true,
    this.compactBreakpoint = const WidthBreakpoint(end: 600),
    this.mediumBreakpoint = const WidthBreakpoint(start: 600, end: 840),
    this.expandedBreakpoint = const WidthBreakpoint(start: 840),
    this.compactPaneWidth,
    this.openPaneWidth,
  }) : assert(length >= 0);

  /// The total number of navigable destinations.
  final int length;

  /// The initial index of the selected destination.
  final int? initialIndex;

  /// The initial path of the selected destination.
  final String? initialPath;

  /// The duration of pane animations.
  final Duration? animationDuration;

  /// The navigation controller for this view.
  ///
  /// Provides access to navigation state and selection methods.
  final NavigationViewController controller;

  /// An [NavigationAppBar] to display at the top of the NavigationView.
  final PreferredSizeWidget appBar;

  /// A panel displayed to the side of the [body], often hidden on mobile
  /// devices. Swipes in from either left-to-right ([TextDirection.ltr]) or
  /// right-to-left ([TextDirection.rtl])
  ///
  /// Typically a [NavigationPane].
  ///
  /// To open the navigationPane, use the [NavigationViewState.openNavigationPane] function.
  ///
  /// To close the pane, use either [NavigationViewState.closePane], [Navigator.pop]
  /// or press the escape key on the keyboard.
  ///
  /// To disable the pane edge swipe on mobile, set the
  /// [NavigationView.paneEnableOpenDragGesture] to false. Then, use
  /// [NavigationViewState.openPane] to open the pane and [Navigator.pop] to close
  /// it.
  final Widget pane;

  /// The primary content of the [NavigationView].
  ///
  /// Displayed below the [NavigationAppBar], above the bottom of the ambient
  /// [MediaQuery]'s [MediaQueryData.viewInsets], and behind the
  /// [floatingActionButton] and [NavigationPane]. If [resizeToAvoidBottomInset] is
  /// false then the body is not resized when the onscreen keyboard appears,
  /// i.e. it is not inset by `viewInsets.bottom`.
  ///
  /// The widget in the body of the NavigationView is positioned at the top-left of
  /// the available space between the app bar and the bottom of the navigation. To
  /// center this widget instead, consider putting it in a [Center] widget and
  /// having that be the body. To expand this widget instead, consider
  /// putting it in a [SizedBox.expand].
  ///
  /// If you have a column of widgets that should normally fit on the screen,
  /// but may overflow and would in such cases need to scroll, consider using a
  /// [ListView] as the body of the navigation. This is also a good choice for
  /// the case where your body is a scrollable list.
  final Widget? body;

  /// Optional callback that is called when the [NavigationView.pane] is opened or closed.
  final PaneCallback? onPaneChanged;

  final DisplayMode? preferredDisplayMode;

  /// The color to use for the scrim that obscures primary content while pane is open.
  ///
  /// If this is null, then [NavigationThemeData.scrimColor] is used. If that
  /// is also null, then it defaults to [Colors.black54].
  final Color? paneScrimColor;

  /// The color of the [Material] widget that underlies the entire NavigationView.
  ///
  /// The theme's [Theme.colorSchema.background] by default.
  final Color? backgroundColor;

  /// If true the [body] and the navigation's floating widgets should size
  /// themselves to avoid the onscreen keyboard whose height is defined by the
  /// ambient [MediaQuery]'s [MediaQueryData.viewInsets] `bottom` property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// navigation, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool? resizeToAvoidBottomInset;

  /// Determines the way that drag start behavior is handled for the pane in a [NavigationView].
  ///
  /// If set to [DragStartBehavior.start], the drag behavior used for opening and closing a pane will begin at the position where the drag gesture won the arena.
  /// If set to [DragStartBehavior.down], it will begin at the position where a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make the drag animation smoother, while setting it to [DragStartBehavior.down] will make the drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  final DragStartBehavior paneDragStartBehavior;

  /// The width of the area within which a horizontal swipe will open the
  /// pane.
  ///
  /// By default, the value used is 20.0 added to the padding edge of
  /// `MediaQuery.paddingOf(context)` that corresponds to the surrounding
  /// [TextDirection]. This ensures that the drag area for notched devices is
  /// not obscured. For example, if `TextDirection.of(context)` is set to
  /// [TextDirection.ltr], 20.0 will be added to
  /// `MediaQuery.paddingOf(context).left`.
  final double? paneEdgeDragWidth;

  /// Determines if the [NavigationView.pane] can be opened with a drag
  /// gesture on mobile.
  ///
  /// On desktop platforms, the pane is not draggable.
  ///
  /// By default, the drag gesture is enabled on mobile.
  final bool paneEnableOpenDragGesture;

  /// The breakpoint value at which the navigation pane switches to compact mode.
  /// When the width is less than 600, the navigation pane is in compact mode.
  final WidthBreakpoint compactBreakpoint;

  /// The breakpoint value at which the navigation pane switches to medium mode.
  /// When the width is between 600 (inclusive) and 840 (exclusive), the navigation pane is in medium mode.
  final WidthBreakpoint mediumBreakpoint;

  /// The breakpoint value at which the navigation pane switches to expanded mode.
  /// When the width is between 840 (inclusive) and 1200 (exclusive), the navigation pane is in expanded mode.
  final WidthBreakpoint expandedBreakpoint;

  /// The width of the navigation pane when in compact mode.
  ///
  /// This value determines how wide the pane will be when the layout is
  /// considered compact, typically for narrow screens or when the pane is closed.
  ///
  /// Defaults to [kCompactNavigationPaneWidth].
  final double? compactPaneWidth;

  /// The width of the navigation pane when fully open.
  ///
  /// This value determines how wide the pane will be when it is expanded or
  /// visible in full mode (e.g., on wider screens or when explicitly opened).
  ///
  /// Defaults to [kOpenNavigationPaneWidth].
  final double? openPaneWidth;

  /// Finds the [NavigationViewState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will cause an
  /// assert in debug mode, and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// Typical usage of the [NavigationView.of] function is to call it from within the
  /// `build` method of a child of a [NavigationView].
  ///
  /// When the [NavigationView] is actually created in the same `build` function, the
  /// `context` argument to the `build` function can't be used to find the
  /// [NavigationView] (since it's "above" the widget being returned in the widget
  /// tree). In such cases, the following technique with a [Builder] can be used
  /// to provide a new scope with a [BuildContext] that is "under" the
  /// [NavigationView]:
  ///
  /// A more efficient solution is to split your build function into several
  /// widgets. This introduces a new context from which you can obtain the
  /// [NavigationView]. In this solution, you would have an outer widget that creates
  /// the [NavigationView] populated by instances of your new inner widgets, and then
  /// in these inner widgets you would use [NavigationView.of].
  ///
  /// A less elegant but more expedient solution is assign a [GlobalKey] to the
  /// [NavigationView], then use the `key.currentState` property to obtain the
  /// [NavigationView] rather than using the [NavigationView.of] function.
  ///
  /// If there is no [NavigationView] in scope, then this will throw an exception.
  /// To return null if there is no [NavigationView], use [maybeOf] instead.
  static NavigationViewState of(BuildContext context) {
    final NavigationViewState? result =
        context.findAncestorStateOfType<NavigationViewState>();
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'NavigationView.of() called with a context that does not contain a NavigationView.',
      ),
      ErrorDescription(
        'No NavigationView ancestor could be found starting from the context that was passed to NavigationView.of(). '
        'This usually happens when the context provided is from the same StatefulWidget as that '
        'whose build function actually creates the NavigationView widget being sought.',
      ),
      ErrorHint(
        'A more efficient solution is to split your build function into several widgets. This '
        'introduces a new context from which you can obtain the NavigationView. In this solution, '
        'you would have an outer widget that creates the NavigationView populated by instances of '
        'your new inner widgets, and then in these inner widgets you would use NavigationView.of().\n'
        'A less elegant but more expedient solution is assign a GlobalKey to the NavigationView, '
        'then use the key.currentState property to obtain the NavigationViewState rather than '
        'using the NavigationView.of() function.',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  /// Finds the [NavigationViewState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function to this one that throws if no instance
  ///    encloses the given context. Also includes some sample code in its
  ///    documentation.
  static NavigationViewState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<NavigationViewState>();
  }

  @override
  NavigationViewState createState() => NavigationViewState();
}

class NavigationViewState extends State<NavigationView>
    with TickerProviderStateMixin {
  final GlobalKey _bodyKey = GlobalKey();

  double? _appBarMaxHeight;

  // NAVIGATION PANE API

  final GlobalKey _paneKey = GlobalKey();

  late Animation<double> _paneWidthAnimation;

  NavigationViewController get controller => widget.controller;

  /// The max height the [NavigationView.appBar] uses.
  ///
  /// This is based on the appBar preferred height plus the top padding.
  double? get appBarMaxHeight => _appBarMaxHeight;

  /// Whether the [NavigationView.pane] is opened.
  ///
  /// See also:
  ///
  ///  * [NavigationViewState.openPane], which opens the [NavigationView.pane] of a
  ///    [NavigationView].
  bool get isPaneOpen => controller.isPaneOpen;

  /// Opens the [NavigationPane] (if any).
  ///
  /// If the NavigationView has a non-null [NavigationView.pane], this function will cause
  /// the pane to begin its entrance animation.
  ///
  /// Normally this is not needed since the [NavigationView] automatically shows an
  /// appropriate [IconButton], and handles the edge-swipe gesture, to show the
  /// pane.
  ///
  /// To close the pane, use either [Navigator.pop].
  ///
  /// See [NavigationView.of] for information about how to obtain the [NavigationViewState].
  void openPane() {
    controller.open();
  }

  /// Closes [NavigationView.pane] if it is currently opened.
  ///
  /// See [NavigationView.of] for information about how to obtain the [NavigationViewState].
  void closePane() {
    controller.close();
  }

  // iOS FEATURES - status bar tap, back gesture

  // On iOS, tapping the status bar scrolls the app's primary scrollable to the
  // top. We implement this by looking up the primary scroll controller and
  // scrolling it to the top when tapped.
  void _handleStatusBarTap() {
    final ScrollController? primaryScrollController =
        PrimaryScrollController.maybeOf(context);
    if (primaryScrollController != null && primaryScrollController.hasClients) {
      primaryScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCirc,
      );
    }
  }

  DisplayMode _getEffectiveDisplayMode(double width) {
    if (widget.preferredDisplayMode != null) {
      return widget.preferredDisplayMode!;
    }
    final double? compactEnd = widget.compactBreakpoint.end;
    final double? mediumStart = widget.mediumBreakpoint.start;
    final double? mediumEnd = widget.mediumBreakpoint.end;
    final double? expandedStart = widget.expandedBreakpoint.start;

    if (compactEnd != null && width <= compactEnd) {
      return DisplayMode.minimal;
    } else if (mediumStart != null &&
        mediumEnd != null &&
        width > mediumStart &&
        width <= mediumEnd) {
      return DisplayMode.medium;
    } else if (expandedStart != null && width >= expandedStart) {
      return DisplayMode.expanded;
    } else {
      return DisplayMode.minimal;
    }
  }

  double _calculatePaneWidth(DisplayMode displayMode) {
    final theme = NavigationTheme.of(context);
    final double openWidth =
        widget.openPaneWidth ?? theme?.openWidth ?? kOpenNavigationPaneWidth;
    final double compactWidth = widget.compactPaneWidth ??
        theme?.compactWidth ??
        kCompactNavigationPaneWidth;
    final double animationValue =
        controller.animation?.value ?? (isPaneOpen ? 1.0 : 0.0);

    return switch (displayMode) {
      DisplayMode.minimal => animationValue * openWidth,
      DisplayMode.medium => lerpDouble(
          compactWidth,
          openWidth,
          animationValue,
        )!,
      DisplayMode.expanded => openWidth,
    };
  }

  // INTERNALS

  bool get _resizeToAvoidBottomInset {
    return widget.resizeToAvoidBottomInset ?? true;
  }

  @override
  void initState() {
    super.initState();
    _paneWidthAnimation = Tween<double>(
      begin: widget.compactPaneWidth ?? kCompactNavigationPaneWidth,
      end: widget.openPaneWidth ?? kOpenNavigationPaneWidth,
    ).animate(
      CurvedAnimation(
        parent: controller.animation!,
        curve: Curves.easeInOutCubic,
      ),
    )..addListener(_rebuild);
  }

  @override
  void didUpdateWidget(NavigationView oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.controller.addListener(_onPaneControllerChanged);
    oldWidget.controller.removeListener(_onPaneControllerChanged);

    if (widget.preferredDisplayMode != oldWidget.preferredDisplayMode ||
        widget.compactBreakpoint != oldWidget.compactBreakpoint ||
        widget.mediumBreakpoint != oldWidget.mediumBreakpoint ||
        widget.expandedBreakpoint != oldWidget.expandedBreakpoint) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuild());
    }

    if (widget.compactPaneWidth != oldWidget.compactPaneWidth ||
        widget.openPaneWidth != oldWidget.openPaneWidth) {
      _paneWidthAnimation.removeListener(_rebuild);
      _paneWidthAnimation = Tween<double>(
        begin: widget.compactPaneWidth ?? kCompactNavigationPaneWidth,
        end: widget.openPaneWidth ?? kOpenNavigationPaneWidth,
      ).animate(
        CurvedAnimation(
          parent: controller.animation!,
          curve: Curves.easeInOutCubic,
        ),
      )..addListener(_rebuild);
    }

    // Sync animation controller value if isPaneOpen state changed externally
    // or if animation controller was reset/changed.
    if (controller.animation != null) {
      final targetValue = isPaneOpen ? 1.0 : 0.0;
      if (controller.animation!.value != targetValue &&
          !controller.animationController.isAnimating) {
        controller.animationController.value = targetValue;
      }
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onPaneControllerChanged);
    controller.dispose();
    _paneWidthAnimation.removeListener(_rebuild);
    super.dispose();
  }

  void _onPaneControllerChanged() {
    // This is called when paneController notifies listeners (e.g., open/close, animation value change)
    if (widget.onPaneChanged != null) {
      // Call the callback when the pane state changes
      if (mounted) {
        widget.onPaneChanged!(isPaneOpen);
      }
    }
    _rebuild(); // Always rebuild if the controller indicates a change
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  void _addIfNonNull(
    List<LayoutId> children,
    Widget? child,
    Object childId, {
    required bool removeLeftPadding,
    required bool removeTopPadding,
    required bool removeRightPadding,
    required bool removeBottomPadding,
    bool removeBottomInset = false,
    bool maintainBottomViewPadding = false,
  }) {
    MediaQueryData data = MediaQuery.of(context).removePadding(
      removeLeft: removeLeftPadding,
      removeTop: removeTopPadding,
      removeRight: removeRightPadding,
      removeBottom: removeBottomPadding,
    );
    if (removeBottomInset) {
      data = data.removeViewInsets(removeBottom: true);
    }

    if (maintainBottomViewPadding && data.viewInsets.bottom != 0.0) {
      data = data.copyWith(
        padding: data.padding.copyWith(bottom: data.viewPadding.bottom),
      );
    }

    if (child != null) {
      children.add(
        LayoutId(
          id: childId,
          child: MediaQuery(data: data, child: child),
        ),
      );
    }
  }

  void _buildNavigationPane(
    List<LayoutId> children,
    TextDirection textDirection,
  ) {
    _addIfNonNull(
      children,
      PaneController(
        key: _paneKey,
        alignment: PaneAlignment.start,
        paneController: controller,
        dragStartBehavior: widget.paneDragStartBehavior,
        scrimColor: widget.paneScrimColor,
        edgeDragWidth: widget.paneEdgeDragWidth,
        enableOpenDragGesture: widget.paneEnableOpenDragGesture,
        isOpenPane: isPaneOpen,
        child: widget.pane,
      ),
      _NavigationViewSlot.navigationPane,
      removeLeftPadding: textDirection == TextDirection.rtl,
      removeTopPadding: false,
      removeRightPadding: textDirection == TextDirection.ltr,
      removeBottomPadding: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasDirectionality(context));
    final ThemeData themeData = Theme.of(context);
    final TextDirection textDirection = Directionality.of(context);

    final List<LayoutId> children = <LayoutId>[];
    _addIfNonNull(
      children,
      widget.body == null
          ? null
          : _BodyBuilder(
              body: KeyedSubtree(
                key: _bodyKey,
                child: widget.body!,
              ),
            ),
      _NavigationViewSlot.body,
      removeLeftPadding: false,
      removeTopPadding: true,
      removeRightPadding: false,
      removeBottomPadding: false,
      removeBottomInset: _resizeToAvoidBottomInset,
    );

    final double topPadding = MediaQuery.paddingOf(context).top;
    _appBarMaxHeight = NavigationAppBar.preferredHeightFor(
          context,
          widget.appBar.preferredSize,
        ) +
        topPadding;
    assert(_appBarMaxHeight! >= 0.0 && _appBarMaxHeight!.isFinite);
    _addIfNonNull(
      children,
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: _appBarMaxHeight!),
        child: FlexibleSpaceBar.createSettings(
          currentExtent: _appBarMaxHeight!,
          child: widget.appBar,
        ),
      ),
      _NavigationViewSlot.appBar,
      removeLeftPadding: false,
      removeTopPadding: false,
      removeRightPadding: false,
      removeBottomPadding: true,
    );

    _buildNavigationPane(children, textDirection);

    switch (themeData.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _addIfNonNull(
          children,
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleStatusBarTap,
            // iOS accessibility automatically adds scroll-to-top to the clock in the status bar
            excludeFromSemantics: true,
          ),
          _NavigationViewSlot.statusBar,
          removeLeftPadding: false,
          removeTopPadding: true,
          removeRightPadding: false,
          removeBottomPadding: true,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        break;
    }

    // The minimum inserts for contents of the NavigationView to keep visible.
    final EdgeInsets minInsets = MediaQuery.paddingOf(context).copyWith(
      bottom: _resizeToAvoidBottomInset
          ? MediaQuery.viewInsetsOf(context).bottom
          : 0.0,
    );

    // The minimum viewPadding for interactive elements positioned by the
    // NavigationView to keep within safe interactive areas.
    final EdgeInsets minViewPadding =
        MediaQuery.viewPaddingOf(context).copyWith(
      bottom: _resizeToAvoidBottomInset &&
              MediaQuery.viewInsetsOf(context).bottom != 0.0
          ? 0.0
          : null,
    );

    return LayoutBuilder(
      builder: (context, consts) {
        final displayMode = _getEffectiveDisplayMode(consts.maxWidth);
        final paneWidth = _calculatePaneWidth(displayMode);

        /*if (width <= widget.compactBreakpoint.end!) {
          displayMode = DisplayMode.minimal;
          _paneWidthController.reverse();
        } else if (width > widget.mediumBreakpoint.begin! &&
            width <= widget.mediumBreakpoint.end!) {
          displayMode = DisplayMode.medium;
          if (!isPaneOpen) {
            _paneWidthController.reverse();
          } else {
            _paneWidthController.forward();
          }
        } else if (width >= widget.expandedBreakpoint.begin!) {
          displayMode = DisplayMode.expanded;
          _paneWidthController.forward();
          if (!isPaneOpen && displayMode != DisplayMode.expanded) {
            _paneWidthController.reverse();
          }
        }*/

        return _NavigationViewScope(
          isPaneOpen: isPaneOpen,
          displayMode: displayMode,
          paneActionMoveAnimationProgress:
              controller.animation?.value ?? (isPaneOpen ? 1.0 : 0.0),
          child: ScrollNotificationObserver(
            child: Material(
              color: widget.backgroundColor ?? themeData.colorScheme.surface,
              child: AnimatedBuilder(
                animation: controller.animation!,
                builder: (context, child) {
                  return Actions(
                    actions: <Type, Action<Intent>>{
                      DismissIntent: _DismissPaneAction(context),
                      TogglePaneIntent: CallbackAction<TogglePaneIntent>(
                        onInvoke: (TogglePaneIntent intent) {
                          controller.toggle();
                          return null;
                        },
                      ),
                    },
                    child: Shortcuts(
                      shortcuts: <ShortcutActivator, Intent>{
                        LogicalKeySet(
                          Theme.of(context).platform == TargetPlatform.macOS
                              ? LogicalKeyboardKey.meta
                              : LogicalKeyboardKey.control,
                          LogicalKeyboardKey.keyB,
                        ): const TogglePaneIntent(),
                      },
                      child: Focus(
                        autofocus: false,
                        child: CustomMultiChildLayout(
                          delegate: _NavigationLayout(
                            minInsets: minInsets,
                            minViewPadding: minViewPadding,
                            textDirection: textDirection,
                            displayMode: displayMode,
                            isOpenPane: isPaneOpen,
                            paneWidth: paneWidth,
                            paneActionMoveAnimationProgress:
                                controller.animation?.value ??
                                    (isPaneOpen ? 1.0 : 0.0),
                          ),
                          children: children,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<DisplayMode?>(
        'preferredDisplayMode',
        widget.preferredDisplayMode,
        defaultValue: null,
      ),
    );
    properties.add(
      EnumProperty<DisplayMode>(
        'effectiveDisplayMode',
        _getEffectiveDisplayMode(MediaQuery.sizeOf(context).width),
      ),
    );
  }
}

class TogglePaneIntent extends Intent {
  const TogglePaneIntent();
}

class _DismissPaneAction extends DismissAction {
  _DismissPaneAction(this.context);

  final BuildContext context;

  @override
  bool isEnabled(DismissIntent intent) {
    return NavigationView.of(context).isPaneOpen;
  }

  @override
  void invoke(DismissIntent intent) {
    NavigationView.of(context).closePane();
  }
}

class _NavigationViewScope extends InheritedWidget {
  const _NavigationViewScope({
    required this.isPaneOpen,
    required this.displayMode,
    required this.paneActionMoveAnimationProgress,
    required super.child,
  });

  final bool isPaneOpen;

  /// The current pane display mode according to the current state.
  final DisplayMode displayMode;

  /// The animation progress for pane move actions (0.0 to 1.0).
  final double paneActionMoveAnimationProgress;

  static _NavigationViewScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NavigationViewScope>();
  }

  static _NavigationViewScope of(BuildContext context) {
    return maybeOf(context)!;
  }

  @override
  bool updateShouldNotify(_NavigationViewScope oldWidget) {
    return oldWidget.isPaneOpen != isPaneOpen ||
        oldWidget.displayMode != displayMode ||
        oldWidget.paneActionMoveAnimationProgress !=
            paneActionMoveAnimationProgress;
  }
}
