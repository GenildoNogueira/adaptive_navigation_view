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
    this.titleSpacing = 16,
    this.titleTextStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.actions,
    this.appBarHeight,
    this.leadingWidth,
    this.backgroundColor,
    this.clipBehavior,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
  }) : preferredSize = _PreferredAppBarSize(appBarHeight);

  /// Used by [NavigationView] to compute its [NavigationAppBar]'s overall height. The returned value is
  /// the same `preferredSize.height` unless [NavigationAppBar.appBarHeight] was null and
  /// `AppBarTheme.of(context).toolbarHeight` is non-null. In that case the
  /// return value is the sum of the theme's toolbar height and the height of
  /// the app bar's [AppBar.bottom] widget.
  static double preferredHeightFor(BuildContext context, Size preferredSize) {
    if (preferredSize is _PreferredAppBarSize &&
        preferredSize.appBarHeight == null) {
      return (AppBarTheme.of(context).toolbarHeight ?? _kDefaultAppBarHeight);
    }
    return preferredSize.height;
  }

  /// {@template flutter.material.appbar.preferredSize}
  /// A size whose height is the sum of [appBarHeight] and the [bottom] widget's
  /// preferred height.
  ///
  /// [Scaffold] uses this size to set its app bar's height.
  /// {@endtemplate}
  @override
  final Size preferredSize;

  final EdgeInsetsGeometry padding;

  /// Typically a [Text] widget that contains the app name.
  final Widget? title;

  /// {@template flutter.material.appbar.titleSpacing}
  /// The spacing around [title] content on the horizontal axis. This spacing is
  /// applied even if there is no [leading] content or [actions]. If you want
  /// [title] to take all the space available, set this value to 0.0.
  ///
  /// If this property is null, then [AppBarTheme.titleSpacing] of
  /// [ThemeData.appBarTheme] is used. If that is also null, then the
  /// default value is [NavigationToolbar.kMiddleSpacing].
  /// {@endtemplate}
  final double? titleSpacing;

  /// {@template flutter.material.appbar.foregroundColor}
  /// The default color for [Text] and [Icon]s within the app bar.
  ///
  /// If null, then [AppBarTheme.foregroundColor] is used. If that
  /// value is also null, then [AppBar] uses the overall theme's
  /// [ColorScheme.onPrimary] if the overall theme's brightness is
  /// [Brightness.light], and [ColorScheme.onSurface] if the overall
  /// theme's brightness is [Brightness.dark].
  ///
  /// This color is used to configure [DefaultTextStyle] that contains
  /// the toolbar's children, and the default [IconTheme] widgets that
  /// are created if [iconTheme] and [actionsIconTheme] are null.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [backgroundColor], which specifies the app bar's background color.
  ///  * [Theme.of], which returns the current overall Material theme as
  ///    a [ThemeData].
  ///  * [ThemeData.colorScheme], the thirteen colors that most Material widget
  ///    default colors are based on.
  ///  * [ColorScheme.brightness], which indicates if the overall [Theme]
  ///    is light or dark.
  final Color? foregroundColor;

  /// {@template flutter.material.appbar.iconTheme}
  /// The color, opacity, and size to use for toolbar icons.
  ///
  /// If this property is null, then a copy of [ThemeData.iconTheme]
  /// is used, with the [IconThemeData.color] set to the
  /// app bar's [foregroundColor].
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [actionsIconTheme], which defines the appearance of icons in
  ///    the [actions] list.
  final IconThemeData? iconTheme;

  /// {@template flutter.material.appbar.actionsIconTheme}
  /// The color, opacity, and size to use for the icons that appear in the app
  /// bar's [actions].
  ///
  /// This property should only be used when the [actions] should be
  /// themed differently than the icon that appears in the app bar's [leading]
  /// widget.
  ///
  /// If this property is null, then [AppBarTheme.actionsIconTheme] of
  /// [ThemeData.appBarTheme] is used. If that is also null, then the value of
  /// [iconTheme] is used.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [iconTheme], which defines the appearance of all of the toolbar icons.
  final IconThemeData? actionsIconTheme;

  /// {@template flutter.material.appbar.centerTitle}
  /// Whether the title should be centered.
  ///
  /// If this property is null, then [AppBarTheme.centerTitle] of
  /// [ThemeData.appBarTheme] is used. If that is also null, then value is
  /// adapted to the current [TargetPlatform].
  /// {@endtemplate}
  final bool? centerTitle;

  /// {@template flutter.material.appbar.titleTextStyle}
  /// The default text style for the AppBar's [title] widget.
  ///
  /// If this property is null, then [AppBarTheme.titleTextStyle] of
  /// [ThemeData.appBarTheme] is used. If that is also null, the default
  /// value is a copy of the overall theme's [TextTheme.titleLarge]
  /// [TextStyle], with color set to the app bar's [foregroundColor].
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [toolbarTextStyle], which is the default text style for the AppBar's
  ///    [title], [leading], and [actions] widgets, also known as the
  ///    AppBar's "toolbar".
  ///  * [DefaultTextStyle], which overrides the default text style for all of the
  ///    widgets in a subtree.
  final TextStyle? titleTextStyle;

  /// A list of Widgets to display in a row after the [title] widget.
  ///
  /// Typically these widgets are [IconButton]s representing common
  /// operations.
  final List<Widget>? actions;

  /// The height of the app bar. [_kDefaultAppBarHeight] is used by default
  final double? appBarHeight;

  /// {@template flutter.material.appbar.leadingWidth}
  /// Defines the width of [AppBar.leading] widget.
  ///
  /// By default, the value of [AppBar.leadingWidth] is 56.0.
  /// {@endtemplate}
  final double? leadingWidth;

  /// The background color of this app bar.
  final Color? backgroundColor;

  /// {@macro flutter.material.Material.clipBehavior}
  final Clip? clipBehavior;

  @override
  State<NavigationAppBar> createState() => _NavigationAppBarState();

  bool _getEffectiveCenterTitle(ThemeData theme) {
    bool platformCenter() {
      switch (theme.platform) {
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

    return centerTitle ?? theme.appBarTheme.centerTitle ?? platformCenter();
  }
}

class _NavigationAppBarState extends State<NavigationAppBar> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final ThemeData theme = Theme.of(context);
    final IconButtonThemeData iconButtonTheme = IconButtonTheme.of(context);
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    final AppBarTheme defaults = _AppBarDefaults(context);
    final _NavigationViewScope navigationViewScope =
        _NavigationViewScope.of(context);

    final bool isDisplayModeOpen =
        navigationViewScope.displayMode == DisplayMode.expanded;

    final TextStyle? titleTextStyle = widget.titleTextStyle ??
        appBarTheme.titleTextStyle ??
        defaults.titleTextStyle;

    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;

    final Color foregroundColor = widget.foregroundColor ??
        appBarTheme.foregroundColor ??
        defaults.foregroundColor!;

    final IconThemeData overallIconTheme = widget.iconTheme ??
        appBarTheme.iconTheme ??
        defaults.iconTheme!.copyWith(color: foregroundColor);

    final Color? actionForegroundColor =
        widget.foregroundColor ?? appBarTheme.foregroundColor;
    final IconThemeData actionsIconTheme = widget.actionsIconTheme ??
        appBarTheme.actionsIconTheme ??
        widget.iconTheme ??
        appBarTheme.iconTheme ??
        defaults.actionsIconTheme?.copyWith(color: actionForegroundColor) ??
        overallIconTheme;

    final double appBarHeight = widget.appBarHeight ??
        appBarTheme.toolbarHeight ??
        _kDefaultAppBarHeight;

    Widget? title = widget.title;
    if (title != null) {
      title = Semantics(
        namesRoute: switch (theme.platform) {
          TargetPlatform.android ||
          TargetPlatform.fuchsia ||
          TargetPlatform.linux ||
          TargetPlatform.windows =>
            true,
          TargetPlatform.iOS || TargetPlatform.macOS => null,
        },
        header: true,
        child: title,
      );

      title = DefaultTextStyle(
        style: titleTextStyle!,
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
      actions = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.actions!,
      );
    }

    // Allow the trailing actions to have their own theme if necessary.
    if (actions != null) {
      final IconButtonThemeData effectiveActionsIconButtonTheme;
      if (actionsIconTheme == defaults.actionsIconTheme) {
        effectiveActionsIconButtonTheme = iconButtonTheme;
      } else {
        final ButtonStyle actionsIconButtonStyle = IconButton.styleFrom(
          foregroundColor: actionsIconTheme.color,
          iconSize: actionsIconTheme.size,
        );

        effectiveActionsIconButtonTheme = IconButtonThemeData(
          style: iconButtonTheme.style?.copyWith(
            foregroundColor: actionsIconButtonStyle.foregroundColor,
            overlayColor: actionsIconButtonStyle.overlayColor,
            iconSize: actionsIconButtonStyle.iconSize,
          ),
        );
      }

      actions = IconButtonTheme(
        data: effectiveActionsIconButtonTheme,
        child: IconTheme.merge(
          data: actionsIconTheme,
          child: actions,
        ),
      );
    }

    final Widget toolbar = NavigationToolbar(
      leading: (!isDisplayModeOpen)
          ? Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
              ),
              child: PaneButton(
                isClose: navigationViewScope.isPaneOpen,
              ),
            )
          : null,
      middle: title,
      trailing: actions,
      centerMiddle: widget._getEffectiveCenterTitle(theme),
      middleSpacing: widget.titleSpacing ??
          appBarTheme.titleSpacing ??
          NavigationToolbar.kMiddleSpacing,
    );

    // If the toolbar is allocated less than toolbarHeight make it
    // appear to scroll upwards within its shrinking container.
    final Widget appBar = ClipRect(
      clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
      child: CustomSingleChildLayout(
        delegate: _ToolbarContainerLayout(appBarHeight),
        child: IconTheme.merge(
          data: overallIconTheme,
          child: toolbar,
        ),
      ),
    );

    final SystemUiOverlayStyle overlayStyle = appBarTheme.systemOverlayStyle ??
        defaults.systemOverlayStyle ??
        _systemOverlayStyleForBrightness(
          ThemeData.estimateBrightnessForColor(backgroundColor),
          // Make the status bar transparent for M3 so the elevation overlay
          // color is picked up by the statusbar.
          theme.useMaterial3 ? const Color(0x00000000) : null,
        );

    return Semantics(
      container: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Material(
          color: backgroundColor,
          type: MaterialType.canvas,
          shadowColor: appBarTheme.shadowColor ?? defaults.shadowColor,
          surfaceTintColor:
              appBarTheme.surfaceTintColor ?? defaults.surfaceTintColor,
          child: Padding(
            padding: EdgeInsetsDirectional.only(top: viewPadding.top),
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

// Bottom justify the toolbarHeight child which may overflow the top.
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
      : super.fromHeight((appBarHeight ?? _kDefaultAppBarHeight));

  final double? appBarHeight;
}

/// The [PaneButton] is an [IconButton] adorned with a "pane" icon. When pressed,
/// the button invokes [NavigationViewState.openPane] for the associated
/// [NavigationView.pane].
///
/// The default behavior upon pressing can be customized using [onPressed].
class PaneButton extends _ActionButton {
  /// Creates a Material Design drawer icon button.
  const PaneButton({
    super.key,
    super.style,
    super.icon = const Icon(Icons.menu),
    super.iconClose = const Icon(Icons.menu_open),
    required super.isClose,
    super.onPressed,
  });

  @override
  void _onPressedCallback(BuildContext context) => isClose
      ? NavigationView.of(context).closePane()
      : NavigationView.of(context).openPane();

  @override
  String _getTooltip(BuildContext context) {
    return isClose
        ? MaterialLocalizations.of(context).closeButtonTooltip
        : MaterialLocalizations.of(context).openAppDrawerTooltip;
  }
}

abstract class _ActionButton extends StatelessWidget {
  /// Creates a Material Design icon button.
  const _ActionButton({
    super.key,
    required this.icon,
    required this.iconClose,
    required this.isClose,
    required this.onPressed,
    this.style,
  });

  /// The icon to display inside the button.
  final Widget icon;

  /// The icon to display inside the button.
  final Widget iconClose;

  final bool isClose;

  /// The callback that is called when the button is tapped
  /// or otherwise activated.
  ///
  /// If this is set to null, the button will do a default action
  /// when it is tapped or activated.
  final VoidCallback? onPressed;

  /// Customizes this icon button's appearance.
  ///
  /// The [style] is only used for Material 3 [IconButton]s. If [ThemeData.useMaterial3]
  /// is set to true, [style] is preferred for icon button customization, and any
  /// parameters defined in [style] will override the same parameters in [IconButton].
  ///
  /// Null by default.
  final ButtonStyle? style;

  /// This returns the appropriate tooltip text for this action button.
  String _getTooltip(BuildContext context);

  /// This is the default function that is called when [onPressed] is set
  /// to null.
  void _onPressedCallback(BuildContext context);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return IconButton(
      icon: isClose ? iconClose : icon,
      style: style,
      tooltip: _getTooltip(context),
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          _onPressedCallback(context);
        }
      },
    );
  }
}

class _AppBarDefaults extends AppBarTheme {
  _AppBarDefaults(this.context)
      : super(
          elevation: 0.0,
          scrolledUnderElevation: 3.0,
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          toolbarHeight: 64.0,
        );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  Color? get foregroundColor => _colors.onSurface;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => _colors.surfaceTint;

  @override
  IconThemeData? get iconTheme => IconThemeData(
        color: _colors.onSurface,
        size: 24.0,
      );

  @override
  IconThemeData? get actionsIconTheme => IconThemeData(
        color: _colors.onSurfaceVariant,
        size: 24.0,
      );

  @override
  TextStyle? get toolbarTextStyle => _textTheme.bodyMedium;

  @override
  TextStyle? get titleTextStyle => _textTheme.titleLarge;
}
