part of 'navigation_view.dart';

/// Defines default property values for descendant [Pane] widgets.
///
/// Descendant widgets obtain the current [NavigationThemeData] object
/// using `PaneTheme.of(context)`. Instances of [NavigationThemeData] can be
/// customized with [NavigationThemeData.copyWith].
///
/// Typically a [NavigationThemeData] is specified as part of the
/// overall [Theme] with [ThemeData.paneTheme].
///
/// All [NavigationThemeData] properties are `null` by default.
///
/// See also:
///
///  * [NavigationTheme], an [InheritedWidget] that propagates the theme down its
///    subtree.
///  * [NavigationThemeData], which describes the overall theme information for the
///    application and can customize a Pane using [NavigationThemeData.paneTheme].
@immutable
class NavigationThemeData with Diagnosticable {
  /// Creates a theme that can be used for [NavigationThemeData.paneTheme] and
  /// [NavigationTheme].
  const NavigationThemeData({
    this.backgroundColor,
    this.scrimColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.dividerColor,
    this.shape,
    this.minimalShape,
    this.indicatorColor,
    this.indicatorShape,
    this.indicatorSize,
    this.labelTextStyle,
    this.iconTheme,
    this.contentPadding,
    this.compactWidth,
    this.openWidth,
    this.itemSize,
    this.itemBackgroundColor,
    this.itemSelectedBackgroundColor,
    this.itemHoverBackgroundColor,
    this.itemPressedBackgroundColor,
    this.itemShape,
    this.itemContentPadding,
    this.itemMargin,
    this.itemSpacing,
    this.itemIconSize,
    this.itemIconColor,
    this.itemSelectedIconColor,
    this.itemHoverIconColor,
    this.itemDisabledIconColor,
    this.itemLabelStyle,
    this.itemSelectedLabelStyle,
    this.itemHoverLabelStyle,
    this.itemDisabledLabelStyle,
    this.itemChevronSize,
    this.itemChevronColor,
    this.itemChevronHoverColor,
    this.itemSelectedChevronColor,
    this.itemChildrenIndent,
    this.itemChildrenSpacing,
    this.itemAnimationDuration,
    this.itemAnimationCurve,
    this.itemElevation,
    this.itemShadowColor,
  });

  /// Overrides the default value of [NavigationPane.backgroundColor].
  final Color? backgroundColor;

  /// Overrides the default value of [PaneController.scrimColor].
  final Color? scrimColor;

  /// Overrides the default value of [NavigationPane.elevation].
  final double? elevation;

  /// Overrides the default value of [NavigationPane.shadowColor].
  final Color? shadowColor;

  /// Overrides the default value of [NavigationPane.surfaceTintColor].
  final Color? surfaceTintColor;

  /// Overrides the default value of [NavigationPane.dividerColor].
  final Color? dividerColor;

  /// Overrides the default value of [NavigationPane.shape].
  final ShapeBorder? shape;

  /// Overrides the default value of [NavigationPane.minimalShape].
  final ShapeBorder? minimalShape;

  /// The color of the [NavigationPane]'s selection indicator.
  final Color? indicatorColor;

  /// The shape of the [NavigationPane]'s selection indicator.
  final ShapeBorder? indicatorShape;

  /// The size of the [NavigationPane]'s selection indicator.
  final Size? indicatorSize;

  /// The text style for [PaneItemDestination] labels in different states.
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// The icon theme for [NavigationDestination] icons in different states.
  final WidgetStateProperty<IconThemeData?>? iconTheme;

  /// The padding for the [NavigationPane]'s content in different states.
  final WidgetStateProperty<EdgeInsetsGeometry?>? contentPadding;

  /// Overrides the default value of [NavigationPane.compactWidth].
  final double? compactWidth;

  /// Overrides the default value of [NavigationPane.openWidth].
  final double? openWidth;

  /// Overrides the default size for a [PaneItemDestination].
  final Size? itemSize;

  /// The background color for a [PaneItemDestination] in different states.
  final WidgetStateProperty<Color?>? itemBackgroundColor;

  /// The background color for a [PaneItemDestination] when it is selected.
  final Color? itemSelectedBackgroundColor;

  /// The background color for a [PaneItemDestination] when the pointer is hovering over it.
  final Color? itemHoverBackgroundColor;

  /// The background color for a [PaneItemDestination] when it is pressed.
  final Color? itemPressedBackgroundColor;

  /// The shape of a [PaneItemDestination]'s container in different states.
  final WidgetStateProperty<ShapeBorder?>? itemShape;

  /// O padding interno para o conteúdo dentro de cada [PaneItemDestination].
  /// Isso controla o espaçamento entre os elementos (ícone, texto, etc) dentro do item.
  final EdgeInsetsGeometry? itemContentPadding;

  /// The margin around each [PaneItemDestination].
  final EdgeInsetsGeometry? itemMargin;

  /// The spacing between a [PaneItemDestination]'s icon and label.
  final double? itemSpacing;

  /// The size of a [PaneItemDestination]'s icon in different states.
  final WidgetStateProperty<double?>? itemIconSize;

  /// The icon color for a [PaneItemDestination] when it is not selected.
  final Color? itemIconColor;

  /// The icon color for a [PaneItemDestination] when it is selected.
  final Color? itemSelectedIconColor;

  /// The icon color for a [PaneItemDestination] when the pointer is hovering over it.
  final Color? itemHoverIconColor;

  /// The icon color for a [PaneItemDestination] when it is disabled.
  final Color? itemDisabledIconColor;

  /// The label text style for a [PaneItemDestination] when it is not selected.
  final TextStyle? itemLabelStyle;

  /// The label text style for a [PaneItemDestination] when it is selected.
  final TextStyle? itemSelectedLabelStyle;

  /// The label text style for a [PaneItemDestination] when the pointer is hovering over it.
  final TextStyle? itemHoverLabelStyle;

  /// The label text style for a [PaneItemDestination] when it is disabled.
  final TextStyle? itemDisabledLabelStyle;

  /// The size of the chevron icon for expandable items.
  final double? itemChevronSize;

  /// The color of the chevron icon for expandable items.
  final Color? itemChevronColor;

  /// The color of the chevron icon for expandable items when the pointer is hovering over them.
  final Color? itemChevronHoverColor;

  /// The color of the chevron icon for expandable items when they are selected.
  final Color? itemSelectedChevronColor;

  /// The indentation for the child items of an expandable item.
  final double? itemChildrenIndent;

  /// The spacing between the child items of an expandable item.
  final double? itemChildrenSpacing;

  /// The duration of animations for item state changes (selection, expansion, etc.).
  final Duration? itemAnimationDuration;

  /// The animation curve for item state changes.
  final Curve? itemAnimationCurve;

  /// The elevation for a [PaneItemDestination] in different states.
  final WidgetStateProperty<double?>? itemElevation;

  /// The shadow color for an elevated [PaneItemDestination] in different states.
  final WidgetStateProperty<Color?>? itemShadowColor;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  NavigationThemeData copyWith({
    Color? backgroundColor,
    Color? scrimColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? dividerColor,
    ShapeBorder? shape,
    ShapeBorder? minimalShape,
    Color? indicatorColor,
    ShapeBorder? indicatorShape,
    Size? indicatorSize,
    WidgetStateProperty<TextStyle?>? labelTextStyle,
    WidgetStateProperty<IconThemeData?>? iconTheme,
    WidgetStateProperty<EdgeInsetsGeometry?>? contentPadding,
    double? compactWidth,
    double? openWidth,
    Size? itemSize,
    WidgetStateProperty<Color?>? itemBackgroundColor,
    Color? itemSelectedBackgroundColor,
    Color? itemHoverBackgroundColor,
    Color? itemPressedBackgroundColor,
    WidgetStateProperty<ShapeBorder?>? itemShape,
    EdgeInsetsGeometry? itemMargin,
    double? itemSpacing,
    WidgetStateProperty<double?>? itemIconSize,
    Color? itemIconColor,
    Color? itemSelectedIconColor,
    Color? itemHoverIconColor,
    Color? itemDisabledIconColor,
    TextStyle? itemLabelStyle,
    TextStyle? itemSelectedLabelStyle,
    TextStyle? itemHoverLabelStyle,
    TextStyle? itemDisabledLabelStyle,
    double? itemChevronSize,
    Color? itemChevronColor,
    Color? itemChevronHoverColor,
    Color? itemSelectedChevronColor,
    double? itemChildrenIndent,
    double? itemChildrenSpacing,
    Duration? itemAnimationDuration,
    Curve? itemAnimationCurve,
    WidgetStateProperty<double?>? itemElevation,
    WidgetStateProperty<Color?>? itemShadowColor,
    Gradient? itemSelectedGradient,
    Gradient? itemHoverGradient,
  }) {
    return NavigationThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      scrimColor: scrimColor ?? this.scrimColor,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      dividerColor: dividerColor ?? this.dividerColor,
      shape: shape ?? this.shape,
      minimalShape: minimalShape ?? this.minimalShape,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorShape: indicatorShape ?? this.indicatorShape,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      iconTheme: iconTheme ?? this.iconTheme,
      contentPadding: contentPadding ?? this.contentPadding,
      compactWidth: compactWidth ?? this.compactWidth,
      openWidth: openWidth ?? this.openWidth,
      itemSize: itemSize ?? this.itemSize,
      itemBackgroundColor: itemBackgroundColor ?? this.itemBackgroundColor,
      itemSelectedBackgroundColor:
          itemSelectedBackgroundColor ?? this.itemSelectedBackgroundColor,
      itemHoverBackgroundColor:
          itemHoverBackgroundColor ?? this.itemHoverBackgroundColor,
      itemPressedBackgroundColor:
          itemPressedBackgroundColor ?? this.itemPressedBackgroundColor,
      itemShape: itemShape ?? this.itemShape,
      itemMargin: itemMargin ?? this.itemMargin,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      itemIconSize: itemIconSize ?? this.itemIconSize,
      itemIconColor: itemIconColor ?? this.itemIconColor,
      itemSelectedIconColor:
          itemSelectedIconColor ?? this.itemSelectedIconColor,
      itemHoverIconColor: itemHoverIconColor ?? this.itemHoverIconColor,
      itemDisabledIconColor:
          itemDisabledIconColor ?? this.itemDisabledIconColor,
      itemLabelStyle: itemLabelStyle ?? this.itemLabelStyle,
      itemSelectedLabelStyle:
          itemSelectedLabelStyle ?? this.itemSelectedLabelStyle,
      itemHoverLabelStyle: itemHoverLabelStyle ?? this.itemHoverLabelStyle,
      itemDisabledLabelStyle:
          itemDisabledLabelStyle ?? this.itemDisabledLabelStyle,
      itemChevronSize: itemChevronSize ?? this.itemChevronSize,
      itemChevronColor: itemChevronColor ?? this.itemChevronColor,
      itemChevronHoverColor:
          itemChevronHoverColor ?? this.itemChevronHoverColor,
      itemSelectedChevronColor:
          itemSelectedChevronColor ?? this.itemSelectedChevronColor,
      itemChildrenIndent: itemChildrenIndent ?? this.itemChildrenIndent,
      itemChildrenSpacing: itemChildrenSpacing ?? this.itemChildrenSpacing,
      itemAnimationDuration:
          itemAnimationDuration ?? this.itemAnimationDuration,
      itemAnimationCurve: itemAnimationCurve ?? this.itemAnimationCurve,
      itemElevation: itemElevation ?? this.itemElevation,
      itemShadowColor: itemShadowColor ?? this.itemShadowColor,
    );
  }

  /// Linearly interpolate between two pane themes.
  ///
  /// If both arguments are null then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static NavigationThemeData? lerp(
    NavigationThemeData? a,
    NavigationThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return NavigationThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      scrimColor: Color.lerp(a?.scrimColor, b?.scrimColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      surfaceTintColor: Color.lerp(a?.surfaceTintColor, b?.surfaceTintColor, t),
      dividerColor: Color.lerp(a?.dividerColor, b?.dividerColor, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
      minimalShape: ShapeBorder.lerp(a?.minimalShape, b?.minimalShape, t),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      indicatorShape: ShapeBorder.lerp(a?.indicatorShape, b?.indicatorShape, t),
      indicatorSize: Size.lerp(a?.indicatorSize, b?.indicatorSize, t),
      labelTextStyle: WidgetStateProperty.lerp<TextStyle?>(
        a?.labelTextStyle,
        b?.labelTextStyle,
        t,
        TextStyle.lerp,
      ),
      iconTheme: WidgetStateProperty.lerp<IconThemeData?>(
        a?.iconTheme,
        b?.iconTheme,
        t,
        IconThemeData.lerp,
      ),
      contentPadding: WidgetStateProperty.lerp<EdgeInsetsGeometry?>(
        a?.contentPadding,
        b?.contentPadding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      compactWidth: lerpDouble(a?.compactWidth, b?.compactWidth, t),
      openWidth: lerpDouble(a?.openWidth, b?.openWidth, t),
      itemSize: Size.lerp(a?.itemSize, b?.itemSize, t),
      itemBackgroundColor: WidgetStateProperty.lerp<Color?>(
        a?.itemBackgroundColor,
        b?.itemBackgroundColor,
        t,
        Color.lerp,
      ),
      itemSelectedBackgroundColor: Color.lerp(
        a?.itemSelectedBackgroundColor,
        b?.itemSelectedBackgroundColor,
        t,
      ),
      itemHoverBackgroundColor: Color.lerp(
        a?.itemHoverBackgroundColor,
        b?.itemHoverBackgroundColor,
        t,
      ),
      itemPressedBackgroundColor: Color.lerp(
        a?.itemPressedBackgroundColor,
        b?.itemPressedBackgroundColor,
        t,
      ),
      itemShape: WidgetStateProperty.lerp<ShapeBorder?>(
        a?.itemShape,
        b?.itemShape,
        t,
        ShapeBorder.lerp,
      ),
      itemMargin: EdgeInsetsGeometry.lerp(
        a?.itemMargin,
        b?.itemMargin,
        t,
      ),
      itemSpacing: lerpDouble(a?.itemSpacing, b?.itemSpacing, t),
      itemIconSize: WidgetStateProperty.lerp<double?>(
        a?.itemIconSize,
        b?.itemIconSize,
        t,
        lerpDouble,
      ),
      itemIconColor: Color.lerp(a?.itemIconColor, b?.itemIconColor, t),
      itemSelectedIconColor:
          Color.lerp(a?.itemSelectedIconColor, b?.itemSelectedIconColor, t),
      itemHoverIconColor:
          Color.lerp(a?.itemHoverIconColor, b?.itemHoverIconColor, t),
      itemDisabledIconColor:
          Color.lerp(a?.itemDisabledIconColor, b?.itemDisabledIconColor, t),
      itemLabelStyle: TextStyle.lerp(a?.itemLabelStyle, b?.itemLabelStyle, t),
      itemSelectedLabelStyle: TextStyle.lerp(
        a?.itemSelectedLabelStyle,
        b?.itemSelectedLabelStyle,
        t,
      ),
      itemHoverLabelStyle:
          TextStyle.lerp(a?.itemHoverLabelStyle, b?.itemHoverLabelStyle, t),
      itemDisabledLabelStyle: TextStyle.lerp(
        a?.itemDisabledLabelStyle,
        b?.itemDisabledLabelStyle,
        t,
      ),
      itemChevronSize: lerpDouble(a?.itemChevronSize, b?.itemChevronSize, t),
      itemChevronColor: Color.lerp(a?.itemChevronColor, b?.itemChevronColor, t),
      itemChevronHoverColor:
          Color.lerp(a?.itemChevronHoverColor, b?.itemChevronHoverColor, t),
      itemSelectedChevronColor: Color.lerp(
        a?.itemSelectedChevronColor,
        b?.itemSelectedChevronColor,
        t,
      ),
      itemChildrenIndent:
          lerpDouble(a?.itemChildrenIndent, b?.itemChildrenIndent, t),
      itemChildrenSpacing:
          lerpDouble(a?.itemChildrenSpacing, b?.itemChildrenSpacing, t),
      itemAnimationDuration:
          t < 0.5 ? a?.itemAnimationDuration : b?.itemAnimationDuration,
      itemAnimationCurve:
          t < 0.5 ? a?.itemAnimationCurve : b?.itemAnimationCurve,
      itemElevation: WidgetStateProperty.lerp<double?>(
        a?.itemElevation,
        b?.itemElevation,
        t,
        lerpDouble,
      ),
      itemShadowColor: WidgetStateProperty.lerp<Color?>(
        a?.itemShadowColor,
        b?.itemShadowColor,
        t,
        Color.lerp,
      ),
    );
  }

  @override
  int get hashCode => Object.hashAll([
        backgroundColor,
        scrimColor,
        elevation,
        shadowColor,
        surfaceTintColor,
        dividerColor,
        shape,
        minimalShape,
        indicatorColor,
        indicatorShape,
        indicatorSize,
        labelTextStyle,
        iconTheme,
        contentPadding,
        compactWidth,
        openWidth,
        itemSize,
        itemBackgroundColor,
        itemSelectedBackgroundColor,
        itemHoverBackgroundColor,
        itemPressedBackgroundColor,
        itemShape,
        itemMargin,
        itemSpacing,
        itemIconSize,
        itemIconColor,
        itemSelectedIconColor,
        itemHoverIconColor,
        itemDisabledIconColor,
        itemLabelStyle,
        itemSelectedLabelStyle,
        itemHoverLabelStyle,
        itemDisabledLabelStyle,
        itemChevronSize,
        itemChevronColor,
        itemChevronHoverColor,
        itemSelectedChevronColor,
        itemChildrenIndent,
        itemChildrenSpacing,
        itemAnimationDuration,
        itemAnimationCurve,
        itemElevation,
        itemShadowColor,
      ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NavigationThemeData &&
        other.backgroundColor == backgroundColor &&
        other.scrimColor == scrimColor &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.dividerColor == dividerColor &&
        other.shape == shape &&
        other.minimalShape == minimalShape &&
        other.indicatorColor == indicatorColor &&
        other.indicatorShape == indicatorShape &&
        other.indicatorSize == indicatorSize &&
        other.labelTextStyle == labelTextStyle &&
        other.iconTheme == iconTheme &&
        other.contentPadding == contentPadding &&
        other.compactWidth == compactWidth &&
        other.openWidth == openWidth &&
        other.itemSize == itemSize &&
        other.itemBackgroundColor == itemBackgroundColor &&
        other.itemSelectedBackgroundColor == itemSelectedBackgroundColor &&
        other.itemHoverBackgroundColor == itemHoverBackgroundColor &&
        other.itemPressedBackgroundColor == itemPressedBackgroundColor &&
        other.itemShape == itemShape &&
        other.itemMargin == itemMargin &&
        other.itemSpacing == itemSpacing &&
        other.itemIconSize == itemIconSize &&
        other.itemIconColor == itemIconColor &&
        other.itemSelectedIconColor == itemSelectedIconColor &&
        other.itemHoverIconColor == itemHoverIconColor &&
        other.itemDisabledIconColor == itemDisabledIconColor &&
        other.itemLabelStyle == itemLabelStyle &&
        other.itemSelectedLabelStyle == itemSelectedLabelStyle &&
        other.itemHoverLabelStyle == itemHoverLabelStyle &&
        other.itemDisabledLabelStyle == itemDisabledLabelStyle &&
        other.itemChevronSize == itemChevronSize &&
        other.itemChevronColor == itemChevronColor &&
        other.itemChevronHoverColor == itemChevronHoverColor &&
        other.itemSelectedChevronColor == itemSelectedChevronColor &&
        other.itemChildrenIndent == itemChildrenIndent &&
        other.itemChildrenSpacing == itemChildrenSpacing &&
        other.itemAnimationDuration == itemAnimationDuration &&
        other.itemAnimationCurve == itemAnimationCurve &&
        other.itemElevation == itemElevation &&
        other.itemShadowColor == itemShadowColor;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ColorProperty('backgroundColor', backgroundColor, defaultValue: null),
    );
    properties.add(ColorProperty('scrimColor', scrimColor, defaultValue: null));
    properties.add(DoubleProperty('elevation', elevation, defaultValue: null));
    properties
        .add(ColorProperty('shadowColor', shadowColor, defaultValue: null));
    properties.add(
      ColorProperty(
        'surfaceTintColor',
        surfaceTintColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<ShapeBorder>('shape', shape, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<ShapeBorder>(
        'minimalShape',
        minimalShape,
        defaultValue: null,
      ),
    );
    properties
        .add(ColorProperty('shadowColor', shadowColor, defaultValue: null));
    properties.add(
      ColorProperty(
        'surfaceTintColor',
        surfaceTintColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty('indicatorColor', indicatorColor, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<ShapeBorder>(
        'indicatorShape',
        indicatorShape,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Size>(
        'indicatorSize',
        indicatorSize,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<TextStyle?>>(
        'labelTextStyle',
        labelTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<IconThemeData?>>(
        'iconTheme',
        iconTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DoubleProperty('compactWidth', compactWidth, defaultValue: null),
    );
    properties.add(
      DoubleProperty('openWidth', openWidth, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        'itemBackgroundColor',
        itemBackgroundColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty(
        'itemSelectedBackgroundColor',
        itemSelectedBackgroundColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty(
        'itemHoverBackgroundColor',
        itemHoverBackgroundColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty(
        'itemPressedBackgroundColor',
        itemPressedBackgroundColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<ShapeBorder?>>(
        'itemShape',
        itemShape,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        'itemMargin',
        itemMargin,
        defaultValue: null,
      ),
    );
    properties.add(
      DoubleProperty('itemSpacing', itemSpacing, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<double?>>(
        'itemIconSize',
        itemIconSize,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty('itemIconColor', itemIconColor, defaultValue: null),
    );
    properties.add(
      ColorProperty(
        'itemSelectedIconColor',
        itemSelectedIconColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty(
        'itemHoverIconColor',
        itemHoverIconColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty(
        'itemDisabledIconColor',
        itemDisabledIconColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle>(
        'itemLabelStyle',
        itemLabelStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle>(
        'itemSelectedLabelStyle',
        itemSelectedLabelStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle>(
        'itemHoverLabelStyle',
        itemHoverLabelStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle>(
        'itemDisabledLabelStyle',
        itemDisabledLabelStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DoubleProperty('itemChevronSize', itemChevronSize, defaultValue: null),
    );
    properties.add(
      ColorProperty('itemChevronColor', itemChevronColor, defaultValue: null),
    );
    properties.add(
      ColorProperty(
        'itemChevronHoverColor',
        itemChevronHoverColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty(
        'itemSelectedChevronColor',
        itemSelectedChevronColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DoubleProperty(
        'itemChildrenIndent',
        itemChildrenIndent,
        defaultValue: null,
      ),
    );
    properties.add(
      DoubleProperty(
        'itemChildrenSpacing',
        itemChildrenSpacing,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Duration>(
        'itemAnimationDuration',
        itemAnimationDuration,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Curve>(
        'itemAnimationCurve',
        itemAnimationCurve,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<double?>>(
        'itemElevation',
        itemElevation,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        'itemShadowColor',
        itemShadowColor,
        defaultValue: null,
      ),
    );
  }
}

/// An inherited widget that defines visual properties for [Pane]s in this
/// widget's subtree.
///
/// Values specified here are used for [Pane] properties that are not
/// given an explicit non-null value.
///
/// Using this would allow you to override the [ThemeData.paneTheme].
class NavigationTheme extends InheritedTheme {
  /// Creates a theme that defines the [NavigationThemeData] properties for a
  /// [Pane].
  const NavigationTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Specifies the background color, scrim color, elevation, and shape for
  /// descendant [NavigationPane] widgets.
  final NavigationThemeData data;

  static NavigationThemeData? of(BuildContext context) {
    final NavigationTheme? paneTheme =
        context.dependOnInheritedWidgetOfExactType<NavigationTheme>();
    return paneTheme?.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NavigationTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(NavigationTheme oldWidget) => data != oldWidget.data;
}

class _NavigationDefaults extends NavigationThemeData {
  _NavigationDefaults(this.context)
      : super(
          elevation: 0.0,
        );

  final BuildContext context;
  late final TextDirection direction = Directionality.of(context);
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

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
  Size? get indicatorSize => const Size.fromHeight(_kIndicatorHeight);

  @override
  Size? get itemSize => const Size.fromHeight(_kItemHeight);

  @override
  double? get itemSpacing => 8.0;

  @override
  EdgeInsets? get itemMargin => const EdgeInsets.symmetric(horizontal: 12.0);

  @override
  EdgeInsets? get itemContentPadding =>
      const EdgeInsets.symmetric(horizontal: 8.0);

  @override
  Duration? get itemAnimationDuration => const Duration(milliseconds: 200);

  @override
  Curve? get itemAnimationCurve => Curves.easeInOut;

  @override
  WidgetStateProperty<Color?>? get itemBackgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _colors.secondaryContainer.withAlpha(127);
        }
        return Colors.transparent;
      });

  @override
  Color? get itemHoverBackgroundColor => _colors.onSurface.withAlpha(2);

  @override
  Color? get itemPressedBackgroundColor => _colors.onSurface.withAlpha(30);

  @override
  WidgetStateProperty<ShapeBorder?>? get itemShape =>
      WidgetStateProperty.all(const StadiumBorder());

  @override
  Color? get itemChevronColor => _colors.onSurfaceVariant;

  @override
  Color? get itemChevronHoverColor => _colors.onSurface;

  @override
  Color? get itemSelectedChevronColor => _colors.onSecondaryContainer;

  @override
  double? get itemChildrenIndent => 18.0;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        return IconThemeData(
          size: 24.0,
          color: states.contains(WidgetState.disabled)
              ? _colors.onSurfaceVariant.withAlpha(96)
              : states.contains(WidgetState.selected)
                  ? _colors.onSecondaryContainer
                  : _colors.onSurfaceVariant,
        );
      });

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        final TextStyle style = _textTheme.labelLarge!;
        return style.apply(
          color: states.contains(WidgetState.disabled)
              ? _colors.onSurfaceVariant.withAlpha(96)
              : states.contains(WidgetState.selected)
                  ? _colors.onSecondaryContainer
                  : _colors.onSurfaceVariant,
          overflow: TextOverflow.ellipsis,
        );
      });
}
