part of 'navigation_view.dart';

/// Detalhes completos do estado atual de um [PaneItemDestination].
///
/// Fornecido para builders customizados ([PaneItemWidgetBuilder]) para permitir
/// que o desenvolvedor crie qualquer padrão de design (Material, Fluent/WinUI,
/// Cupertino/macOS, Shadcn, etc.) reagindo às animações e estados nativos.
@immutable
class PaneItemStateDetails {
  const PaneItemStateDetails({
    required this.destination,
    required this.states,
    required this.isSelected,
    required this.isExpanded,
    required this.isFocused,
    required this.isHovered,
    required this.isPressed,
    required this.isInFlyoutMenu,
    required this.displayMode,
    required this.isPaneOpen,
    required this.paneAnimationProgress,
    required this.selectionAnimation,
    required this.expansionAnimation,
    required this.onTap,
  });

  final PaneItemDestination destination;
  final Set<WidgetState> states;
  final bool isSelected;
  final bool isExpanded;
  final bool isFocused;
  final bool isHovered;
  final bool isPressed;
  final bool isInFlyoutMenu;
  final DisplayMode displayMode;
  final bool isPaneOpen;
  final double paneAnimationProgress;
  final Animation<double> selectionAnimation;
  final Animation<double> expansionAnimation;
  final VoidCallback? onTap;
}

typedef PaneItemWidgetBuilder =
    Widget Function(
      BuildContext context,
      PaneItemStateDetails details,
    );

typedef PaneItemWrapperBuilder =
    Widget Function(
      BuildContext context,
      PaneItemStateDetails details,
      Widget child,
    );

/// Um item de destino de navegação de baixo nível e altamente customizável
/// para uso em um [NavigationPane].
///
/// Totalmente independente de `package:flutter/material.dart`.
class PaneItemDestination extends StatelessWidget {
  const PaneItemDestination({
    super.key,
    this.backgroundColor,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.trailing,
    this.enabled = true,
    this.children,
    this.initialExpanded = false,
    this.path,
    this.statesController,
    this.indicatorBuilder,
    this.chevronBuilder,
    this.interactionBuilder,
    this.itemBuilder,
    this.semanticLabel,
  });

  /// Define a cor de fundo customizada para este item específico.
  final Color? backgroundColor;

  /// O [Widget] (geralmente um [Icon]) exibido neste item.
  final Widget icon;

  /// O [Widget] opcional exibido quando este item está selecionado.
  final Widget? selectedIcon;

  /// O rótulo de texto exibido ao lado do ícone.
  final Widget label;

  /// Widget opcional exibido à direita do label (ex: badges, contadores).
  final Widget? trailing;

  /// Indica se este destino pode ser selecionado. Padrão: `true`.
  final bool enabled;

  /// Destinos filhos exibidos quando este item é expandido.
  final List<PaneItemDestination>? children;

  /// Define se este item deve iniciar expandido quando possuir [children].
  final bool initialExpanded;

  /// O caminho de rota para navegação baseada em path.
  final String? path;

  /// Controlador opcional para observar ou modificar os [WidgetState]s de fora.
  final WidgetStatesController? statesController;

  /// Construtor customizado para o indicador de seleção.
  final PaneItemWidgetBuilder? indicatorBuilder;

  /// Construtor customizado para o ícone de expansão (chevron).
  final PaneItemWidgetBuilder? chevronBuilder;

  /// Construtor wrapper para injetar efeitos interativos customizados (ex: ripple, glow, acrylic).
  final PaneItemWrapperBuilder? interactionBuilder;

  /// Construtor que substitui completamente a árvore visual interna do item,
  /// preservando a máquina de estados, foco, atalhos e hierarquia.
  final PaneItemWidgetBuilder? itemBuilder;

  /// Rótulo semântico para leitores de tela.
  final String? semanticLabel;

  /// Indica se este destino possui sub-itens.
  bool get hasChildren => children != null && children!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return _PaneItemBuilder(destination: this);
  }
}

class _PaneItemBuilder extends StatefulWidget {
  const _PaneItemBuilder({required this.destination});

  final PaneItemDestination destination;

  @override
  State<_PaneItemBuilder> createState() => _PaneItemBuilderState();
}

class _PaneItemBuilderState extends State<_PaneItemBuilder>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _selectionController;
  late CurvedAnimation _expansionAnimation;
  late CurvedAnimation _selectionAnimation;

  NavigationViewController? _navigationController;
  WidgetStatesController? _internalStatesController;
  WidgetStatesController get _statesController =>
      widget.destination.statesController ?? _internalStatesController!;

  bool _isSelected = false;
  bool _isExpanded = false;
  bool _animationsInitialized = false;

  bool? _wasPaneOpen;
  DisplayMode? _previousDisplayMode;

  final MenuController _menuController = MenuController();
  final FocusNode focusNode = FocusNode(debugLabel: 'PaneItemDestination');

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _handleTap(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _handleTap(),
    ),
  };

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
          TraversalDirection.down,
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
          TraversalDirection.up,
        ),
      };

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.destination.initialExpanded;
    if (widget.destination.statesController == null) {
      _internalStatesController = WidgetStatesController();
    }
    _statesController.addListener(_handleStatesChanged);
    _syncStaticStates();
  }

  @override
  void didUpdateWidget(covariant _PaneItemBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination.statesController !=
        widget.destination.statesController) {
      oldWidget.destination.statesController?.removeListener(
        _handleStatesChanged,
      );
      _internalStatesController?.dispose();
      _internalStatesController = null;

      if (widget.destination.statesController == null) {
        _internalStatesController = WidgetStatesController();
      }
      _statesController.addListener(_handleStatesChanged);
    }
    _syncStaticStates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = NavigationView.of(context).controller;
    if (_navigationController != newController) {
      _navigationController?.removeListener(_updateSelectionState);
      _navigationController = newController;
      _navigationController?.addListener(_updateSelectionState);
    }

    _initializeAnimations();
    _checkPaneStateChange();
  }

  void _handleStatesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncStaticStates() {
    _statesController.update(WidgetState.disabled, !widget.destination.enabled);
    _statesController.update(WidgetState.selected, _isSelected);
  }

  void _initializeAnimations() {
    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);
    final animationDuration =
        theme?.itemAnimationDuration ??
        defaults.itemAnimationDuration ??
        const Duration(milliseconds: 200);
    final animationCurve =
        theme?.itemAnimationCurve ??
        defaults.itemAnimationCurve ??
        Curves.easeInOut;

    if (!_animationsInitialized) {
      _expansionController = AnimationController(
        duration: animationDuration,
        vsync: this,
      );

      _selectionController = AnimationController(
        duration: animationDuration,
        vsync: this,
      );

      _expansionAnimation = CurvedAnimation(
        parent: _expansionController,
        curve: animationCurve,
      );

      _selectionAnimation = CurvedAnimation(
        parent: _selectionController,
        curve: animationCurve,
      );

      _isSelected = _isDestinationSelected();
      if (_isSelected) {
        _selectionController.value = 1.0;
      }

      if (_isExpanded) {
        _expansionController.value = 1.0;
      }

      _syncStaticStates();
      _animationsInitialized = true;
    } else {
      _expansionController.duration = animationDuration;
      _selectionController.duration = animationDuration;
      _expansionAnimation.curve = animationCurve;
      _selectionAnimation.curve = animationCurve;
    }
  }

  void _updateSelectionState() {
    if (!mounted || _navigationController == null) return;

    final bool wasSelected = _isSelected;
    _isSelected = _isDestinationSelected();

    if (_isSelected != wasSelected) {
      _statesController.update(WidgetState.selected, _isSelected);
      if (_animationsInitialized) {
        if (_isSelected) {
          _selectionController.forward();
        } else {
          _selectionController.reverse();
        }
      }
      setState(() {});
    }
  }

  void _checkPaneStateChange() {
    if (!mounted || !widget.destination.hasChildren) return;

    final navigationScope = _NavigationViewScope.of(context);
    final currentDisplayMode = navigationScope.displayMode;
    final currentPaneOpen = navigationScope.isPaneOpen;

    // Check if pane was open and now is closed (collapsed)
    final bool paneWasClosed = _wasPaneOpen == true && !currentPaneOpen;

    // Check if display mode changed from expanded/medium to a more compact state
    final bool displayModeCollapsed =
        _previousDisplayMode != null &&
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
    if (_navigationController == null || widget.destination.hasChildren) {
      return false;
    }

    if (widget.destination.path != null) {
      return _navigationController!.selectedPath == widget.destination.path;
    }

    // For index-based selection, we need to get the destination info
    final destinationInfo = _PaneDestinationInfo.maybeOf(context);
    if (destinationInfo?.index != null) {
      return _navigationController!.selectedIndex == destinationInfo!.index;
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
        // In compact mode with pane closed
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
      if (destinationInfo?.index != null) {
        _navigationController!.selectDestinationByIndex(
          destinationInfo!.index!,
        );
      }
    }
  }

  void _handleHoverChanged(bool isHovered) {
    _statesController.update(WidgetState.hovered, isHovered);
  }

  void _handleFocusChanged(bool isFocused) {
    final navigationScope = _NavigationViewScope.of(context);
    _statesController.update(
      WidgetState.focused,
      isFocused && navigationScope.isPaneOpen,
    );
  }

  void _handlePressedChanged(bool isPressed) {
    _statesController.update(WidgetState.pressed, isPressed);
  }

  @override
  void dispose() {
    _navigationController?.removeListener(_updateSelectionState);
    _statesController.removeListener(_handleStatesChanged);
    _internalStatesController?.dispose();
    focusNode.dispose();

    if (_animationsInitialized) {
      _expansionController.dispose();
      _selectionController.dispose();
    }

    super.dispose();
  }

  PaneItemStateDetails _createStateDetails(
    _NavigationViewScope scope, {
    bool isInFlyoutMenu = false,
  }) {
    final states = Set<WidgetState>.unmodifiable(_statesController.value);
    return PaneItemStateDetails(
      destination: widget.destination,
      states: states,
      isSelected: _isSelected,
      isExpanded: _isExpanded,
      isFocused: states.contains(WidgetState.focused),
      isHovered: states.contains(WidgetState.hovered),
      isPressed: states.contains(WidgetState.pressed),
      isInFlyoutMenu: isInFlyoutMenu,
      displayMode: scope.displayMode,
      isPaneOpen: scope.isPaneOpen,
      paneAnimationProgress: scope.paneActionMoveAnimationProgress,
      selectionAnimation: _selectionAnimation,
      expansionAnimation: _expansionAnimation,
      onTap: widget.destination.enabled ? _handleTap : null,
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);
    final navigationScope = _NavigationViewScope.of(context);
    final textDirection = Directionality.of(context);

    final details = _createStateDetails(navigationScope);
    final states = details.states;

    final EdgeInsets itemMargin =
        (theme?.itemMargin ?? defaults.itemMargin ?? EdgeInsets.zero).resolve(
          textDirection,
        );
    final EdgeInsets itemContentPadding =
        (theme?.itemContentPadding ??
                defaults.itemContentPadding ??
                EdgeInsets.zero)
            .resolve(textDirection);
    final Size itemSize =
        theme?.itemSize ?? defaults.itemSize ?? const Size.fromHeight(36.0);
    final double itemSpacing =
        theme?.itemSpacing ?? defaults.itemSpacing ?? 8.0;

    final ShapeBorder itemShape =
        theme?.itemShape?.resolve(states) ??
        defaults.itemShape?.resolve(states) ??
        const RoundedRectangleBorder();

    final Color itemBackgroundColor = _resolveBackgroundColor(
      theme,
      defaults,
      details,
    );
    final double itemElevation =
        theme?.itemElevation?.resolve(states) ??
        defaults.itemElevation?.resolve(states) ??
        0.0;
    final Color itemShadowColor =
        theme?.itemShadowColor?.resolve(states) ??
        defaults.itemShadowColor?.resolve(states) ??
        const Color(0x00000000);

    final double labelReveal = _getLabelOpacity(navigationScope);

    Widget itemCore;
    if (widget.destination.itemBuilder != null) {
      itemCore = widget.destination.itemBuilder!(context, details);
    } else {
      final Widget indicator = widget.destination.indicatorBuilder != null
          ? widget.destination.indicatorBuilder!(context, details)
          : AnimatedBuilder(
              animation: _selectionAnimation,
              builder: (context, _) {
                return PaneIndicator(
                  animation: _selectionAnimation,
                  color: theme?.indicatorColor ?? defaults.indicatorColor!,
                  shape: theme?.indicatorShape ?? defaults.indicatorShape!,
                  width:
                      (theme?.indicatorSize ?? defaults.indicatorSize!).width,
                  height:
                      (theme?.indicatorSize ?? defaults.indicatorSize!).height,
                );
              },
            );

      final Widget leading = _buildIcon(
        context,
        details,
        widget.destination.icon,
        widget.destination.selectedIcon,
        theme,
        defaults,
      );

      final Widget label = _buildLabel(
        context,
        details,
        navigationScope,
        theme,
        defaults,
      );

      final Widget? trailing = _buildTrailingAndChevron(
        context,
        details,
        navigationScope,
        theme,
        defaults,
      );

      itemCore = _PaneItemRenderObjectWidget(
        minHeight: itemSize.height,
        preferredWidth: itemSize.width,
        padding: itemContentPadding,
        spacing: itemSpacing,
        labelRevealProgress: labelReveal,
        textDirection: textDirection,
        backgroundColor: itemBackgroundColor,
        shape: itemShape,
        elevation: itemElevation,
        shadowColor: itemShadowColor,
        indicator: indicator,
        leading: leading,
        label: label,
        trailing: trailing,
      );
    }

    Widget interactiveItem = Semantics(
      label: widget.destination.semanticLabel,
      selected: _isSelected,
      enabled: widget.destination.enabled,
      button: true,
      expanded: widget.destination.hasChildren ? _isExpanded : null,
      child: FocusableActionDetector(
        focusNode: focusNode,
        enabled: widget.destination.enabled,
        actions: _actions,
        onShowFocusHighlight: _handleFocusChanged,
        mouseCursor: widget.destination.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: MouseRegion(
          onEnter: widget.destination.enabled
              ? (_) => _handleHoverChanged(true)
              : null,
          onExit: widget.destination.enabled
              ? (_) => _handleHoverChanged(false)
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.destination.enabled ? _handleTap : null,
            onTapDown: widget.destination.enabled
                ? (_) => _handlePressedChanged(true)
                : null,
            onTapUp: widget.destination.enabled
                ? (_) => _handlePressedChanged(false)
                : null,
            onTapCancel: widget.destination.enabled
                ? () => _handlePressedChanged(false)
                : null,
            child: widget.destination.interactionBuilder != null
                ? widget.destination.interactionBuilder!(
                    context,
                    details,
                    itemCore,
                  )
                : itemCore,
          ),
        ),
      ),
    );

    if (widget.destination.hasChildren) {
      final bool isCompactClosed =
          navigationScope.displayMode == DisplayMode.medium &&
          !navigationScope.isPaneOpen;

      if (isCompactClosed) {
        interactiveItem = _wrapWithFlyoutMenu(
          context,
          interactiveItem,
          textDirection,
        );
      }
    }

    if (itemMargin != EdgeInsets.zero) {
      interactiveItem = Padding(padding: itemMargin, child: interactiveItem);
    }

    if (!widget.destination.hasChildren) {
      return interactiveItem;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        interactiveItem,
        if (_isExpanded) _buildChildrenSection(context),
      ],
    );
  }

  Color _resolveBackgroundColor(
    NavigationThemeData? theme,
    NavigationThemeData defaults,
    PaneItemStateDetails details,
  ) {
    if (widget.destination.backgroundColor != null && !details.isSelected) {
      return widget.destination.backgroundColor!;
    }

    if (details.isPressed) {
      final pressed =
          theme?.itemPressedBackgroundColor ??
          defaults.itemPressedBackgroundColor;
      if (pressed != null) return pressed;
    }

    if (details.isHovered) {
      final hover =
          theme?.itemHoverBackgroundColor ?? defaults.itemHoverBackgroundColor;
      if (hover != null) return hover;
    }

    if (details.isSelected) {
      final selected =
          theme?.itemSelectedBackgroundColor ??
          theme?.itemBackgroundColor?.resolve(details.states) ??
          defaults.itemSelectedBackgroundColor ??
          defaults.itemBackgroundColor?.resolve(details.states);
      if (selected != null) return selected;
    }

    return theme?.itemBackgroundColor?.resolve(details.states) ??
        defaults.itemBackgroundColor?.resolve(details.states) ??
        const Color(0x00000000);
  }

  Widget _buildIcon(
    BuildContext context,
    PaneItemStateDetails details,
    Widget icon,
    Widget? selectedIcon,
    NavigationThemeData? theme,
    NavigationThemeData defaults,
  ) {
    final states = details.states;

    Color? iconColor;
    if (!widget.destination.enabled) {
      iconColor =
          theme?.itemDisabledIconColor ?? defaults.itemDisabledIconColor;
    } else if (details.isSelected) {
      iconColor =
          theme?.itemSelectedIconColor ?? defaults.itemSelectedIconColor;
    } else if (details.isHovered) {
      iconColor =
          theme?.itemHoverIconColor ??
          defaults.itemHoverIconColor ??
          theme?.itemIconColor ??
          defaults.itemIconColor;
    } else {
      iconColor = theme?.itemIconColor ?? defaults.itemIconColor;
    }

    final iconSize = theme?.itemIconSize?.resolve(states);

    final iconTheme = IconThemeData(
      color:
          iconColor ??
          (theme?.iconTheme?.resolve(states)?.color ??
              defaults.iconTheme!.resolve(states)!.color),
      size:
          iconSize ??
          (theme?.iconTheme?.resolve(states)?.size ??
              defaults.iconTheme!.resolve(states)!.size),
    );
    final resolveIcon = details.isSelected && selectedIcon != null
        ? selectedIcon
        : icon;

    return AnimatedBuilder(
      animation: _selectionAnimation,
      child: resolveIcon,
      builder: (context, child) => IconTheme.merge(
        data: iconTheme,
        child: child!,
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context,
    PaneItemStateDetails details,
    _NavigationViewScope navigationScope,
    NavigationThemeData? theme,
    NavigationThemeData defaults,
  ) {
    final states = details.states;

    TextStyle? labelStyle;
    if (!widget.destination.enabled) {
      labelStyle =
          theme?.itemDisabledLabelStyle ?? defaults.itemDisabledLabelStyle;
    } else if (details.isSelected) {
      labelStyle =
          theme?.itemSelectedLabelStyle ?? defaults.itemSelectedLabelStyle;
    } else if (details.isHovered) {
      labelStyle =
          theme?.itemHoverLabelStyle ??
          defaults.itemHoverLabelStyle ??
          theme?.itemLabelStyle ??
          defaults.itemLabelStyle;
    } else {
      labelStyle = theme?.itemLabelStyle ?? defaults.itemLabelStyle;
    }

    final textStyle =
        labelStyle ??
        (theme?.labelTextStyle?.resolve(states) ??
            defaults.labelTextStyle!.resolve(states)!);

    final animationDuration =
        theme?.itemAnimationDuration ??
        defaults.itemAnimationDuration ??
        const Duration(milliseconds: 100);

    return AnimatedOpacity(
      duration: animationDuration,
      opacity: _getLabelOpacity(navigationScope),
      child: DefaultTextStyle(
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        child: widget.destination.label,
      ),
    );
  }

  Widget? _buildTrailingAndChevron(
    BuildContext context,
    PaneItemStateDetails details,
    _NavigationViewScope navigationScope,
    NavigationThemeData? theme,
    NavigationThemeData defaults,
  ) {
    final bool showChevron =
        widget.destination.hasChildren && _shouldShowChevron(navigationScope);
    final Widget? customTrailing = widget.destination.trailing;

    if (!showChevron && customTrailing == null) {
      return null;
    }

    Widget? chevronWidget;
    if (showChevron) {
      if (widget.destination.chevronBuilder != null) {
        chevronWidget = widget.destination.chevronBuilder!(context, details);
      } else {
        chevronWidget = _buildChevron(context, details, theme, defaults);
      }
    }

    if (customTrailing != null && chevronWidget != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.0,
        children: [customTrailing, chevronWidget],
      );
    }

    return chevronWidget ?? customTrailing;
  }

  Widget _buildChevron(
    BuildContext context,
    PaneItemStateDetails details,
    NavigationThemeData? theme,
    NavigationThemeData defaults,
  ) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    Color? chevronColor;
    if (details.isSelected) {
      chevronColor =
          theme?.itemSelectedChevronColor ?? defaults.itemSelectedChevronColor;
    } else if (details.isHovered) {
      chevronColor =
          theme?.itemChevronHoverColor ??
          defaults.itemChevronHoverColor ??
          theme?.itemChevronColor ??
          defaults.itemChevronColor;
    } else {
      chevronColor = theme?.itemChevronColor ?? defaults.itemChevronColor;
    }

    final chevronSize =
        theme?.itemChevronSize ?? defaults.itemChevronSize ?? 20.0;

    return AnimatedBuilder(
      animation: _expansionAnimation,
      builder: (context, _) {
        final angle =
            _expansionAnimation.value * 0.5 * math.pi * (isRTL ? -1.0 : 1.0);
        return Transform.rotate(
          angle: angle,
          child: _RawChevronIcon(
            size: chevronSize,
            color: chevronColor ?? const Color(0xFF888888),
            isRTL: isRTL,
          ),
        );
      },
    );
  }

  Widget _wrapWithFlyoutMenu(
    BuildContext context,
    Widget content,
    TextDirection textDirection,
  ) {
    return RawMenuAnchor(
      controller: _menuController,
      childFocusNode: focusNode,
      onCloseRequested: (hideOverlay) {
        hideOverlay();
      },
      onClose: _clearFocus,
      overlayBuilder: (BuildContext context, RawMenuOverlayInfo info) {
        final navTheme = NavigationTheme.of(context);
        final navDefaults = _NavigationDefaults(context);

        final Color overlayColor =
            navTheme?.backgroundColor ?? navDefaults.backgroundColor!;

        final Color overlayShadowColor =
            navTheme?.shadowColor ??
            navDefaults.shadowColor ??
            const Color(0x33000000);

        final double overlayElevation = navTheme?.elevation ?? 3.0;

        final ShapeBorder overlayShape =
            navTheme?.minimalShape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            );

        const EdgeInsetsGeometry overlayPadding = EdgeInsets.all(4);

        final screenSize = MediaQuery.sizeOf(context);
        const double menuMinWidth = 168.0;

        double? leftPos;
        double? rightPos;

        if (textDirection == TextDirection.rtl) {
          rightPos = screenSize.width - info.anchorRect.left;

          if (info.anchorRect.left < menuMinWidth) {
            rightPos = null;
            leftPos = info.anchorRect.right;
          }
        } else {
          leftPos = info.anchorRect.right;

          if (leftPos + menuMinWidth > screenSize.width) {
            leftPos = null;
            rightPos = screenSize.width - info.anchorRect.left;
          }
        }

        double top = info.anchorRect.top;
        final double maxTop = screenSize.height - 56.0;
        if (top > maxTop) top = maxTop;

        return Positioned(
          top: top,
          left: leftPos,
          right: rightPos,
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: TapRegion(
              groupId: info.tapRegionGroupId,
              onTapOutside: (PointerDownEvent event) {
                _menuController.close();
              },
              child: FocusScope(
                child: IntrinsicWidth(
                  child: PhysicalShape(
                    clipper: ShapeBorderClipper(
                      shape: overlayShape,
                      textDirection: textDirection,
                    ),
                    clipBehavior: Clip.antiAlias,
                    color: overlayColor,
                    elevation: overlayElevation,
                    shadowColor: overlayShadowColor,
                    child: CustomPaint(
                      foregroundPainter: _PaneShapeBorderPainter(
                        shape: overlayShape,
                        textDirection: textDirection,
                      ),
                      child: Padding(
                        padding: overlayPadding,
                        child: Shortcuts(
                          shortcuts: _shortcuts,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _buildMenuChildren(
                              context,
                              textDirection,
                              navTheme,
                              navDefaults,
                            ),
                          ),
                        ),
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

  List<Widget> _buildMenuChildren(
    BuildContext context,
    TextDirection textDirection,
    NavigationThemeData? theme,
    NavigationThemeData navDefaults,
  ) {
    if (!widget.destination.hasChildren) return [];

    final parentInfo = _PaneDestinationInfo.maybeOf(context);
    final parentIndex = parentInfo?.index ?? 0;

    int currentChildIndex = parentIndex + 1;
    final List<Widget> menuItems = [];

    for (final child in widget.destination.children!) {
      final int childFlatIndex = currentChildIndex;

      currentChildIndex += 1;
      if (child.hasChildren) {
        currentChildIndex += _countSlots(child.children!);
      }

      final bool isChildSelected = _isChildSelected(child, childFlatIndex);

      menuItems.add(
        _FlyoutMenuItem(
          destination: child,
          isSelected: isChildSelected,
          textDirection: textDirection,
          theme: theme,
          navDefaults: navDefaults,
          onPressed: child.enabled
              ? () {
                  _menuController.close();
                  _selectChild(child, childFlatIndex);
                }
              : null,
        ),
      );
    }
    return menuItems;
  }

  int _countSlots(List<PaneItemDestination> items) {
    int count = 0;
    for (final item in items) {
      count++;
      if (item.hasChildren) {
        count += _countSlots(item.children!);
      }
    }
    return count;
  }

  bool _isChildSelected(PaneItemDestination child, int childFlatIndex) {
    if (_navigationController == null) return false;

    // Check path-based selection first
    if (child.path != null) {
      return _navigationController!.selectedPath == child.path;
    }
    if (_navigationController!.selectedIndex != null) {
      // For index-based selection, we need to get the destination info
      return _navigationController!.selectedIndex == childFlatIndex;
    }

    return false;
  }

  void _selectChild(PaneItemDestination child, int childFlatIndex) {
    if (_navigationController == null || !child.enabled) return;

    if (child.path != null) {
      _navigationController!.selectDestinationByPath(child.path!);
      return;
    }

    _navigationController!.selectDestinationByIndex(childFlatIndex);
  }

  Widget _buildChildrenSection(BuildContext context) {
    final theme = NavigationTheme.of(context);
    final defaults = _NavigationDefaults(context);

    // Get children properties from theme
    final childrenIndent =
        theme?.itemChildrenIndent ?? defaults.itemChildrenIndent ?? 16.0;
    final childrenSpacing =
        theme?.itemChildrenSpacing ?? defaults.itemChildrenSpacing ?? 0.0;

    final parentInfo = _PaneDestinationInfo.maybeOf(context);
    final parentIndex = parentInfo?.index ?? 0;

    final List<Widget> childWidgets = [];
    int currentChildIndex = parentIndex + 1;

    for (int i = 0; i < widget.destination.children!.length; i++) {
      final child = widget.destination.children![i];

      childWidgets.add(
        _PaneDestinationInfo(
          index: currentChildIndex,
          path: child.path,
          child: child,
        ),
      );

      currentChildIndex += 1;
      if (child.hasChildren) {
        currentChildIndex += _countSlots(child.children!);
      }
    }

    return SizeTransition(
      sizeFactor: _expansionAnimation,
      axisAlignment: -1.0,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: childrenIndent),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: childrenSpacing,
          children: childWidgets,
        ),
      ),
    );
  }
}

// ============================================================================
// FLYOUT MENU ITEM (100% WIDGETS.DART, SEM MENUITEMBUTTON / BUTTONSTYLE)
// ============================================================================

class _FlyoutMenuItem extends StatefulWidget {
  const _FlyoutMenuItem({
    required this.destination,
    required this.isSelected,
    required this.textDirection,
    required this.theme,
    required this.navDefaults,
    required this.onPressed,
  });

  final PaneItemDestination destination;
  final bool isSelected;
  final TextDirection textDirection;
  final NavigationThemeData? theme;
  final NavigationThemeData navDefaults;
  final VoidCallback? onPressed;

  @override
  State<_FlyoutMenuItem> createState() => _FlyoutMenuItemState();
}

class _FlyoutMenuItemState extends State<_FlyoutMenuItem> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  Set<WidgetState> get _states => <WidgetState>{
    if (widget.isSelected) WidgetState.selected,
    if (!widget.destination.enabled) WidgetState.disabled,
    if (_isHovered) WidgetState.hovered,
    if (_isPressed) WidgetState.pressed,
    if (_isFocused) WidgetState.focused,
  };

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final navDefaults = widget.navDefaults;
    final states = _states;

    final TextStyle resolvedTextStyle =
        (widget.isSelected
            ? (theme?.itemSelectedLabelStyle ??
                  navDefaults.itemSelectedLabelStyle)
            : (theme?.itemLabelStyle ?? navDefaults.itemLabelStyle)) ??
        (theme?.labelTextStyle?.resolve(states) ??
            navDefaults.labelTextStyle!.resolve(states))!;

    final ShapeBorder indicatorShape =
        theme?.indicatorShape ??
        navDefaults.indicatorShape ??
        const StadiumBorder();

    final ShapeBorder itemShape =
        theme?.indicatorShape ??
        navDefaults.indicatorShape ??
        const StadiumBorder();

    final EdgeInsets padding =
        (theme?.itemContentPadding ??
                navDefaults.itemContentPadding ??
                const EdgeInsets.symmetric(horizontal: 12.0))
            .resolve(widget.textDirection);

    final double itemHeight = (theme?.itemSize ?? navDefaults.itemSize!).height;
    final double spacing = theme?.itemSpacing ?? navDefaults.itemSpacing ?? 8.0;

    final Size resolvedIndicatorSize =
        theme?.menuIndicatorSize ??
        navDefaults.menuIndicatorSize ??
        (theme?.indicatorSize ?? navDefaults.indicatorSize!);

    final AlignmentGeometry resolvedAlignment =
        theme?.menuIndicatorAlignment ??
        navDefaults.menuIndicatorAlignment ??
        AlignmentDirectional.center;

    Color overlayColor = const Color(0x00000000);
    if (_isPressed) {
      overlayColor =
          theme?.itemPressedBackgroundColor ??
          navDefaults.itemPressedBackgroundColor ??
          const Color(0x1F000000);
    } else if (_isHovered || _isFocused) {
      overlayColor =
          theme?.itemHoverBackgroundColor ??
          navDefaults.itemHoverBackgroundColor ??
          const Color(0x14000000);
    }

    Color? iconColor;
    if (!widget.destination.enabled) {
      iconColor =
          theme?.itemDisabledIconColor ?? navDefaults.itemDisabledIconColor;
    } else if (widget.isSelected) {
      iconColor =
          theme?.itemSelectedIconColor ?? navDefaults.itemSelectedIconColor;
    } else {
      iconColor = theme?.itemIconColor ?? navDefaults.itemIconColor;
    }

    final IconThemeData iconTheme = IconThemeData(
      color:
          iconColor ??
          theme?.iconTheme?.resolve(states)?.color ??
          navDefaults.iconTheme!.resolve(states)!.color,
      size:
          theme?.itemIconSize?.resolve(states) ??
          theme?.iconTheme?.resolve(states)?.size ??
          navDefaults.iconTheme!.resolve(states)!.size,
    );

    final Widget activeIcon =
        widget.isSelected && widget.destination.selectedIcon != null
        ? widget.destination.selectedIcon!
        : widget.destination.icon;

    final bool fillIndicatorWidth =
        resolvedIndicatorSize.width == double.infinity;
    final bool fillIndicatorHeight =
        resolvedIndicatorSize.height == double.infinity;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      enabled: widget.destination.enabled,
      child: FocusableActionDetector(
        enabled: widget.destination.enabled,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onPressed?.call(),
          ),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
            onInvoke: (_) => widget.onPressed?.call(),
          ),
        },
        onShowHoverHighlight: (v) => setState(() => _isHovered = v),
        onShowFocusHighlight: (v) => setState(() => _isFocused = v),
        mouseCursor: widget.destination.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: widget.destination.enabled
              ? (_) => setState(() => _isPressed = true)
              : null,
          onTapUp: widget.destination.enabled
              ? (_) => setState(() => _isPressed = false)
              : null,
          onTapCancel: widget.destination.enabled
              ? () => setState(() => _isPressed = false)
              : null,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: overlayColor,
              shape: itemShape,
            ),
            child: SizedBox(
              height: itemHeight,
              child: Stack(
                alignment: resolvedAlignment,
                textDirection: widget.textDirection,
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: resolvedAlignment,
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tightFor(
                          width: fillIndicatorWidth
                              ? double.infinity
                              : resolvedIndicatorSize.width,
                          height: fillIndicatorHeight
                              ? double.infinity
                              : resolvedIndicatorSize.height,
                        ),
                        child: AnimatedOpacity(
                          opacity: widget.isSelected ? 1.0 : 0.0,
                          duration:
                              theme?.itemAnimationDuration ??
                              navDefaults.itemAnimationDuration ??
                              const Duration(milliseconds: 200),
                          curve:
                              theme?.itemAnimationCurve ??
                              navDefaults.itemAnimationCurve ??
                              Curves.easeInOut,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              color:
                                  theme?.indicatorColor ??
                                  navDefaults.indicatorColor!,
                              shape: indicatorShape,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: padding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: spacing,
                      textDirection: widget.textDirection,
                      children: [
                        IconTheme.merge(data: iconTheme, child: activeIcon),
                        DefaultTextStyle.merge(
                          style: resolvedTextStyle,
                          child: widget.destination.label,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CAMADA RENDER OBJECT (MULTI-CHILD RENDER BOX DE ALTA PERFORMANCE)
// ============================================================================

enum _PaneItemSlot { indicator, leading, label, trailing }

class _PaneItemRenderObjectWidget extends MultiChildRenderObjectWidget {
  _PaneItemRenderObjectWidget({
    required this.minHeight,
    required this.preferredWidth,
    required this.padding,
    required this.spacing,
    required this.labelRevealProgress,
    required this.textDirection,
    required this.backgroundColor,
    required this.shape,
    required this.elevation,
    required this.shadowColor,
    required Widget indicator,
    required Widget leading,
    required Widget label,
    Widget? trailing,
  }) : super(
         children: <Widget>[
           _SlotTag(slot: _PaneItemSlot.indicator, child: indicator),
           _SlotTag(slot: _PaneItemSlot.leading, child: leading),
           _SlotTag(slot: _PaneItemSlot.label, child: label),
           if (trailing != null)
             _SlotTag(slot: _PaneItemSlot.trailing, child: trailing),
         ],
       );

  final double minHeight;
  final double? preferredWidth;
  final EdgeInsets padding;
  final double spacing;
  final double labelRevealProgress;
  final TextDirection textDirection;
  final Color backgroundColor;
  final ShapeBorder shape;
  final double elevation;
  final Color shadowColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPaneItemLayout(
      minHeight: minHeight,
      preferredWidth: preferredWidth,
      padding: padding,
      spacing: spacing,
      labelRevealProgress: labelRevealProgress,
      textDirection: textDirection,
      backgroundColor: backgroundColor,
      shape: shape,
      elevation: elevation,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderPaneItemLayout renderObject,
  ) {
    renderObject
      ..minHeight = minHeight
      ..preferredWidth = preferredWidth
      ..padding = padding
      ..spacing = spacing
      ..labelRevealProgress = labelRevealProgress
      ..textDirection = textDirection
      ..backgroundColor = backgroundColor
      ..shape = shape
      ..elevation = elevation
      ..shadowColor = shadowColor;
  }
}

class _SlotTag extends ParentDataWidget<_PaneItemParentData> {
  const _SlotTag({required this.slot, required super.child});

  final _PaneItemSlot slot;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _PaneItemParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _PaneItemRenderObjectWidget;
}

class _PaneItemParentData extends ContainerBoxParentData<RenderBox> {
  _PaneItemSlot? slot;
}

class _RenderPaneItemLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PaneItemParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PaneItemParentData> {
  _RenderPaneItemLayout({
    required double minHeight,
    required double? preferredWidth,
    required EdgeInsets padding,
    required double spacing,
    required double labelRevealProgress,
    required TextDirection textDirection,
    required Color backgroundColor,
    required ShapeBorder shape,
    required double elevation,
    required Color shadowColor,
  }) : _minHeight = minHeight,
       _preferredWidth = preferredWidth,
       _padding = padding,
       _spacing = spacing,
       _labelRevealProgress = labelRevealProgress,
       _textDirection = textDirection,
       _backgroundColor = backgroundColor,
       _shape = shape,
       _elevation = elevation,
       _shadowColor = shadowColor;

  double _minHeight;
  set minHeight(double value) {
    if (_minHeight == value) return;
    _minHeight = value;
    markNeedsLayout();
  }

  double? _preferredWidth;
  set preferredWidth(double? value) {
    if (_preferredWidth == value) return;
    _preferredWidth = value;
    markNeedsLayout();
  }

  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  double _labelRevealProgress;
  set labelRevealProgress(double value) {
    if (_labelRevealProgress == value) return;
    _labelRevealProgress = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  ShapeBorder _shape;
  set shape(ShapeBorder value) {
    if (_shape == value) return;
    _shape = value;
    markNeedsPaint();
  }

  double _elevation;
  set elevation(double value) {
    if (_elevation == value) return;
    _elevation = value;
    markNeedsPaint();
  }

  Color _shadowColor;
  set shadowColor(Color value) {
    if (_shadowColor == value) return;
    _shadowColor = value;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PaneItemParentData) {
      child.parentData = _PaneItemParentData();
    }
  }

  Map<_PaneItemSlot, RenderBox> get _slotMap {
    final map = <_PaneItemSlot, RenderBox>{};
    RenderBox? child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _PaneItemParentData;
      if (parentData.slot != null) {
        map[parentData.slot!] = child;
      }
      child = parentData.nextSibling;
    }
    return map;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _minHeight;

  @override
  double computeMaxIntrinsicHeight(double width) => _minHeight;

  @override
  double computeMinIntrinsicWidth(double height) {
    final slots = _slotMap;
    final leadingWidth =
        slots[_PaneItemSlot.leading]?.getMinIntrinsicWidth(height) ?? 0.0;
    return _padding.horizontal + leadingWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final slots = _slotMap;
    final leadingWidth =
        slots[_PaneItemSlot.leading]?.getMaxIntrinsicWidth(height) ?? 0.0;
    final labelWidth =
        slots[_PaneItemSlot.label]?.getMaxIntrinsicWidth(height) ?? 0.0;
    final trailingWidth =
        slots[_PaneItemSlot.trailing]?.getMaxIntrinsicWidth(height) ?? 0.0;

    double total = _padding.horizontal + leadingWidth;
    if (labelWidth > 0) total += _spacing + labelWidth;
    if (trailingWidth > 0) total += _spacing + trailingWidth;
    return total;
  }

  @override
  void performLayout() {
    final slots = _slotMap;
    final indicator = slots[_PaneItemSlot.indicator];
    final leading = slots[_PaneItemSlot.leading];
    final label = slots[_PaneItemSlot.label];
    final trailing = slots[_PaneItemSlot.trailing];

    final double targetWidth = constraints.constrainWidth(
      _preferredWidth ?? constraints.maxWidth,
    );
    final double targetHeight = constraints.constrainHeight(_minHeight);
    size = Size(targetWidth, targetHeight);

    if (indicator != null) {
      indicator.layout(BoxConstraints.tight(size), parentUsesSize: false);
      (indicator.parentData! as _PaneItemParentData).offset = Offset.zero;
    }

    final double innerMaxHeight = math.max(
      0.0,
      size.height - _padding.vertical,
    );
    final BoxConstraints looseInnerConstraints = BoxConstraints(
      maxWidth: math.max(0.0, size.width - _padding.horizontal),
      maxHeight: innerMaxHeight,
    );

    Size leadingSize = Size.zero;
    if (leading != null) {
      leading.layout(looseInnerConstraints, parentUsesSize: true);
      leadingSize = leading.size;
    }

    Size trailingSize = Size.zero;
    if (trailing != null) {
      trailing.layout(looseInnerConstraints, parentUsesSize: true);
      trailingSize = trailing.size;
    }

    final double availableAfterLeading =
        size.width - _padding.horizontal - leadingSize.width;
    final double requiredForTrailing = trailingSize.width > 0
        ? (_spacing + trailingSize.width)
        : 0.0;
    final double availableForLabel = math.max(
      0.0,
      availableAfterLeading - _spacing - requiredForTrailing,
    );

    Size labelSize = Size.zero;
    if (label != null) {
      label.layout(
        BoxConstraints(maxWidth: availableForLabel, maxHeight: innerMaxHeight),
        parentUsesSize: true,
      );
      labelSize = label.size;
    }

    final bool isRTL = _textDirection == TextDirection.rtl;
    final double startX = isRTL ? size.width - _padding.right : _padding.left;
    final double endX = isRTL ? _padding.left : size.width - _padding.right;

    if (leading != null) {
      final double dx = isRTL ? startX - leadingSize.width : startX;
      final double dy =
          _padding.top + (innerMaxHeight - leadingSize.height) / 2.0;
      (leading.parentData! as _PaneItemParentData).offset = Offset(dx, dy);
    }

    if (label != null) {
      final double dx = isRTL
          ? startX - leadingSize.width - _spacing - labelSize.width
          : startX + leadingSize.width + _spacing;
      final double dy =
          _padding.top + (innerMaxHeight - labelSize.height) / 2.0;
      (label.parentData! as _PaneItemParentData).offset = Offset(dx, dy);
    }

    if (trailing != null) {
      final double dx = isRTL ? endX : endX - trailingSize.width;
      final double dy =
          _padding.top + (innerMaxHeight - trailingSize.height) / 2.0;
      (trailing.parentData! as _PaneItemParentData).offset = Offset(dx, dy);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Rect rect = offset & size;

    if (_elevation > 0.0 && _shadowColor.a > 0.0) {
      final Path path = _shape.getOuterPath(
        rect,
        textDirection: _textDirection,
      );
      canvas.drawShadow(path, _shadowColor, _elevation, true);
    }

    if (_backgroundColor.a > 0.0) {
      final Paint bgPaint = Paint()
        ..color = _backgroundColor
        ..style = PaintingStyle.fill;
      final Path outerPath = _shape.getOuterPath(
        rect,
        textDirection: _textDirection,
      );
      canvas.drawPath(outerPath, bgPaint);
    }
    _shape.paint(canvas, rect, textDirection: _textDirection);

    final slots = _slotMap;
    final indicator = slots[_PaneItemSlot.indicator];
    final leading = slots[_PaneItemSlot.leading];
    final label = slots[_PaneItemSlot.label];
    final trailing = slots[_PaneItemSlot.trailing];

    if (indicator != null) {
      final pd = indicator.parentData! as _PaneItemParentData;
      context.paintChild(indicator, offset + pd.offset);
    }

    if (leading != null) {
      final pd = leading.parentData! as _PaneItemParentData;
      context.paintChild(leading, offset + pd.offset);
    }

    if (_labelRevealProgress > 0.01) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        (PaintingContext clippedContext, Offset clippedOffset) {
          if (label != null && label.size.width > 0) {
            final pd = label.parentData! as _PaneItemParentData;
            clippedContext.paintChild(label, clippedOffset + pd.offset);
          }
          if (trailing != null && trailing.size.width > 0) {
            final pd = trailing.parentData! as _PaneItemParentData;
            clippedContext.paintChild(trailing, clippedOffset + pd.offset);
          }
        },
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => size.contains(position);
}

// ============================================================================
// PINTORES VETORIAIS E COMPONENTES AUXILIARES (ZERO DEPENDÊNCIA DE MATERIAL)
// ============================================================================

/// Desenha o ícone de Chevron diretamente no Canvas sem precisar de MaterialIcons.
class _RawChevronIcon extends StatelessWidget {
  const _RawChevronIcon({
    required this.size,
    required this.color,
    required this.isRTL,
  });

  final double size;
  final Color color;
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ChevronPainter(color: color, isRTL: isRTL),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color, required this.isRTL});

  final Color color;
  final bool isRTL;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;
    final Path path = Path();

    if (isRTL) {
      path.moveTo(w * 0.60, h * 0.28);
      path.lineTo(w * 0.38, h * 0.50);
      path.lineTo(w * 0.60, h * 0.72);
    } else {
      path.moveTo(w * 0.40, h * 0.28);
      path.lineTo(w * 0.62, h * 0.50);
      path.lineTo(w * 0.40, h * 0.72);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isRTL != isRTL;
}

class _PaneShapeBorderPainter extends CustomPainter {
  const _PaneShapeBorderPainter({
    required this.shape,
    required this.textDirection,
  });

  final ShapeBorder shape;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    shape.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_PaneShapeBorderPainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.textDirection != textDirection;
}

class PaneIndicator extends StatelessWidget {
  const PaneIndicator({
    super.key,
    required this.animation,
    required this.color,
    required this.shape,
    required this.width,
    required this.height,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final Animation<double> animation;
  final Color color;
  final ShapeBorder shape;
  final double width;
  final double height;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Align(
        alignment: alignment,
        child: SizedBox(
          width: width == double.infinity ? double.infinity : width,
          height: height == double.infinity ? double.infinity : height,
          child: DecoratedBox(
            decoration: ShapeDecoration(color: color, shape: shape),
          ),
        ),
      ),
    );
  }
}

class _PaneDestinationInfo extends InheritedWidget {
  const _PaneDestinationInfo({this.index, this.path, required super.child});

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
