part of 'navigation_view.dart';

/// The possible alignments of a [NavigationPane].
enum PaneAlignment {
  /// Denotes that the [NavigationPane] is at the start side of the [NavigationView].
  ///
  /// This corresponds to the left side when the text direction is left-to-right
  /// and the right side when the text direction is right-to-left.
  start,

  /// Denotes that the [NavigationPane] is at the end side of the [NavigationView].
  ///
  /// This corresponds to the right side when the text direction is left-to-right
  /// and the left side when the text direction is right-to-left.
  end,
}

const double _kEdgeDragWidth = 20.0;
const double _kMinFlingVelocity = 365.0;
const Duration _kBaseSettleDuration = Duration(milliseconds: 300);

typedef PaneCallback = void Function(bool isOpened);

class NavigationPane extends StatelessWidget {
  /// Creates a Material Design pane.
  ///
  /// Typically used in the [NavigationView.pane] property.
  ///
  /// The [elevation] must be non-negative.
  const NavigationPane({
    super.key,
    this.indicatorColor,
    this.indicatorShape,
    required this.children,
    this.footers,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.tilePadding,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.compactWidth,
    this.openWidth,
    this.semanticLabel,
    this.shape,
    this.minimalShape,
    this.clipBehavior,
  }) : assert(elevation == null || elevation >= 0.0);

  /// The background color of the [Material] that holds the [NavigationPane]'s
  /// contents.
  ///
  /// If this is null, then [PaneThemeData.backgroundColor] is used.
  /// If that is also null, then it falls back to [ColorScheme.surface].
  final Color? backgroundColor;

  /// The color used for the drop shadow to indicate elevation.
  ///
  /// If null, [PaneThemeData.shadowColor] is used. If that
  /// is also null, the default value is [Colors.transparent] which
  /// indicates that no drop shadow will be displayed.
  ///
  /// See [Material.shadowColor] for more details on drop shadows.
  final Color? shadowColor;

  ///  The surface tint of the [Material] that holds the [NavigationPane]'s
  /// contents.
  ///
  /// If this is null, then [PaneThemeData.surfaceTintColor] is used.
  /// If that is also null, then it falls back to [Material.surfaceTintColor]'s default.
  final Color? surfaceTintColor;

  /// The elevation of the [NavigationPane] itself.
  ///
  /// If null, [PaneThemeData.elevation] is used. If that
  /// is also null, it will be 1.0.
  final double? elevation;

  /// The color of the [indicatorShape] when this destination is selected.
  ///
  /// If this is null, [PaneThemeData.indicatorColor] is used.
  /// If that is also null, defaults to [ColorScheme.secondaryContainer].
  final Color? indicatorColor;

  /// The shape of the selected indicator.
  ///
  /// If this is null, [PaneThemeData.indicatorShape] is used.
  /// If that is also null, defaults to [StadiumBorder].
  final ShapeBorder? indicatorShape;

  /// Defines the appearance of the items within the navigation drawer.
  ///
  /// The list contains [PaneItemDestination] widgets and/or customized
  /// widgets like headlines and dividers.
  final List<Widget> children;

  /// Additional widgets displayed at the bottom of the navigation drawer.
  ///
  /// These widgets are typically used for footers or additional controls that
  /// should appear at the bottom of the navigation drawer.
  final List<Widget>? footers;

  /// The index into destinations for the current selected
  /// [PaneItemDestination] or null if no destination is selected.
  ///
  /// A valid [selectedIndex] satisfies 0 <= [selectedIndex] < number of [PaneItemDestination].
  /// For an invalid [selectedIndex] like `-1`, all destinations will appear unselected.
  final int selectedIndex;

  /// Called when one of the [PaneItemDestination] children is selected.
  ///
  /// This callback usually updates the int passed to [selectedIndex].
  ///
  /// Upon updating [selectedIndex], the [NavigationPane] will be rebuilt.
  final ValueChanged<int>? onDestinationSelected;

  /// Defines the padding for [PaneItemDestination] widgets (Pane items).
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12.0)`.
  final EdgeInsetsGeometry? tilePadding;

  /// The width of the pane.
  ///
  /// If this is null, then [PaneThemeData.compactWidth] is used. If that is also
  /// null, then it falls back to the Material spec's default (80.0).
  final double? compactWidth;

  /// The width of the pane.
  ///
  /// If this is null, then [PaneThemeData.openWidth] is used. If that is also
  /// null, then it falls back to the Material spec's default (360.0).
  final double? openWidth;

  /// The semantic label of the Pane used by accessibility frameworks to
  /// announce screen transitions when the Pane is opened and closed.
  ///
  /// If this label is not provided, it will default to
  /// [MaterialLocalizations.paneLabel].
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.namesRoute], for a description of how this
  ///    value is used.
  final String? semanticLabel;

  final ShapeBorder? shape;

  final ShapeBorder? minimalShape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// The [clipBehavior] argument specifies how to clip the pane's [shape].
  ///
  /// If the pane has a [shape], it defaults to [Clip.hardEdge]. Otherwise,
  /// defaults to [Clip.none].
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final PaneThemeData? paneTheme = PaneTheme.of(context);
    final _NavigationViewScope navigationViewScope =
        _NavigationViewScope.of(context);
    String? label = semanticLabel;
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        label = semanticLabel ?? MaterialLocalizations.of(context).drawerLabel;
    }

    final isDisplayModeMinimal =
        navigationViewScope.displayMode == DisplayMode.minimal;

    final PaneThemeData defaults = _PaneDefaults(context);
    final ShapeBorder? effectiveShape =
        shape ?? (paneTheme?.shape ?? defaults.shape);
    final ShapeBorder? effectiveMinimalShape =
        minimalShape ?? (paneTheme?.minimalShape ?? defaults.minimalShape);
    final int totalNumberOfDestinations =
        children.whereType<PaneItemDestination>().toList().length +
            (footers?.whereType<PaneItemDestination>().toList().length ?? 0);

    int destinationIndex = 0;
    final List<Widget> wrappedChildren = <Widget>[];
    Widget wrapChild(Widget child, int index) => _SelectableAnimatedBuilder(
          duration: const Duration(milliseconds: 500),
          isSelected: index == selectedIndex,
          builder: (BuildContext context, Animation<double> animation) {
            return _PaneInfo(
              index: index,
              totalNumberOfDestinations: totalNumberOfDestinations,
              selectedAnimation: animation,
              indicatorColor: indicatorColor,
              indicatorShape: indicatorShape,
              tilePadding:
                  tilePadding ?? const EdgeInsets.symmetric(horizontal: 12.0),
              onTap: () {
                if (onDestinationSelected != null) {
                  onDestinationSelected!(index);
                }
              },
              child: child,
            );
          },
        );

    for (int i = 0; i < children.length; i++) {
      if (children[i] is! PaneItemDestination) {
        wrappedChildren.add(children[i]);
      } else {
        wrappedChildren.add(wrapChild(children[i], destinationIndex));
        destinationIndex += 1;
      }
    }

    final List<Widget> wrappedFooters = <Widget>[];
    if (footers != null && footers!.isNotEmpty) {
      for (int i = 0; i < footers!.length; i++) {
        if (footers![i] is! PaneItemDestination) {
          wrappedFooters.add(footers![i]);
        } else {
          wrappedFooters.add(wrapChild(footers![i], destinationIndex));
          destinationIndex += 1;
        }
      }
    }

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(
          width: isDisplayModeMinimal
              ? (openWidth ?? paneTheme?.openWidth ?? kOpenNavigationPaneWidth)
              : null,
        ),
        child: Material(
          color: backgroundColor ??
              paneTheme?.backgroundColor ??
              defaults.backgroundColor,
          elevation: elevation ?? paneTheme?.elevation ?? defaults.elevation!,
          shadowColor:
              shadowColor ?? paneTheme?.shadowColor ?? defaults.shadowColor,
          surfaceTintColor: surfaceTintColor ??
              paneTheme?.surfaceTintColor ??
              defaults.surfaceTintColor,
          shape: isDisplayModeMinimal ? effectiveMinimalShape : effectiveShape,
          clipBehavior: effectiveMinimalShape != null || effectiveShape != null
              ? (clipBehavior ?? Clip.hardEdge)
              : Clip.none,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (isDisplayModeMinimal)
                      Align(
                        alignment: switch (Directionality.of(context)) {
                          TextDirection.rtl => Alignment.centerRight,
                          TextDirection.ltr => Alignment.centerLeft,
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10,
                          ),
                          child: PaneButton(
                            isClose: navigationViewScope.isPaneOpen,
                          ),
                        ),
                      ),
                    ...wrappedChildren,
                  ],
                ),
              ),
              ...wrappedFooters,
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaneControllerScope extends InheritedWidget {
  const _PaneControllerScope({
    required this.controller,
    required this.paneActionMoveAnimationProgress,
    required super.child,
  });

  final PaneController controller;

  final double paneActionMoveAnimationProgress;

  static _PaneControllerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_PaneControllerScope>();
  }

  static _PaneControllerScope of(BuildContext context) {
    return maybeOf(context)!;
  }

  @override
  bool updateShouldNotify(_PaneControllerScope old) {
    return controller != old.controller ||
        old.paneActionMoveAnimationProgress != paneActionMoveAnimationProgress;
  }
}

/// Provides interactive behavior for [NavigationPane] widgets.
///
/// Rarely used directly. Pane controllers are typically created automatically
/// by [NavigationView] widgets.
///
/// The Pane controller provides the ability to open and close a Pane, either
/// via an animation or via user interaction. When closed, the Pane collapses
/// to a translucent gesture detector that can be used to listen for edge
/// swipes.
///
/// See also:
///
///  * [NavigationPane], a container with the default width of a Pane.
///  * [NavigationView.pane], the [NavigationView] slot for showing a Pane.
class PaneController extends StatefulWidget {
  /// Creates a controller for a [NavigationPane].
  ///
  /// Rarely used directly.
  ///
  /// The [child] argument is typically a [NavigationPane].
  const PaneController({
    super.key,
    required this.child,
    required this.alignment,
    required this.isOpenPane,
    required this.paneController,
    required this.paneAnimationController,
    this.compactWidth = kCompactNavigationPaneWidth,
    this.openWidth = kOpenNavigationPaneWidth,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrimColor,
    this.edgeDragWidth,
    this.enableOpenDragGesture = true,
  });

  /// The widget below this widget in the tree.
  ///
  /// Typically a [NavigationPane].
  final Widget child;

  /// The alignment of the [NavigationPane].
  ///
  /// This controls the direction in which the user should swipe to open and
  /// close the pane.
  final PaneAlignment alignment;

  final NavigationPaneController paneController;

  final AnimationController paneAnimationController;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag behavior used for opening
  /// and closing a sidebar will begin at the position where the drag gesture won
  /// the arena. If set to [DragStartBehavior.down] it will begin at the position
  /// where a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for
  ///    the different behaviors.
  ///
  final DragStartBehavior dragStartBehavior;

  /// The color to use for the scrim that obscures the underlying content while
  /// a sidebar is open.
  ///
  /// If this is null, then [PaneThemeData.scrimColor] is used. If that
  /// is also null, then it defaults to [Colors.black54].
  final Color? scrimColor;

  /// Determines if the [NavigationPane] can be opened with a drag gesture.
  ///
  /// By default, the drag gesture is enabled.
  final bool enableOpenDragGesture;

  /// The width of the area within which a horizontal swipe will open the
  /// pane.
  ///
  /// By default, the value used is 20.0 added to the padding edge of
  /// `MediaQuery.paddingOf(context)` that corresponds to [alignment].
  /// This ensures that the drag area for notched devices is not obscured. For
  /// example, if [alignment] is set to [PaneAlignment.start] and
  /// `TextDirection.of(context)` is set to [TextDirection.ltr],
  /// 20.0 will be added to `MediaQuery.paddingOf(context).left`.
  final double? edgeDragWidth;

  /// Whether or not the pane is opened or closed.
  ///
  /// This parameter is primarily used by the state restoration framework
  /// to restore the pane's animation controller to the open or closed state
  /// depending on what was last saved to the target platform before the
  /// application was killed.
  final bool isOpenPane;

  final double compactWidth;

  final double openWidth;

  /// The closest instance of [PaneController] that encloses the given
  /// context, or null if none is found.
  ///
  /// {@tool snippet} Typical usage is as follows:
  ///
  /// ```dart
  /// PaneController? controller = PaneController.maybeOf(context);
  /// ```
  /// {@end-tool}
  ///
  /// Calling this method will create a dependency on the closest
  /// [PaneController] in the [context], if there is one.
  ///
  /// See also:
  ///
  /// * [PaneController.of], which is similar to this method, but asserts
  ///   if no [PaneController] ancestor is found.
  static PaneController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_PaneControllerScope>()
        ?.controller;
  }

  /// The closest instance of [PaneController] that encloses the given
  /// context.
  ///
  /// If no instance is found, this method will assert in debug mode and throw
  /// an exception in release mode.
  ///
  /// Calling this method will create a dependency on the closest
  /// [PaneController] in the [context].
  ///
  /// {@tool snippet} Typical usage is as follows:
  ///
  /// ```dart
  /// PaneController controller = PaneController.of(context);
  /// ```
  /// {@end-tool}
  static PaneController of(BuildContext context) {
    final PaneController? controller = maybeOf(context);
    assert(() {
      if (controller == null) {
        throw FlutterError(
          'PaneController.of() was called with a context that does not '
          'contain a PaneController widget.\n'
          'No PaneController widget ancestor could be found starting from '
          'the context that was passed to PaneController.of(). This can '
          'happen because you are using a widget that looks for a PaneController '
          'ancestor, but no such ancestor exists.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return controller!;
  }

  @override
  PaneControllerState createState() => PaneControllerState();
}

/// State for a [PaneController].
///
/// Typically used by a [NavigationView] to [open] and [close] the Pane.
class PaneControllerState extends State<PaneController>
    with SingleTickerProviderStateMixin {
  AnimationController get _controller => widget.paneAnimationController;

  /// Use this property to customize how the pane will be displayed.
  /// [PaneDisplayMode.auto] is used by default.
  DisplayMode get displayMode => mounted
      ? _NavigationViewScope.of(context).displayMode
      : DisplayMode.minimal;

  bool get isDisplayModeMinimal => displayMode == DisplayMode.minimal;
  bool get isDisplayModeCompact => displayMode == DisplayMode.medium;
  bool get isDisplayModeExpanded => displayMode == DisplayMode.expanded;

  SystemMouseCursor _paneCursor = SystemMouseCursors.resizeColumn;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_animationStatusChanged);
  }

  @override
  void dispose() {
    _historyEntry?.remove();
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrimColorTween = _buildScrimColorTween();
  }

  LocalHistoryEntry? _historyEntry;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(
          onRemove: _handleHistoryEntryRemoved,
          impliesAppBarDismissal: false,
        );
        route.addLocalHistoryEntry(_historyEntry!);
        FocusScope.of(context).setFirstFocus(_focusScopeNode);
      }
    }
  }

  void _animationStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        if (isDisplayModeMinimal) {
          _ensureHistoryEntry();
        }
      case AnimationStatus.reverse:
        if (isDisplayModeMinimal) {
          _historyEntry?.remove();
          _historyEntry = null;
        }
      case AnimationStatus.dismissed:
        break;
      case AnimationStatus.completed:
        break;
    }
  }

  void _handleHistoryEntryRemoved() {
    _historyEntry = null;
    close();
  }

  void _handleDragDown(DragDownDetails details) {
    _controller.stop();
    if (isDisplayModeMinimal) {
      _ensureHistoryEntry();
    }
  }

  void _handleDragCancel() {
    if (_controller.isDismissed || _controller.isAnimating) {
      return;
    }
    if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  final GlobalKey _paneKey = GlobalKey();

  double get _width {
    final RenderBox? box =
        _paneKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      return box.size.width;
    }
    // pane not being shown currently
    return !widget.isOpenPane && isDisplayModeCompact
        ? widget.compactWidth
        : widget.openWidth;
  }

  bool _previouslyOpened = false;

  void _move(DragUpdateDetails details) {
    double delta = details.primaryDelta! / _width;
    switch (widget.alignment) {
      case PaneAlignment.start:
        break;
      case PaneAlignment.end:
        delta = -delta;
    }
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        _controller.value -= delta;
      case TextDirection.ltr:
        _controller.value += delta;
    }

    if (!widget.isOpenPane && _controller.value > 0.5) {
      _paneCursor = SystemMouseCursors.resizeRight;
    } else if (widget.isOpenPane && _controller.value < 0.5) {
      _paneCursor = SystemMouseCursors.resizeLeft;
    } else {
      _paneCursor = SystemMouseCursors.resizeColumn;
    }

    final bool opened = _controller.value > 0.5;
    if (opened != _previouslyOpened) {
      widget.paneController.openOrClose(opened);
    }
    _previouslyOpened = opened;
  }

  void _settle(DragEndDetails details) {
    if (_controller.isDismissed) {
      return;
    }
    double visualVelocity = details.velocity.pixelsPerSecond.dx / _width;
    if (visualVelocity.abs() >= _kMinFlingVelocity) {
      switch (widget.alignment) {
        case PaneAlignment.start:
          break;
        case PaneAlignment.end:
          visualVelocity = -visualVelocity;
      }
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          _controller.fling(velocity: -visualVelocity);
          break;
        case TextDirection.ltr:
          _controller.fling(velocity: visualVelocity);
          break;
      }
    } else if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  /// Starts an animation to open the pane.
  ///
  /// Typically called by [NavigationViewState.openPane].
  void open() {
    _controller.fling();
    widget.paneController.openOrClose(true);
    _paneCursor = switch (Directionality.of(context)) {
      TextDirection.rtl => SystemMouseCursors.resizeRight,
      TextDirection.ltr => SystemMouseCursors.resizeLeft,
    };
  }

  /// Starts an animation to close the pane.
  void close() {
    _controller.fling(velocity: -1.0);
    widget.paneController.openOrClose(false);
    _paneCursor = switch (Directionality.of(context)) {
      TextDirection.rtl => SystemMouseCursors.resizeLeft,
      TextDirection.ltr => SystemMouseCursors.resizeRight,
    };
  }

  late ColorTween _scrimColorTween;
  final GlobalKey _gestureDetectorKey = GlobalKey();

  ColorTween _buildScrimColorTween() {
    return ColorTween(
      begin: Colors.transparent,
      end: widget.scrimColor ??
          PaneTheme.of(context)?.scrimColor ??
          Colors.black54,
    );
  }

  AlignmentDirectional get _paneOuterAlignment {
    return switch (widget.alignment) {
      PaneAlignment.start => AlignmentDirectional.centerStart,
      PaneAlignment.end => AlignmentDirectional.centerEnd,
    };
  }

  AlignmentDirectional get _paneInnerAlignment {
    return switch (widget.alignment) {
      PaneAlignment.start => AlignmentDirectional.centerEnd,
      PaneAlignment.end => AlignmentDirectional.centerStart,
    };
  }

  Widget _buildPane(BuildContext context) {
    final bool paneIsStart = widget.alignment == PaneAlignment.start;
    final TextDirection textDirection = Directionality.of(context);
    final bool isDesktop;
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        isDesktop = false;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        isDesktop = true;
    }

    double? dragAreaWidth = widget.edgeDragWidth;
    if (widget.edgeDragWidth == null) {
      final EdgeInsets padding = MediaQuery.paddingOf(context);
      dragAreaWidth = switch (textDirection) {
        TextDirection.ltr =>
          _kEdgeDragWidth + (paneIsStart ? padding.left : padding.right),
        TextDirection.rtl =>
          _kEdgeDragWidth + (paneIsStart ? padding.right : padding.left),
      };
    }

    if (_controller.status == AnimationStatus.dismissed &&
        isDisplayModeMinimal) {
      if (widget.enableOpenDragGesture && !isDesktop) {
        return Align(
          alignment: _paneOuterAlignment,
          child: GestureDetector(
            key: _gestureDetectorKey,
            onHorizontalDragDown: _handleDragDown,
            onHorizontalDragUpdate: _move,
            onHorizontalDragEnd: _settle,
            onHorizontalDragCancel: _handleDragCancel,
            behavior: HitTestBehavior.translucent,
            excludeFromSemantics: true,
            dragStartBehavior: widget.dragStartBehavior,
            child: Container(
              width: dragAreaWidth,
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      final bool platformHasBackButton;
      switch (Theme.of(context).platform) {
        case TargetPlatform.android:
          platformHasBackButton = true;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          platformHasBackButton = false;
      }

      final Widget child = _PaneControllerScope(
        controller: widget,
        paneActionMoveAnimationProgress: _controller.value,
        child: RepaintBoundary(
          child: Stack(
            children: <Widget>[
              if (isDisplayModeMinimal)
                BlockSemantics(
                  child: ExcludeSemantics(
                    // On Android, the back button is used to dismiss a modal.
                    excluding: platformHasBackButton,
                    child: GestureDetector(
                      onTap: close,
                      child: Semantics(
                        label: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        child: Container(
                          // The pane's "scrim"
                          color: _scrimColorTween.evaluate(_controller),
                        ),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: _paneOuterAlignment,
                child: Align(
                  alignment: _paneInnerAlignment,
                  widthFactor: isDisplayModeCompact || isDisplayModeExpanded
                      ? null
                      : _controller.value,
                  child: RepaintBoundary(
                    child: FocusScope(
                      key: _paneKey,
                      node: _focusScopeNode,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
              if (!isDisplayModeMinimal)
                Align(
                  alignment: _paneInnerAlignment,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _move,
                    onHorizontalDragEnd: _settle,
                    behavior: HitTestBehavior.translucent,
                    excludeFromSemantics: true,
                    dragStartBehavior: widget.dragStartBehavior,
                    child: MouseRegion(
                      cursor: _paneCursor,
                      child: Container(
                        width: 15,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

      if (isDesktop) {
        return child;
      }

      return GestureDetector(
        key: _gestureDetectorKey,
        onHorizontalDragDown: _handleDragDown,
        onHorizontalDragUpdate: _move,
        onHorizontalDragEnd: _settle,
        onHorizontalDragCancel: _handleDragCancel,
        excludeFromSemantics: true,
        dragStartBehavior: widget.dragStartBehavior,
        child: child,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return _buildPane(context);
  }
}

class _PaneDefaults extends PaneThemeData {
  _PaneDefaults(this.context)
      : super(
          elevation: 0.0,
        );

  final BuildContext context;
  late final TextDirection direction = Directionality.of(context);
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  Color? get surfaceTintColor => _colors.surfaceTint;

  @override
  Color get dividerColor => _colors.outlineVariant;

  @override
  Color? get shadowColor => Colors.transparent;

  // There isn't currently a token for this value, but it is shown in the spec,
  // so hard coding here for now.
  @override
  ShapeBorder? get shape => const RoundedRectangleBorder();

  // There isn't currently a token for this value, but it is shown in the spec,
  // so hard coding here for now.
  @override
  ShapeBorder? get minimalShape => RoundedRectangleBorder(
        borderRadius: const BorderRadiusDirectional.horizontal(
          end: Radius.circular(8.0),
        ).resolve(direction),
      );

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();

  @override
  Size? get indicatorSize => const Size.fromHeight(36.0);

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: 24.0,
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withOpacity(0.38)
            : states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = _textTheme.labelLarge!;
      return style.apply(
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withOpacity(0.38)
            : states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurfaceVariant,
      );
    });
  }
}
