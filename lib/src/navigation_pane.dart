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
typedef DestinationSelectedIndex = void Function(int? index);
typedef DestinationSelectedPath = void Function(String? path);

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
    required this.destinations,
    this.footers,
    this.itemPadding,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.semanticLabel,
    this.shape,
    this.minimalShape,
    this.clipBehavior,
  }) : assert(elevation == null || elevation >= 0.0);

  /// The background color of the [Material] that holds the [NavigationPane]'s
  /// contents.
  ///
  /// If this is null, then [NavigationThemeData.backgroundColor] is used.
  /// If that is also null, then it falls back to [ColorScheme.surface].
  final Color? backgroundColor;

  /// The color used for the drop shadow to indicate elevation.
  ///
  /// If null, [NavigationThemeData.shadowColor] is used. If that
  /// is also null, the default value is [Colors.transparent] which
  /// indicates that no drop shadow will be displayed.
  ///
  /// See [Material.shadowColor] for more details on drop shadows.
  final Color? shadowColor;

  ///  The surface tint of the [Material] that holds the [NavigationPane]'s
  /// contents.
  ///
  /// If this is null, then [NavigationThemeData.surfaceTintColor] is used.
  /// If that is also null, then it falls back to [Material.surfaceTintColor]'s default.
  final Color? surfaceTintColor;

  /// The elevation of the [NavigationPane] itself.
  ///
  /// If null, [NavigationThemeData.elevation] is used. If that
  /// is also null, it will be 1.0.
  final double? elevation;

  /// The color of the [indicatorShape] when this destination is selected.
  ///
  /// If this is null, [NavigationThemeData.indicatorColor] is used.
  /// If that is also null, defaults to [ColorScheme.secondaryContainer].
  final Color? indicatorColor;

  /// The shape of the selected indicator.
  ///
  /// If this is null, [NavigationThemeData.indicatorShape] is used.
  /// If that is also null, defaults to [StadiumBorder].
  final ShapeBorder? indicatorShape;

  /// Defines the appearance of the items within the navigation pane.
  ///
  /// The list contains [PaneItemDestination] widgets and/or customized
  /// widgets like headlines and dividers.
  final List<Widget> destinations;

  /// Additional widgets displayed at the bottom of the navigation pane.
  ///
  /// These widgets are typically used for footers or additional controls that
  /// should appear at the bottom of the navigation pane.
  final List<Widget>? footers;

  /// Defines the padding for [PaneItemDestination] widgets (Pane items).
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12.0)`.
  final EdgeInsetsGeometry? itemPadding;

  /// The semantic label of the Pane used by accessibility frameworks to
  /// announce screen transitions when the Pane is opened and closed.
  ///
  /// If this label is not provided, it will default to
  /// [MaterialLocalizations.paneLabel].
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

  int _calculateTotalFlatSlotsRecursive(List<Widget> items) {
    int count = 0;
    for (final itemWidget in items) {
      if (itemWidget is PaneItemDestination) {
        final destination = itemWidget;
        count++; // For the PaneItemDestination itself (parent or leaf)
        if (destination.children != null && destination.children!.isNotEmpty) {
          // Each child of this PaneItemDestination will also occupy a flat slot.
          // These children are PaneItemDestination objects themselves.
          count += destination.children!.length;
        }
      }
      // Other widgets (like Dividers, Headers) don't contribute to selectable slots.
    }
    return count;
  }

  List<Widget> _buildHierarchyRecursive({
    required BuildContext context,
    required List<Widget> sourceItems,
    required NavigationViewController controller,
    required int currentGlobalSelectedIndex,
    required int initialFlatIndex,
    required int totalOverallSlots,
    required ValueChanged<int> updateFlatIndex,
  }) {
    final List<Widget> resultWidgets = [];
    int currentProcessingFlatIndex = initialFlatIndex;

    for (var itemDataWidget in sourceItems) {
      if (itemDataWidget is! PaneItemDestination) {
        // Non-destination items (Dividers, etc.)
        resultWidgets.add(itemDataWidget);
        continue;
      }

      final PaneItemDestination destinationData = itemDataWidget;
      final bool hasChildren = destinationData.children != null &&
          destinationData.children!.isNotEmpty;

      // This is the index the PaneItemDestination itself (parent or leaf) occupies in the flat list.
      final int itemSelfFlatIndex = currentProcessingFlatIndex;

      Widget itemWidget;

      if (hasChildren) {
        // Parent item: Not directly selectable, tap expands/collapses.
        // It needs _PaneDestinationInfo for its PaneItemBuilder to get parentIndex.
        itemWidget = _PaneDestinationInfo(
          index:
              itemSelfFlatIndex, // Parent's own slot index for child calculation
          path: destinationData
              .path, // Parent's own slot path for child calculation
          child: itemDataWidget, // The PaneItemDestination widget itself
        );
        // Advance flat index: 1 for parent + number of children slots
        currentProcessingFlatIndex +=
            1 + (destinationData.children?.length ?? 0);
      } else {
        // Leaf item: This is a directly selectable destination.
        final bool isSelected =
            controller.destinationType == DestinationTypes.byIndex
                ? itemSelfFlatIndex == currentGlobalSelectedIndex
                : destinationData.path == controller.selectedPath;

        itemWidget = _SelectableAnimatedBuilder(
          key: ValueKey('item_$itemSelfFlatIndex'), // Use its unique flat index
          animation: controller.getDestinationAnimation(itemSelfFlatIndex),
          isSelected: isSelected,
          child: _PaneDestinationInfo(
            index: itemSelfFlatIndex, // Leaf's own selectable index
            path: destinationData.path, // Leaf's own selectable path
            child: itemDataWidget, // The PaneItemDestination widget itself
          ),
        );
        // Advance flat index: 1 for this leaf item
        currentProcessingFlatIndex += 1;
      }
      resultWidgets.add(itemWidget);
    }
    // Update the caller's tracking of the flat index
    updateFlatIndex(currentProcessingFlatIndex);
    return resultWidgets;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final NavigationThemeData? paneTheme = NavigationTheme.of(context);
    final NavigationViewController navigationViewC =
        NavigationView.of(context).controller;
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

    final NavigationThemeData defaults = _NavigationDefaults(context);
    final ShapeBorder? effectiveShape =
        shape ?? paneTheme?.shape ?? defaults.shape;
    final ShapeBorder? effectiveMinimalShape =
        minimalShape ?? paneTheme?.minimalShape ?? defaults.minimalShape;

    // Get the selected index from the NavigationViewController
    final selectedIndex = navigationViewC.selectedIndex ?? 0;

    // Calculate total flat slots first
    final int totalCalculatedSlots =
        _calculateTotalFlatSlotsRecursive(destinations) +
            _calculateTotalFlatSlotsRecursive(footers ?? []);
    int currentFlatIdx = 0;

    final List<Widget> wrappedChildren = _buildHierarchyRecursive(
      context: context,
      sourceItems: destinations,
      controller: navigationViewC,
      currentGlobalSelectedIndex: selectedIndex,
      initialFlatIndex: currentFlatIdx,
      totalOverallSlots: totalCalculatedSlots,
      updateFlatIndex: (newIndex) => currentFlatIdx = newIndex,
    );

    final List<Widget> wrappedFooters = [];
    if (footers != null && footers!.isNotEmpty) {
      wrappedFooters.addAll(
        _buildHierarchyRecursive(
          context: context,
          sourceItems: footers!,
          controller: navigationViewC,
          currentGlobalSelectedIndex: selectedIndex,
          initialFlatIndex: currentFlatIdx,
          totalOverallSlots: totalCalculatedSlots,
          updateFlatIndex: (newIndex) => currentFlatIdx = newIndex,
        ),
      );
    }

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(
          width: isDisplayModeMinimal
              ? (paneTheme?.openWidth ?? kOpenNavigationPaneWidth)
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: wrappedChildren,
                ),
              ),
              if (wrappedFooters.isNotEmpty) ...wrappedFooters,
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
    required super.child,
  });

  final PaneController controller;

  @override
  bool updateShouldNotify(_PaneControllerScope old) {
    return controller != old.controller;
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

  final NavigationViewController paneController;

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
  /// If this is null, then [NavigationThemeData.scrimColor] is used. If that
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
  late final AnimationController _animationController;

  /// Use this property to customize how the pane will be displayed.
  /// [DisplayMode.auto] is used by default.
  DisplayMode get displayMode => mounted
      ? _NavigationViewScope.of(context).displayMode
      : DisplayMode.minimal;

  bool get isDisplayModeMinimal => displayMode == DisplayMode.minimal;
  bool get isDisplayModeCompact => displayMode == DisplayMode.medium;
  bool get isDisplayModeExpanded => displayMode == DisplayMode.expanded;

  bool _isDragging = false;
  bool _isHoveringResizeArea = false;

  SystemMouseCursor get _getCursor {
    if (_isDragging) {
      return SystemMouseCursors.resizeColumn;
    }

    if (_animationController.value < 0.1) {
      return switch (Directionality.of(context)) {
        TextDirection.rtl => SystemMouseCursors.resizeLeft,
        TextDirection.ltr => SystemMouseCursors.resizeRight,
      };
    }

    if (_animationController.value > 0.9) {
      return switch (Directionality.of(context)) {
        TextDirection.rtl => SystemMouseCursors.resizeRight,
        TextDirection.ltr => SystemMouseCursors.resizeLeft,
      };
    }

    return SystemMouseCursors.resizeColumn;
  }

  @override
  void initState() {
    super.initState();
    _animationController = widget.paneController.animationController;

    _animationController.addStatusListener(_animationStatusChanged);
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
    if (!mounted) return;
    switch (status) {
      case AnimationStatus.forward:
        if (isDisplayModeMinimal) {
          _ensureHistoryEntry();
        }
        break;
      case AnimationStatus.reverse:
        if (isDisplayModeMinimal) {
          _historyEntry?.remove();
          _historyEntry = null;
        }
        break;
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
    _animationController.stop();
    _isDragging = true;
    if (isDisplayModeMinimal) {
      _ensureHistoryEntry();
    }
  }

  void _handleDragCancel() {
    _isDragging = false;
    if (_animationController.isDismissed || _animationController.isAnimating) {
      return;
    }
    if (_animationController.value < 0.5) {
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

    final NavigationThemeData? paneTheme = NavigationTheme.of(context);
    final compactWidth = paneTheme?.compactWidth ?? kCompactNavigationPaneWidth;
    final openWidth = paneTheme?.openWidth ?? kOpenNavigationPaneWidth;

    // pane not being shown currently
    return !widget.isOpenPane && isDisplayModeCompact
        ? compactWidth
        : openWidth;
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
        _animationController.value -= delta;
      case TextDirection.ltr:
        _animationController.value += delta;
    }

    final bool opened = _animationController.value > 0.5;
    if (opened != _previouslyOpened) {
      opened ? widget.paneController.open() : widget.paneController.close();
    }
    _previouslyOpened = opened;
  }

  void _settle(DragEndDetails details) {
    _isDragging = false;

    if (_animationController.isDismissed) {
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
          _animationController.fling(velocity: -visualVelocity);
          break;
        case TextDirection.ltr:
          _animationController.fling(velocity: visualVelocity);
          break;
      }
    } else if (_animationController.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  void _handleHoverChanged(bool isHovering) {
    if (_isHoveringResizeArea != isHovering) {
      setState(() {
        _isHoveringResizeArea = isHovering;
      });
    }
  }

  /// Starts an animation to open the pane.
  ///
  /// Typically called by [NavigationViewState.openPane].
  void open() {
    widget.paneController.open();
  }

  /// Starts an animation to close the pane.
  void close() {
    widget.paneController.close();
  }

  late ColorTween _scrimColorTween;
  final GlobalKey _gestureDetectorKey = GlobalKey();

  ColorTween _buildScrimColorTween() {
    return ColorTween(
      begin: Colors.transparent,
      end: widget.scrimColor ??
          NavigationTheme.of(context)?.scrimColor ??
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
      dragAreaWidth = _kEdgeDragWidth +
          (paneIsStart
              ? (textDirection == TextDirection.ltr
                  ? padding.left
                  : padding.right)
              : (textDirection == TextDirection.rtl
                  ? padding.right
                  : padding.left));
    }

    if (_animationController.status == AnimationStatus.dismissed &&
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
                          color: _scrimColorTween.evaluate(
                            _animationController,
                          ),
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
                      : _animationController.value,
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
                      onEnter: (_) => _handleHoverChanged(true),
                      onExit: (_) => _handleHoverChanged(false),
                      cursor: _getCursor,
                      child: const SizedBox(
                        width: 15,
                        height: double.infinity,
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
