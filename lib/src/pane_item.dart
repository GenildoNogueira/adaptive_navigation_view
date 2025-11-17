part of 'navigation_view.dart';

/// A navigation destination item for use in a [NavigationPane].
///
/// This widget represents a single navigation destination that can be selected
/// by the user. It supports hierarchical navigation with child destinations,
/// icons, labels, and both path-based and index-based selection.
class PaneItemDestination extends StatelessWidget {
  /// Creates a pane item destination.
  const PaneItemDestination({
    super.key,
    this.backgroundColor,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.enabled = true,
    this.children,
    this.initialExpanded = false,
    this.path,
  });

  /// Sets the color of the [Material] that holds all of the [Pane]'s contents.
  ///
  /// If this is null, then [NavigationThemeData.backgroundColor] is used. If that
  /// is also null, then it falls back to [Material]'s default.
  final Color? backgroundColor;

  /// The [Widget] (usually an [Icon]) that's displayed for this
  /// [PaneItemDestination].
  ///
  /// The icon will use [NavigationThemeData.iconTheme]. If this is
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
  /// The icon will use [NavigationThemeData.iconTheme] with
  /// [WidgetState.selected]. If this is null, the default [IconThemeData]
  /// would use a size of 24.0 and [ColorScheme.onSecondaryContainer].
  final Widget? selectedIcon;

  /// The text label that appears on the right of the icon
  ///
  /// The accompanying [Text] widget will use
  /// [NavigationThemeData.labelTextStyle]. If this are null, the default
  /// text style would use [TextTheme.labelLarge] with [ColorScheme.onSurfaceVariant].
  final Widget label;

  /// Indicates that this destination is selectable.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Child destinations that appear when this item is expanded.
  ///
  /// If null or empty, this destination will be treated as a leaf node
  /// that can be directly selected. If non-empty, this destination becomes
  /// a parent node that can be expanded to show its children.
  final List<PaneItemDestination>? children;

  /// Whether this destination should be initially expanded when it has children.
  ///
  /// Only applies to destinations with children. Defaults to false.
  final bool initialExpanded;

  /// The navigation path for this destination.
  ///
  /// Used for path-based navigation. If provided, this destination can be
  /// selected using [NavigationViewController.selectDestinationByPath].
  final String? path;

  /// Whether this destination has child destinations.
  bool get hasChildren => children != null && children!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return _PaneItemBuilder(
      destination: this,
    );
  }
}

class _PaneItemBuilder extends StatefulWidget {
  const _PaneItemBuilder({
    required this.destination,
  });

  final PaneItemDestination destination;

  @override
  State<_PaneItemBuilder> createState() => _PaneItemBuilderState();
}

class _PaneItemBuilderState extends State<_PaneItemBuilder>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _selectionController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _selectionAnimation;

  NavigationViewController? _navigationController;
  bool _isSelected = false;
  bool _isExpanded = false;
  bool _animationsInitialized = false;

  // Track previous pane state to detect when it closes
  bool? _wasPaneOpen;
  DisplayMode? _previousDisplayMode;

  final MenuController _menuController = MenuController();
  final FocusNode focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _navigationController = NavigationView.of(context).controller;
    _navigationController?.addListener(_updateSelectionState);
    _isExpanded = widget.destination.initialExpanded;

    focusNode.addListener(_onFocusChange);
  }

  void _initializeAnimations() {
    if (_animationsInitialized) return;

    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);
    final animationDuration = theme?.itemAnimationDuration ??
        defaults.itemAnimationDuration ??
        const Duration(milliseconds: 200);
    final animationCurve = theme?.itemAnimationCurve ??
        defaults.itemAnimationCurve ??
        Curves.easeInOut;

    _expansionController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(
      CurvedAnimation(
        parent: _expansionController,
        curve: animationCurve,
      ),
    );

    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: animationCurve,
    );

    if (_isExpanded) {
      _expansionController.value = 1.0;
    }

    _animationsInitialized = true;
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = focusNode.hasFocus;
      });
    }
  }

  @override
  void didChangeDependencies() {
    _initializeAnimations();
    _checkPaneStateChange();
    super.didChangeDependencies();
  }

  void _updateSelectionState() {
    if (!mounted || _navigationController == null) return;

    final bool wasSelected = _isSelected;
    _isSelected = _isDestinationSelected();

    if (_isSelected != wasSelected) {
      if (_isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
    setState(() {});
  }

  void _checkPaneStateChange() {
    if (!mounted || !widget.destination.hasChildren) return;

    final navigationScope = _NavigationViewScope.of(context);
    final currentDisplayMode = navigationScope.displayMode;
    final currentPaneOpen = navigationScope.isPaneOpen;

    // Check if pane was open and now is closed (collapsed)
    final bool paneWasClosed = _wasPaneOpen == true && !currentPaneOpen;

    // Check if display mode changed from expanded/medium to a more compact state
    final bool displayModeCollapsed = _previousDisplayMode != null &&
        (_previousDisplayMode == DisplayMode.expanded ||
            _previousDisplayMode == DisplayMode.medium) &&
        (currentDisplayMode == DisplayMode.minimal ||
            (currentDisplayMode == DisplayMode.medium && !currentPaneOpen));

    // If pane closed or display mode became more compact, collapse expanded items
    if ((paneWasClosed || displayModeCollapsed) && _isExpanded) {
      _collapseItem();
    }

    if (paneWasClosed || displayModeCollapsed) {
      _clearFocus();
    }

    // Update tracking variables
    _wasPaneOpen = currentPaneOpen;
    _previousDisplayMode = currentDisplayMode;
  }

  void _clearFocus() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    // Fecha o menu se estiver aberto
    if (_menuController.isOpen) {
      _menuController.close();
    }
  }

  void _collapseItem() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _expansionController.reverse();
      });
    }
    _clearFocus();
  }

  bool _isDestinationSelected() {
    if (_navigationController == null) {
      return false;
    }

    if (widget.destination.hasChildren) {
      return false;
    }

    // Check path-based selection first
    if (widget.destination.path != null) {
      return _navigationController!.selectedPath == widget.destination.path;
    }

    // For index-based selection, we need to get the destination info
    final destinationInfo = _PaneDestinationInfo.maybeOf(context);
    if (destinationInfo != null) {
      return _navigationController!.selectedIndex == destinationInfo.index;
    }

    return false;
  }

  void _handleTap() {
    if (!widget.destination.enabled) return;

    // Handle expansion for parent items
    if (widget.destination.hasChildren) {
      final navigationScope = _NavigationViewScope.of(context);
      final bool isCompactClosed =
          navigationScope.displayMode == DisplayMode.medium &&
              !navigationScope.isPaneOpen;

      if (isCompactClosed) {
        // In compact mode with pane closed, use MenuAnchor
        if (_menuController.isOpen) {
          _menuController.close();
        } else {
          _menuController.open();
          if (!focusNode.hasFocus) {
            focusNode.requestFocus();
          }
        }
      } else {
        // In other modes, toggle inline expansion
        _toggleExpansion();
      }
      return;
    }

    // Handle selection for leaf items
    if (_navigationController != null) {
      _selectDestination();
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expansionController.forward();
      } else {
        _expansionController.reverse();
      }
    });
  }

  void _selectDestination() {
    if (_navigationController == null) return;

    // Prefer path-based navigation
    if (widget.destination.path != null) {
      _navigationController!.selectDestinationByPath(widget.destination.path!);
    } else {
      // Fallback to index-based navigation
      final destinationInfo = _PaneDestinationInfo.maybeOf(context);
      if (destinationInfo != null) {
        _navigationController!.selectDestinationByIndex(
          destinationInfo.index!,
        );
      }
    }
  }

  @override
  void dispose() {
    _navigationController?.removeListener(_updateSelectionState);
    focusNode.removeListener(_onFocusChange);
    _expansionController.dispose();
    _selectionController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);
    final states = _getWidgetStates();

    final textDirection = Directionality.of(context);
    final itemMargin = theme?.itemMargin?.resolve(textDirection) ??
        defaults.itemMargin?.resolve(textDirection);
    final itemContentPadding =
        theme?.itemContentPadding?.resolve(textDirection) ??
            defaults.itemContentPadding;
    final itemSize = theme?.itemSize ?? defaults.itemSize;
    final itemShape = theme?.itemShape?.resolve(states) ??
        defaults.itemShape?.resolve(states);
    final itemBackgroundColor = _isSelected
        ? (theme?.itemSelectedBackgroundColor ??
            theme?.itemBackgroundColor?.resolve(states) ??
            defaults.itemSelectedBackgroundColor ??
            defaults.itemBackgroundColor?.resolve(states))
        : (theme?.itemBackgroundColor?.resolve(states) ??
            defaults.itemBackgroundColor?.resolve(states));
    final itemElevation = theme?.itemElevation?.resolve(states) ??
        defaults.itemElevation?.resolve(states);
    final itemShadowColor = theme?.itemShadowColor?.resolve(states) ??
        defaults.itemShadowColor?.resolve(states);
    final indicatorShape = theme?.indicatorShape ?? defaults.indicatorShape;
    final Color? hoverColor =
        theme?.itemHoverBackgroundColor ?? defaults.itemHoverBackgroundColor;
    final pressedColor = theme?.itemPressedBackgroundColor ??
        defaults.itemPressedBackgroundColor;

    return Column(
      children: [
        Container(
          margin: itemMargin,
          
          height: itemSize?.height,
          width: itemSize?.width,
          child: Stack(
            children: [
              Positioned.fill(
                child: Material(
                  type: MaterialType.button,
                  color: itemBackgroundColor ?? Colors.transparent,
                  shape: itemShape,
                  elevation: itemElevation ?? 0.0,
                  shadowColor: itemShadowColor,
                  child: InkWell(
                    onTap: _handleTap,
                    customBorder: indicatorShape,
                    hoverColor: hoverColor,
                    highlightColor: pressedColor,
                    child: Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [
                        AnimatedBuilder(
                          animation: _selectionAnimation,
                          builder: (context, child) {
                            return PaneIndicator(
                              animation: _selectionAnimation,
                              color: theme?.indicatorColor ??
                                  defaults.indicatorColor!,
                              shape: theme?.indicatorShape ??
                                  defaults.indicatorShape!,
                              width: (theme?.indicatorSize ??
                                      defaults.indicatorSize!)
                                  .width,
                              height: (theme?.indicatorSize ??
                                      defaults.indicatorSize!)
                                  .height,
                            );
                          },
                        ),
                        Padding(
                          padding: itemContentPadding ?? EdgeInsets.zero,
                          child: _buildContent(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.destination.hasChildren && _isExpanded)
          _buildChildrenSection(context),
      ],
    );
  }

  bool _shouldShowLabel(
    DisplayMode displayMode,
    bool isPaneOpen,
    double paneActionProgress,
  ) =>
      switch (displayMode) {
        DisplayMode.expanded => true,
        DisplayMode.minimal => isPaneOpen && paneActionProgress > 0.5,
        DisplayMode.medium => isPaneOpen && paneActionProgress > 0.5,
      };

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        DirectionalFocusIntent(TraversalDirection.down),
    SingleActivator(LogicalKeyboardKey.arrowUp):
        DirectionalFocusIntent(TraversalDirection.up),
  };

  Widget _buildContent(BuildContext context) {
    final navigationScope = _NavigationViewScope.of(context);
    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);

    final isLabelVisible = _shouldShowLabel(
      navigationScope.displayMode,
      navigationScope.isPaneOpen,
      navigationScope.paneActionMoveAnimationProgress,
    );

    final itemSpacing = theme?.itemSpacing ?? defaults.itemSpacing;

    final content = Focus(
      focusNode: focusNode,
      child: Row(
        spacing: itemSpacing ?? 0.0,
        children: [
          _buildIcon(
            context,
            _isSelected,
            widget.destination.icon,
            widget.destination.selectedIcon,
            theme,
            defaults,
          ),
          if (isLabelVisible)
            Expanded(
              child: _buildLabel(context, navigationScope, theme, defaults),
            ),
          if (widget.destination.hasChildren &&
              _shouldShowChevron(navigationScope)) ...[
            _buildChevron(context, navigationScope),
          ],
        ],
      ),
    );

    if (widget.destination.hasChildren) {
      final bool isCompactClosed =
          navigationScope.displayMode == DisplayMode.medium &&
              !navigationScope.isPaneOpen;

      if (isCompactClosed) {
        final textDirection = Directionality.of(context);

        return RawMenuAnchor(
          controller: _menuController,
          childFocusNode: focusNode,
          overlayBuilder: (BuildContext context, RawMenuOverlayInfo info) {
            return Positioned(
              top: info.anchorRect.bottom,
              left: textDirection == TextDirection.rtl
                  ? info.anchorRect.left - 168
                  : info.anchorRect.right,
              // The overlay will be treated as a dialog.
              child: Semantics(
                scopesRoute: true,
                explicitChildNodes: true,
                child: TapRegion(
                  groupId: info.tapRegionGroupId,
                  onTapOutside: (PointerDownEvent event) {
                    MenuController.maybeOf(context)?.close();
                    _clearFocus();
                  },
                  child: FocusScope(
                    child: IntrinsicWidth(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        constraints: const BoxConstraints(minWidth: 168),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: kElevationToShadow[4],
                        ),
                        child: Shortcuts(
                          shortcuts: _shortcuts,
                          child: Column(
                            children:
                                _buildMenuChildren(context, textDirection),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: content,
        );
      }
    }

    return content;
  }

  List<Widget> _buildMenuChildren(
    BuildContext context,
    TextDirection textDirection,
  ) {
    if (!widget.destination.hasChildren) return [];

    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);

    return widget.destination.children!.map((child) {
      final bool isChildSelected = _isChildSelected(child);
      final Set<WidgetState> states =
          isChildSelected ? {WidgetState.selected} : <WidgetState>{};

      final TextStyle resolvedTextStyle =
          (theme?.labelTextStyle?.resolve(states) ??
              defaults.labelTextStyle!.resolve(states))!;

      final OutlinedBorder indicatorShape =
          (theme?.indicatorShape ?? defaults.indicatorShape)! as OutlinedBorder;

      return MenuItemButton(
        //focusNode: focusNode,
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.pressed)) {
              return Theme.of(context).colorScheme.onSurface.withAlpha(40);
            }
            return null;
          }),
          shape: WidgetStatePropertyAll(indicatorShape),
        ),
        onPressed: () {
          _menuController.close();
          if (child.enabled) {
            _selectChild(child);
          }
        },
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          textDirection: textDirection,
          children: [
            if (isChildSelected)
              PaneIndicator(
                animation: const AlwaysStoppedAnimation(1.0),
                color: theme?.indicatorColor ?? defaults.indicatorColor!,
                shape: theme?.indicatorShape ?? defaults.indicatorShape!,
                width: (theme?.indicatorSize ?? defaults.indicatorSize!).width,
                height:
                    (theme?.indicatorSize ?? defaults.indicatorSize!).height,
              ),
            Row(
              spacing: (theme?.itemSpacing ?? defaults.itemSpacing!),
              textDirection: textDirection,
              children: [
                _buildIcon(
                  context,
                  isChildSelected,
                  child.icon,
                  child.selectedIcon,
                  theme,
                  defaults,
                ),
                DefaultTextStyle.merge(
                  style: resolvedTextStyle,
                  child: child.label,
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  bool _isChildSelected(PaneItemDestination child) {
    if (_navigationController == null) return false;

    // Check path-based selection first
    if (child.path != null) {
      return _navigationController!.selectedPath == child.path;
    }
    if (_navigationController!.selectedIndex != null) {
      // For index-based selection, we need to get the destination info
      final destinationInfo = _PaneDestinationInfo.maybeOf(context);
      if (destinationInfo != null) {
        return _navigationController!.selectedIndex == destinationInfo.index;
      }
    }

    return false;
  }

  void _selectChild(PaneItemDestination child) {
    if (_navigationController == null || !child.enabled) return;

    if (child.path != null) {
      _navigationController!.selectDestinationByPath(child.path!);
      return;
    }

    final destinationInfo = _PaneDestinationInfo.maybeOf(context);
    if (destinationInfo != null && destinationInfo.index != null) {
      if (destinationInfo.index == null) {
        _navigationController!.selectDestinationByIndex(destinationInfo.index!);
      }
    }
  }

  Widget _buildIcon(
    BuildContext context,
    bool isSelected,
    Widget icon,
    Widget? selectedIcon,
    NavigationThemeData? theme,
    NavigationThemeData defaults,
  ) {
    final states = _getWidgetStates();

    // Get icon properties from theme
    Color? iconColor;
    if (isSelected) {
      iconColor =
          theme?.itemSelectedIconColor ?? defaults.itemSelectedIconColor;
    } else if (!widget.destination.enabled) {
      iconColor =
          theme?.itemDisabledIconColor ?? defaults.itemDisabledIconColor;
    } else {
      iconColor = theme?.itemIconColor ?? defaults.itemIconColor;
    }

    final iconSize = theme?.itemIconSize?.resolve(states);

    // Fallback to default theme if no custom theme properties are set
    final iconTheme = IconThemeData(
      color: iconColor ??
          (theme?.iconTheme?.resolve(states)?.color ??
              defaults.iconTheme!.resolve(states)!.color),
      size: iconSize ??
          (theme?.iconTheme?.resolve(states)?.size ??
              defaults.iconTheme!.resolve(states)!.size),
    );

    return AnimatedBuilder(
      animation: _selectionAnimation,
      builder: (context, child) {
        final resolveIcon =
            isSelected && selectedIcon != null ? selectedIcon : icon;

        return IconTheme.merge(
          data: iconTheme,
          child: resolveIcon,
        );
      },
    );
  }

  Widget _buildLabel(
    BuildContext context,
    _NavigationViewScope navigationScope,
    NavigationThemeData? theme,
    NavigationThemeData defaults,
  ) {
    final states = _getWidgetStates();

    // Get label style from theme based on state
    TextStyle? labelStyle;
    if (_isSelected) {
      labelStyle =
          theme?.itemSelectedLabelStyle ?? defaults.itemSelectedLabelStyle;
    } else if (!widget.destination.enabled) {
      labelStyle =
          theme?.itemDisabledLabelStyle ?? defaults.itemDisabledLabelStyle;
    } else {
      labelStyle = theme?.itemLabelStyle ?? defaults.itemLabelStyle;
    }

    // Fallback to default theme if no custom style is set
    final textStyle = labelStyle ??
        (theme?.labelTextStyle?.resolve(states) ??
            defaults.labelTextStyle!.resolve(states)!);

    final animationDuration = theme?.itemAnimationDuration ??
        defaults.itemAnimationDuration ??
        const Duration(milliseconds: 100);

    return AnimatedOpacity(
      duration: animationDuration,
      opacity: _getLabelOpacity(navigationScope),
      child: DefaultTextStyle(
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        child: widget.destination.label,
      ),
    );
  }

  Widget _buildChevron(
    BuildContext context,
    _NavigationViewScope navigationScope,
  ) {
    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);

    // Get chevron properties from theme
    Color? chevronColor;
    if (_isSelected) {
      chevronColor =
          theme?.itemSelectedChevronColor ?? defaults.itemSelectedChevronColor;
    } else {
      chevronColor = theme?.itemChevronColor ?? defaults.itemChevronColor;
    }

    final chevronSize =
        theme?.itemChevronSize ?? defaults.itemChevronSize ?? 20.0;

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * math.pi,
          child: Icon(
            Icons.keyboard_arrow_right,
            size: chevronSize,
            color: chevronColor,
          ),
        );
      },
    );
  }

  Widget _buildChildrenSection(BuildContext context) {
    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);

    // Get children properties from theme
    final childrenIndent =
        theme?.itemChildrenIndent ?? defaults.itemChildrenIndent ?? 16.0;
    final childrenSpacing =
        theme?.itemChildrenSpacing ?? defaults.itemChildrenSpacing ?? 0.0;
    final animationCurve = theme?.itemAnimationCurve ??
        defaults.itemAnimationCurve ??
        Curves.easeInOut;

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _expansionController,
        curve: animationCurve,
      ),
      axisAlignment: -1.0,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: childrenIndent),
        child: Column(
          children: [
            for (int i = 0; i < widget.destination.children!.length; i++) ...[
              _ChildDestinationWrapper(
                parent: widget.destination,
                child: widget.destination.children![i],
              ),
              if (i < widget.destination.children!.length - 1 &&
                  childrenSpacing > 0)
                SizedBox(height: childrenSpacing),
            ],
          ],
        ),
      ),
    );
  }

  Set<WidgetState> _getWidgetStates() {
    final Set<WidgetState> states = <WidgetState>{};
    if (_isSelected) {
      states.add(WidgetState.selected);
    }
    if (!widget.destination.enabled) {
      states.add(WidgetState.disabled);
    }
    final navigationScope = _NavigationViewScope.of(context);
    if (_isFocused && navigationScope.isPaneOpen) {
      states.add(WidgetState.focused);
    }
    return states;
  }

  double _getLabelOpacity(_NavigationViewScope scope) =>
      switch (scope.displayMode) {
        DisplayMode.expanded => 1.0,
        DisplayMode.minimal =>
          scope.isPaneOpen ? scope.paneActionMoveAnimationProgress : 0.5,
        DisplayMode.medium =>
          scope.isPaneOpen ? scope.paneActionMoveAnimationProgress : 0.0,
      };

  bool _shouldShowChevron(_NavigationViewScope scope) =>
      switch (scope.displayMode) {
        DisplayMode.expanded => true,
        DisplayMode.minimal =>
          scope.isPaneOpen && scope.paneActionMoveAnimationProgress > 0.5,
        DisplayMode.medium => scope.isPaneOpen,
      };
}

class _ChildDestinationWrapper extends StatelessWidget {
  const _ChildDestinationWrapper({
    required this.parent,
    required this.child,
  });

  final PaneItemDestination parent;
  final PaneItemDestination child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class PaneIndicator extends StatelessWidget {
  const PaneIndicator({
    super.key,
    required this.animation,
    required this.color,
    required this.shape,
    required this.width,
    required this.height,
  });

  final Animation<double> animation;
  final Color color;
  final ShapeBorder shape;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: animation.value,
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: color,
            shape: shape,
          ),
        ),
      ),
    );
  }
}

class _PaneDestinationInfo extends InheritedWidget {
  const _PaneDestinationInfo({
    this.index,
    this.path,
    required super.child,
  });

  final int? index;
  final String? path;

  static _PaneDestinationInfo? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_PaneDestinationInfo>();
  }

  @override
  bool updateShouldNotify(_PaneDestinationInfo oldWidget) {
    return index != oldWidget.index || path != oldWidget.path;
  }
}

class _SelectableAnimatedBuilder extends StatefulWidget {
  /// Builds and maintains an [AnimationController] that will animate from 0 to
  /// 1 and back depending on when [isSelected] is true.
  const _SelectableAnimatedBuilder({
    super.key,
    required this.animation,
    required this.isSelected,
    required this.child,
  });

  final Animation<double> animation;
  final bool isSelected;
  final Widget child;

  @override
  State<_SelectableAnimatedBuilder> createState() =>
      _SelectableAnimatedBuilderState();
}

class _SelectableAnimatedBuilderState extends State<_SelectableAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
    );
    _controller.value = widget.isSelected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(_SelectableAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => widget.child,
    );
  }
}
