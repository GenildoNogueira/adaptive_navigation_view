part of 'navigation_view.dart';

const double _kDefaultAppBarHeight = 50.0;
const double _kMaxTitleTextScaleFactor = 1.34;

/// The bar displayed at the top of the app. It can adapt itself to
/// all the display modes.
///
/// See also:
///
///   * [NavigationView], which uses this to render the app bar
class NavigationAppBar extends StatefulWidget implements PreferredSizeWidget {
  NavigationAppBar({
    super.key,
    this.centerTitle,
    this.title,
    this.titleSpacing = 16.0,
    this.titleTextStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.actions,
    this.appBarHeight,
    this.additionalLending,
    this.leadingWidth,
    this.backgroundColor,
    this.clipBehavior,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.systemOverlayStyle,
    this.elevation = 0.0,
    this.shadowColor = const Color(0x00000000),
  }) : preferredSize = _PreferredAppBarSize(appBarHeight);

  /// Used by [NavigationView] to compute its [NavigationAppBar]'s overall height.
  static double preferredHeightFor(BuildContext context, Size preferredSize) {
    if (preferredSize is _PreferredAppBarSize &&
        preferredSize.appBarHeight == null) {
      return _kDefaultAppBarHeight;
    }
    return preferredSize.height;
  }

  @override
  final Size preferredSize;

  final EdgeInsetsGeometry padding;

  /// Typically a [Text] widget that contains the app name.
  final Widget? title;

  /// Horizontal spacing around the [title].
  final double? titleSpacing;

  /// Default color for text and icons within the bar.
  final Color? foregroundColor;

  /// Icon theme for the leading element / button in the panel.
  final IconThemeData? iconTheme;

  /// Icon theme for the [actions] list.
  final IconThemeData? actionsIconTheme;

  /// Specifies whether the title should be centered.
  final bool? centerTitle;

  /// Text style for the [title].
  final TextStyle? titleTextStyle;

  /// Widgets displayed to the right of the [title].
  final List<Widget>? actions;

  /// Custom app bar height. Default: [_kDefaultAppBarHeight].
  final double? appBarHeight;

  /// Additional widget displayed before the panel button/title.
  final Widget? additionalLending;

  /// Width reserved for the leading area.
  final double? leadingWidth;

  /// Bar background color.
  final Color? backgroundColor;

  /// Clipping behavior.
  final Clip? clipBehavior;

  /// System status bar style.
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Optional bar lift.
  final double elevation;

  /// Shadow color when [elevation] > 0.
  final Color shadowColor;

  @override
  State<NavigationAppBar> createState() => _NavigationAppBarState();

  bool _getEffectiveCenterTitle() {
    bool platformCenter() {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          return false;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return actions == null || actions!.length < 2;
      }
    }

    return centerTitle ?? platformCenter();
  }
}

class _NavigationAppBarState extends State<NavigationAppBar> {
  static Brightness _estimateBrightnessForColor(Color color) {
    final double relativeLuminance = color.computeLuminance();
    const double kThreshold = 0.15;
    if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold) {
      return Brightness.light;
    }
    return Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final double topPadding = MediaQuery.viewPaddingOf(context).top;
    final NavigationThemeData? navTheme = NavigationTheme.of(context);
    final _NavigationViewScope navigationViewScope = _NavigationViewScope.of(
      context,
    );

    final bool isDisplayModeOpen =
        navigationViewScope.displayMode == DisplayMode.expanded;

    final Color backgroundColor =
        widget.backgroundColor ??
        navTheme?.backgroundColor ??
        _AppBarDefaults.resolveDefaultBackground(context);

    // Calculates defaults based on the actual luminance of the backgroundColor!
    // So, if the background changes to light or dark, the text and icons react instantly.
    final Brightness effectiveBrightness = _estimateBrightnessForColor(
      backgroundColor,
    );
    final _AppBarDefaults defaults = _AppBarDefaults(
      context,
      brightness: effectiveBrightness,
    );

    final Color foregroundColor =
        widget.foregroundColor ??
        navTheme?.itemLabelStyle?.color ??
        navTheme?.labelTextStyle?.resolve(const <WidgetState>{})?.color ??
        defaults.foregroundColor;

    final TextStyle titleTextStyle =
        widget.titleTextStyle ??
        defaults.titleTextStyle.copyWith(color: foregroundColor);

    final Color effectiveLeadingIconColor =
        widget.foregroundColor ??
        navTheme?.itemIconColor ??
        navTheme?.iconTheme?.resolve(const <WidgetState>{})?.color ??
        foregroundColor;

    final IconThemeData overallIconTheme =
        widget.iconTheme ??
        defaults.iconTheme.copyWith(color: effectiveLeadingIconColor);

    final IconThemeData actionsIconTheme =
        widget.actionsIconTheme ??
        widget.iconTheme ??
        defaults.actionsIconTheme.copyWith(color: foregroundColor);

    final double appBarHeight = widget.appBarHeight ?? _kDefaultAppBarHeight;

    Widget? title = widget.title;
    if (title != null) {
      title = Semantics(
        namesRoute: switch (defaultTargetPlatform) {
          TargetPlatform.android ||
          TargetPlatform.fuchsia ||
          TargetPlatform.linux ||
          TargetPlatform.windows => true,
          TargetPlatform.iOS || TargetPlatform.macOS => null,
        },
        header: true,
        child: title,
      );

      title = DefaultTextStyle(
        style: titleTextStyle,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: title,
      );

      // Set maximum text scale factor to [_kMaxTitleTextScaleFactor] for the
      // title to keep the visual hierarchy the same even with larger font
      // sizes. To opt out, wrap the [title] widget in a [MediaQuery] widget
      // with a different `TextScaler`.
      title = MediaQuery.withClampedTextScaling(
        maxScaleFactor: _kMaxTitleTextScaleFactor,
        child: title,
      );
    }

    Widget? actions;
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      actions = IconTheme.merge(
        data: actionsIconTheme,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foregroundColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.actions!,
          ),
        ),
      );
    }

    final Widget toolbar = Padding(
      padding: widget.padding,
      child: NavigationToolbar(
        leading: IconTheme.merge(
          data: overallIconTheme,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.additionalLending != null) widget.additionalLending!,
              if (!isDisplayModeOpen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: PaneButton(
                    isClose: navigationViewScope.isPaneOpen,
                  ),
                ),
            ],
          ),
        ),
        middle: title,
        trailing: actions,
        centerMiddle: widget._getEffectiveCenterTitle(),
        middleSpacing: widget.titleSpacing ?? NavigationToolbar.kMiddleSpacing,
      ),
    );

    // If the toolbar is allocated less than toolbarHeight make it
    // appear to scroll upwards within its shrinking container.
    final Widget appBar = ClipRect(
      clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
      child: CustomSingleChildLayout(
        delegate: _ToolbarContainerLayout(appBarHeight),
        child: IconTheme.merge(
          data: overallIconTheme,
          child: DefaultTextStyle(
            style: defaults.toolbarTextStyle.copyWith(color: foregroundColor),
            child: toolbar,
          ),
        ),
      ),
    );

    final SystemUiOverlayStyle overlayStyle =
        widget.systemOverlayStyle ??
        _systemOverlayStyleForBrightness(
          effectiveBrightness,
          const Color(0x00000000),
        );

    return Semantics(
      container: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: PhysicalModel(
          color: backgroundColor,
          elevation: widget.elevation,
          shadowColor: widget.shadowColor,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Semantics(
              explicitChildNodes: true,
              child: appBar,
            ),
          ),
        ),
      ),
    );
  }

  SystemUiOverlayStyle _systemOverlayStyleForBrightness(
    Brightness brightness, [
    Color? backgroundColor,
  ]) {
    final SystemUiOverlayStyle style = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    // For backward compatibility, create an overlay style without system navigation bar settings.
    return SystemUiOverlayStyle(
      statusBarColor: backgroundColor,
      statusBarBrightness: style.statusBarBrightness,
      statusBarIconBrightness: style.statusBarIconBrightness,
      systemStatusBarContrastEnforced: style.systemStatusBarContrastEnforced,
    );
  }
}

class NavigationAppBarSettings extends InheritedWidget {
  const NavigationAppBarSettings({
    super.key,
    required this.currentExtent,
    required super.child,
  });

  final double currentExtent;

  static NavigationAppBarSettings? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NavigationAppBarSettings>();
  }

  @override
  bool updateShouldNotify(NavigationAppBarSettings oldWidget) =>
      currentExtent != oldWidget.currentExtent;
}

class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
  const _ToolbarContainerLayout(this.toolbarHeight);

  final double toolbarHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(height: toolbarHeight);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, toolbarHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_ToolbarContainerLayout oldDelegate) =>
      toolbarHeight != oldDelegate.toolbarHeight;
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.appBarHeight)
    : super.fromHeight(appBarHeight ?? _kDefaultAppBarHeight);

  final double? appBarHeight;
}

@immutable
class PaneButtonStyle {
  const PaneButtonStyle({
    this.size = 36.0,
    this.padding = const EdgeInsets.all(6.0),
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
    ),
    this.backgroundColor,
    this.hoverColor,
    this.pressedColor,
    this.iconColor,
    this.iconSize,
  });

  final double size;
  final EdgeInsetsGeometry padding;
  final ShapeBorder shape;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? pressedColor;
  final Color? iconColor;
  final double? iconSize;
}

class PaneButton extends _ActionButton {
  const PaneButton({
    super.key,
    super.style,
    super.icon,
    super.iconClose,
    required super.isClose,
    super.onPressed,
    this.openSemanticLabel = 'Open navigation menu',
    this.closeSemanticLabel = 'Close navigation menu',
  });

  final String openSemanticLabel;
  final String closeSemanticLabel;

  @override
  void _onPressedCallback(BuildContext context) => isClose
      ? NavigationView.of(context).closePane()
      : NavigationView.of(context).openPane();

  @override
  String _getTooltip(BuildContext context) {
    return isClose ? closeSemanticLabel : openSemanticLabel;
  }
}

abstract class _ActionButton extends StatefulWidget {
  const _ActionButton({
    super.key,
    this.icon,
    this.iconClose,
    required this.isClose,
    this.onPressed,
    this.style,
  });

  /// Custom icon widget when the panel is closed.
  /// If null, draw the menu vector icon via Canvas.
  final Widget? icon;

  /// Custom icon widget when the panel is open.
  /// If null, draw the open-menu vector icon via Canvas.
  final Widget? iconClose;

  final bool isClose;
  final VoidCallback? onPressed;
  final PaneButtonStyle? style;

  String _getTooltip(BuildContext context);

  /// This is the default function that is called when [onPressed] is set
  /// to null.
  void _onPressedCallback(BuildContext context);

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  void _triggerTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      widget._onPressedCallback(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final NavigationThemeData? navTheme = NavigationTheme.of(context);
    final _NavigationDefaults navDefaults = _NavigationDefaults(context);
    const PaneButtonStyle defaultStyle = PaneButtonStyle();
    final PaneButtonStyle effectiveStyle = widget.style ?? defaultStyle;

    // Prioriza a cor herdada do IconTheme da AppBar (que já reagiu ao tema/background)
    final Color iconColor =
        effectiveStyle.iconColor ??
        iconTheme.color ??
        navTheme?.itemIconColor ??
        navDefaults.itemIconColor ??
        const Color(0xFF1C1B1F);

    final double iconSize = effectiveStyle.iconSize ?? iconTheme.size ?? 20.0;

    Color bgColor = effectiveStyle.backgroundColor ?? const Color(0x00000000);
    if (_isPressed) {
      bgColor =
          effectiveStyle.pressedColor ??
          navTheme?.itemPressedBackgroundColor ??
          iconColor.withAlpha(30);
    } else if (_isHovered || _isFocused) {
      bgColor =
          effectiveStyle.hoverColor ??
          navTheme?.itemHoverBackgroundColor ??
          iconColor.withAlpha(20);
    }

    final Widget activeChild = widget.isClose
        ? (widget.iconClose ??
              _RawMenuIcon(size: iconSize, color: iconColor, isOpen: true))
        : (widget.icon ??
              _RawMenuIcon(size: iconSize, color: iconColor, isOpen: false));

    return Semantics(
      button: true,
      label: widget._getTooltip(context),
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => _triggerTap(),
          ),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
            onInvoke: (_) => _triggerTap(),
          ),
        },
        onShowHoverHighlight: (v) => setState(() => _isHovered = v),
        onShowFocusHighlight: (v) => setState(() => _isFocused = v),
        mouseCursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _triggerTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: SizedBox.square(
            dimension: effectiveStyle.size,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: bgColor,
                shape: effectiveStyle.shape,
              ),
              child: Padding(
                padding: effectiveStyle.padding,
                child: Center(
                  child: IconTheme.merge(
                    data: IconThemeData(color: iconColor, size: iconSize),
                    child: activeChild,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Desenha os ícones de Menu (Hambúrguer) e Menu Open vetorialmente no Canvas,
/// sem depender da fonte MaterialIcons.
class _RawMenuIcon extends StatelessWidget {
  const _RawMenuIcon({
    required this.size,
    required this.color,
    required this.isOpen,
  });

  final double size;
  final Color color;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MenuIconPainter(
        color: color,
        isOpen: isOpen,
        isRTL: Directionality.of(context) == TextDirection.rtl,
      ),
    );
  }
}

class _MenuIconPainter extends CustomPainter {
  const _MenuIconPainter({
    required this.color,
    required this.isOpen,
    required this.isRTL,
  });

  final Color color;
  final bool isOpen;
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

    if (!isOpen) {
      canvas.drawLine(
        Offset(w * 0.16, h * 0.26),
        Offset(w * 0.84, h * 0.26),
        paint,
      );
      canvas.drawLine(
        Offset(w * 0.16, h * 0.50),
        Offset(w * 0.84, h * 0.50),
        paint,
      );
      canvas.drawLine(
        Offset(w * 0.16, h * 0.74),
        Offset(w * 0.84, h * 0.74),
        paint,
      );
    } else {
      if (isRTL) {
        canvas.drawLine(
          Offset(w * 0.16, h * 0.26),
          Offset(w * 0.84, h * 0.26),
          paint,
        );
        canvas.drawLine(
          Offset(w * 0.36, h * 0.50),
          Offset(w * 0.84, h * 0.50),
          paint,
        );
        canvas.drawLine(
          Offset(w * 0.16, h * 0.74),
          Offset(w * 0.84, h * 0.74),
          paint,
        );

        final Path chevron = Path()
          ..moveTo(w * 0.16, h * 0.36)
          ..lineTo(w * 0.30, h * 0.50)
          ..lineTo(w * 0.16, h * 0.64);
        canvas.drawPath(chevron, paint);
      } else {
        canvas.drawLine(
          Offset(w * 0.16, h * 0.26),
          Offset(w * 0.84, h * 0.26),
          paint,
        );
        canvas.drawLine(
          Offset(w * 0.16, h * 0.50),
          Offset(w * 0.64, h * 0.50),
          paint,
        );
        canvas.drawLine(
          Offset(w * 0.16, h * 0.74),
          Offset(w * 0.84, h * 0.74),
          paint,
        );

        final Path chevron = Path()
          ..moveTo(w * 0.84, h * 0.36)
          ..lineTo(w * 0.70, h * 0.50)
          ..lineTo(w * 0.84, h * 0.64);
        canvas.drawPath(chevron, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MenuIconPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.isOpen != isOpen ||
      oldDelegate.isRTL != isRTL;
}

/// Substituto puro de [_AppBarDefaults] que reage dinamicamente ao brilho do fundo
/// e ao [DefaultTextStyle] do app, sem depender de [AppBarTheme] ou [Theme].
class _AppBarDefaults {
  _AppBarDefaults(this.context, {Brightness? brightness})
    : _isDark = brightness != null
          ? brightness == Brightness.dark
          : _detectIsDark(context);

  final BuildContext context;
  final bool _isDark;

  static bool _detectIsDark(BuildContext context) {
    final Color? ambientTextColor = DefaultTextStyle.of(context).style.color;
    if (ambientTextColor != null &&
        ambientTextColor != const Color(0xFF000000)) {
      return ambientTextColor.computeLuminance() > 0.5;
    }
    return MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
  }

  static Color resolveDefaultBackground(BuildContext context) {
    return _detectIsDark(context)
        ? const Color(0xFF1E1E24)
        : const Color(0xFFF8F9FA);
  }

  Color get backgroundColor =>
      _isDark ? const Color(0xFF1E1E24) : const Color(0xFFF8F9FA);

  Color get foregroundColor =>
      _isDark ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);

  Color get onSurfaceVariant =>
      _isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);

  IconThemeData get iconTheme => IconThemeData(
    color: foregroundColor,
    size: 24.0,
  );

  IconThemeData get actionsIconTheme => IconThemeData(
    color: foregroundColor,
    size: 24.0,
  );

  TextStyle get toolbarTextStyle {
    final TextStyle base = DefaultTextStyle.of(context).style;
    return base.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: foregroundColor,
      decoration: TextDecoration.none,
    );
  }

  TextStyle get titleTextStyle {
    final TextStyle base = DefaultTextStyle.of(context).style;
    return base.copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: foregroundColor,
      decoration: TextDecoration.none,
    );
  }
}
