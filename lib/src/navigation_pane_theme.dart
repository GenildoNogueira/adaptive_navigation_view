part of 'navigation_view.dart';

/// Defines default property values for descendant [Pane] widgets.
///
/// Descendant widgets obtain the current [PaneThemeData] object
/// using `PaneTheme.of(context)`. Instances of [PaneThemeData] can be
/// customized with [PaneThemeData.copyWith].
///
/// Typically a [PaneThemeData] is specified as part of the
/// overall [Theme] with [ThemeData.paneTheme].
///
/// All [PaneThemeData] properties are `null` by default.
///
/// See also:
///
///  * [PaneTheme], an [InheritedWidget] that propagates the theme down its
///    subtree.
///  * [ThemeData], which describes the overall theme information for the
///    application and can customize a Pane using [ThemeData.paneTheme].
@immutable
class PaneThemeData with Diagnosticable {
  /// Creates a theme that can be used for [ThemeData.paneTheme] and
  /// [PaneTheme].
  const PaneThemeData({
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
    this.compactWidth,
    this.openWidth,
  });

  /// Overrides the default value of [Pane.backgroundColor].
  final Color? backgroundColor;

  /// Overrides the default value of [PaneController.scrimColor].
  final Color? scrimColor;

  /// Overrides the default value of [NavigationPane.elevation].
  final double? elevation;

  /// Overrides the default value for [NavigationPane.shadowColor].
  final Color? shadowColor;

  /// Overrides the default value for [NavigationPane.surfaceTintColor].
  final Color? surfaceTintColor;

  /// Overrides the default value of [NavigationPane.dividerColor].
  final Color? dividerColor;

  /// Overrides the default value of [NavigationPane.shape].
  final ShapeBorder? shape;

  /// Overrides the default value of [NavigationPane.minimalShape].
  final ShapeBorder? minimalShape;

  /// Overrides the default value of [NavigationPane]'s selection indicator.
  final Color? indicatorColor;

  /// Overrides the default shape of the [NavigationPane]'s selection indicator.
  final ShapeBorder? indicatorShape;

  /// Overrides the default size of the [NavigationPane]'s selection indicator.
  final Size? indicatorSize;

  /// The style to merge with the default text style for
  /// [NavigationDestination] labels.
  ///
  /// You can use this to specify a different style when the label is selected.
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// The theme to merge with the default icon theme for
  /// [NavigationDestination] icons.
  ///
  /// You can use this to specify a different icon theme when the icon is
  /// selected.
  final WidgetStateProperty<IconThemeData?>? iconTheme;

  /// Overrides the default value of [Pane.compactWidth].
  final double? compactWidth;

  /// Overrides the default value of [Pane.openWidth].
  final double? openWidth;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  PaneThemeData copyWith({
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
    double? compactWidth,
    double? openWidth,
  }) {
    return PaneThemeData(
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
      compactWidth: compactWidth ?? this.compactWidth,
      openWidth: openWidth ?? this.openWidth,
    );
  }

  /// Linearly interpolate between two pane themes.
  ///
  /// If both arguments are null then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static PaneThemeData? lerp(
    PaneThemeData? a,
    PaneThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return PaneThemeData(
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
      indicatorSize: Size.lerp(a?.indicatorSize, a?.indicatorSize, t),
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
      compactWidth: lerpDouble(a?.compactWidth, b?.compactWidth, t),
      openWidth: lerpDouble(a?.openWidth, b?.openWidth, t),
    );
  }

  @override
  int get hashCode => Object.hash(
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
        compactWidth,
        openWidth,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PaneThemeData &&
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
        other.compactWidth == compactWidth &&
        other.openWidth == openWidth;
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
    properties.add(DoubleProperty('width', compactWidth, defaultValue: null));
    properties.add(DoubleProperty('width', openWidth, defaultValue: null));
  }
}

/// An inherited widget that defines visual properties for [Pane]s in this
/// widget's subtree.
///
/// Values specified here are used for [Pane] properties that are not
/// given an explicit non-null value.
///
/// Using this would allow you to override the [ThemeData.paneTheme].
class PaneTheme extends InheritedTheme {
  /// Creates a theme that defines the [PaneThemeData] properties for a
  /// [Pane].
  const PaneTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Specifies the background color, scrim color, elevation, and shape for
  /// descendant [Pane] widgets.
  final PaneThemeData data;

  static PaneThemeData? of(BuildContext context) {
    final PaneTheme? paneTheme =
        context.dependOnInheritedWidgetOfExactType<PaneTheme>();
    return paneTheme?.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return PaneTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(PaneTheme oldWidget) => data != oldWidget.data;
}
