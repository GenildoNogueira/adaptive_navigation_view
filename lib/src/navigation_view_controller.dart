part of 'navigation_view.dart';

enum DestinationTypes {
  /// The destination is selected by index.
  byIndex,

  /// The destination is selected by path.
  byPath,
}

/// Controls the state of a [NavigationPane] and [NavigationView].
///
/// The [selectedIndex] property is the index of the currently selected navigation
/// destination and the [animation] represents the current position of the pane's
/// open/close state. The selected destination's index can be changed with [selectDestinationByIndex].
///
/// A stateful widget that builds a [NavigationPane] or [NavigationView] can create
/// a [NavigationViewController] and share it directly.
///
/// When the [NavigationPane] and [NavigationView] don't have a convenient stateful
/// ancestor, a [NavigationViewController] can be shared by providing a
/// [NavigationViewController] inherited widget.
class NavigationViewController extends ChangeNotifier {
  /// Creates a controller for [NavigationPane] and [NavigationView].
  ///
  /// The [length] must not be negative. Typically it's a value greater than
  /// zero when there are navigation destinations. The [length] should match
  /// the number of navigable destinations in the [NavigationPane].
  ///
  /// The [initialIndex] must be valid given [length] and [destinationType].
  /// If [length] is zero, then [initialIndex] must be 0 (the default).
  ///
  /// The [initialPath] can be provided to set the initial selected path when
  /// [destinationType] is [DestinationTypes.byPath].
  NavigationViewController({
    int? initialIndex,
    String? initialPath,
    Duration? animationDuration,
    this.length = 0,
    this.destinationType = DestinationTypes.byIndex,
    this.onDestinationIndex,
    this.onDestinationPath,
    required TickerProvider vsync,
  })  : assert(length >= 0),
        assert(
          destinationType == DestinationTypes.byIndex
              ? (initialIndex == null ||
                  (initialIndex >= 0 &&
                      (length == 0
                          ? initialIndex == 0
                          : initialIndex < length)))
              : true,
          'When destinationType is byIndex, initialIndex must be valid for the given length',
        ),
        assert(
          destinationType == DestinationTypes.byPath
              ? initialPath != null
              : true,
          'When destinationType is byPath, initialPath must be provided',
        ),
        _selectedIndex =
            destinationType == DestinationTypes.byIndex ? initialIndex : null,
        _previousIndex =
            destinationType == DestinationTypes.byIndex ? initialIndex : null,
        _previousIndices = destinationType == DestinationTypes.byIndex
            ? (initialIndex != null ? [initialIndex] : <int>[])
            : <int>[],
        _selectedPath =
            destinationType == DestinationTypes.byPath ? initialPath : null,
        _previousPath = destinationType == DestinationTypes.byPath
            ? (initialPath != null ? [initialPath] : <String>[])
            : <String>[],
        _animationDuration = animationDuration ?? _kBaseSettleDuration,
        _destinationAnimations = [],
        _animationController = AnimationController(
          value: 0.0,
          vsync: vsync,
          duration: animationDuration ?? _kBaseSettleDuration,
        ) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }

    // Initialize destination animations only for index-based navigation
    if (destinationType == DestinationTypes.byIndex) {
      _initializeDestinationAnimations(vsync);
    }
  }

  // Private constructor used by `_copyWith`. This allows a new NavigationPaneController to
  // be created without having to create a new AnimationController.
  NavigationViewController._({
    required int? selectedIndex,
    required int? previousIndex,
    required List<int> previousIndices,
    required String? selectedPath,
    required List<String> previousPath,
    required AnimationController animationController,
    required Duration animationDuration,
    required this.length,
    required this.destinationType,
    required this.onDestinationIndex,
    required this.onDestinationPath,
    required List<AnimationController> destinationAnimations,
  })  : _selectedIndex = selectedIndex,
        _previousIndex = previousIndex,
        _previousIndices = previousIndices,
        _selectedPath = selectedPath,
        _previousPath = previousPath,
        _animationController = animationController,
        _animationDuration = animationDuration,
        _destinationAnimations = destinationAnimations {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  /// An animation whose value represents the current position of the [NavigationPane]'s
  /// open/close state.
  ///
  /// The animation's value ranges from 0.0 (closed) to 1.0 (open).
  ///
  /// If this [NavigationViewController] was disposed, then return null.
  Animation<double>? get animation => _animationController.view;

  /// The underlying [AnimationController] used for pane animations.
  ///
  /// This provides direct access to the animation controller for advanced use cases.
  /// If this [NavigationViewController] was disposed, then return null.
  AnimationController get animationController => _animationController;
  final AnimationController _animationController;

  /// Controls the duration of pane open/close animations.
  ///
  /// Defaults to [_kBaseSettleDuration] (300ms).
  Duration get animationDuration => _animationDuration;
  final Duration _animationDuration;

  /// The total number of navigable destinations.
  ///
  /// Typically greater than zero. Should match the number of navigable
  /// destinations in the [NavigationPane].
  final int length;

  /// Defines how destinations are selected and managed.
  ///
  /// - [DestinationTypes.byIndex]: Destinations are selected by index
  /// - [DestinationTypes.byPath]: Destinations are selected by path
  final DestinationTypes destinationType;

  /// Callback that is called when a destination is selected.
  ///
  /// The function receives parameter:
  /// - [index]: The index of the selected destination (can be null)
  final DestinationSelectedIndex? onDestinationIndex;

  /// Callback that is called when a destination is selected.
  ///
  /// The function receives parameter:
  /// - [path]: The path of the selected destination (can be null)
  final DestinationSelectedPath? onDestinationPath;

  /// Animation controllers for each destination's selection state.
  /// Only used when [destinationType] is [DestinationTypes.byIndex].
  final List<AnimationController> _destinationAnimations;

  /// Whether the pane is currently open.
  ///
  /// This is determined by whether the animation value is greater than 0.5.
  bool get isPaneOpen => _animationController.value > 0.5;

  /// Whether the pane is currently animating between open and closed states.
  ///
  /// This value is true during animations triggered by [open], [close], or [toggle].
  bool get isAnimating => _animationController.isAnimating;

  /// Initializes animation controllers for each destination.
  /// Only called when [destinationType] is [DestinationTypes.byIndex].
  void _initializeDestinationAnimations(TickerProvider vsync) {
    _destinationAnimations.clear();
    for (int i = 0; i < length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: vsync,
      );
      _destinationAnimations.add(controller);

      // Set initial animation value for selected destination
      if (i == _selectedIndex) {
        controller.value = 1.0;
      }
    }
  }

  /// Gets the selection animation for a specific destination index.
  ///
  /// Returns an animation that goes from 0.0 (unselected) to 1.0 (selected).
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  Animation<double> getDestinationAnimation(int index) {
    if (destinationType != DestinationTypes.byIndex) {
      return kAlwaysCompleteAnimation;
    }

    if (index < 0 ||
        index >= length ||
        index >= _destinationAnimations.length) {
      return kAlwaysCompleteAnimation;
    }
    return _destinationAnimations[index].view;
  }

  /// Creates a callback for when a destination at the given index is tapped.
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  VoidCallback? createDestinationTapCallback(int index) {
    if (destinationType != DestinationTypes.byIndex) {
      return null;
    }

    return () {
      selectDestinationByIndex(index);
    };
  }

  /// Creates a callback for when a destination with the given path is tapped.
  /// Only available when [destinationType] is [DestinationTypes.byPath].
  VoidCallback? createDestinationPathTapCallback(String path) {
    if (destinationType != DestinationTypes.byPath) {
      return null;
    }

    return () {
      selectDestinationByPath(path);
    };
  }

  void _changeIndex(int? value) {
    if (destinationType == DestinationTypes.byIndex) {
      if (value == null && _selectedIndex == null) {
        return;
      }

      if (value == _selectedIndex) {
        return;
      }

      // Animate previous selection out
      if (_selectedIndex != null &&
          _selectedIndex! < _destinationAnimations.length) {
        _destinationAnimations[_selectedIndex!].animateTo(0.0);
      }

      // Add current index to history before changing
      if (_selectedIndex != null &&
          !_previousIndices.contains(_selectedIndex!)) {
        _previousIndices.add(_selectedIndex!);
      }

      _previousIndex = _selectedIndex;
      _selectedIndex = value;

      // Animate new selection in
      if (_selectedIndex != null &&
          _selectedIndex! < _destinationAnimations.length) {
        _destinationAnimations[_selectedIndex!].animateTo(1.0);
      }
    }

    notifyListeners();
  }

  void _changePath(String? value) {
    if (destinationType == DestinationTypes.byPath) {
      if (value == _selectedPath) {
        return;
      }

      // Add current path to history before changing
      if (_selectedPath != null && !_previousPath.contains(_selectedPath!)) {
        _previousPath.add(_selectedPath!);
      }
      _selectedPath = value;
    }

    notifyListeners();
  }

  /// The index of the currently selected navigation destination.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  /// Changing the index also updates [previousIndex] and notifies listeners.
  ///
  /// The value of [selectedIndex] must be valid given [length]. If [length] is zero,
  /// then [selectedIndex] will also be zero.
  int? get selectedIndex {
    if (destinationType == DestinationTypes.byIndex) {
      return _selectedIndex;
    }
    return null;
  }

  int? _selectedIndex;
  set selectedIndex(int? value) {
    if (destinationType == DestinationTypes.byIndex) {
      assert(
        value == null ||
            (value >= 0 && (length == 0 ? value == 0 : value < length)),
      );
      _changeIndex(value);
    }
  }

  /// The index of the previously selected navigation destination.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  /// Initially the same as [selectedIndex].
  int? get previousIndex {
    if (destinationType == DestinationTypes.byIndex) {
      return _previousIndex;
    }
    return null;
  }

  int? _previousIndex;

  /// The list of previously visited navigation indices.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  /// Contains the history of all indices the user has navigated to.
  List<int> get previousIndices {
    if (destinationType == DestinationTypes.byIndex) {
      return List.unmodifiable(_previousIndices);
    }
    return const <int>[];
  }

  /// Gets the last visited index from the navigation history.
  ///
  /// Returns null if there's no previous index in the history.
  int? get lastVisitedIndex {
    if (destinationType == DestinationTypes.byIndex &&
        _previousIndices.isNotEmpty) {
      return _previousIndices.last;
    }
    return null;
  }

  final List<int> _previousIndices;

  /// The path of the currently selected navigation destination.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byPath].
  /// Can be null if no path is associated with the current destination.
  String? get selectedPath {
    if (destinationType == DestinationTypes.byPath) {
      return _selectedPath;
    }
    return null;
  }

  String? _selectedPath;

  /// The list of previously visited navigation paths.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byPath].
  /// Contains the history of all paths the user has navigated to.
  List<String> get previousPaths {
    if (destinationType == DestinationTypes.byPath) {
      return List.unmodifiable(_previousPath);
    }
    return const <String>[];
  }

  /// Gets the last visited path from the navigation history.
  ///
  /// Returns null if there's no previous path in the history.
  String? get lastVisitedPath {
    if (destinationType == DestinationTypes.byPath &&
        _previousPath.isNotEmpty) {
      return _previousPath.last;
    }
    return null;
  }

  final List<String> _previousPath;

  /// Selects a navigation destination by index.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  /// This updates [selectedIndex], [previousIndex], then notifies listeners
  /// and triggers selection animations.
  void selectDestinationByIndex(int index) {
    if (destinationType != DestinationTypes.byIndex) {
      assert(
        false,
        'selectDestinationByIndex can only be used when destinationTyped is DestinationTyped.byIndex',
      );
      return;
    }

    assert(index >= 0 && (length == 0 ? index == 0 : index < length));
    _changeIndex(index);
    onDestinationIndex?.call(index);
  }

  /// Selects a navigation destination by path.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byPath].
  /// This method updates [selectedPath] and [previousPath], then notifies listeners.
  void selectDestinationByPath(String path) {
    if (destinationType != DestinationTypes.byPath) {
      assert(
        false,
        'selectDestinationByPath can only be used when destinationType is DestinationTyped.byPath',
      );
      return;
    }

    _changePath(path);
    onDestinationPath?.call(path);
  }

  /// Opens the navigation pane with an animation.
  ///
  /// The animation duration can be customized with [duration], otherwise
  /// [animationDuration] is used. The [curve] parameter controls the
  /// animation easing.
  void open({Duration? duration, Curve curve = Curves.easeInOut}) {
    _animationController.animateTo(
      1.0,
      duration: duration ?? _animationDuration,
      curve: curve,
    );
    notifyListeners();
  }

  /// Closes the navigation pane with an animation.
  ///
  /// The animation duration can be customized with [duration], otherwise
  /// [animationDuration] is used. The [curve] parameter controls the
  /// animation easing.
  void close({Duration? duration, Curve curve = Curves.easeInOut}) {
    _animationController.animateTo(
      0.0,
      duration: duration ?? _animationDuration,
      curve: curve,
    );
    notifyListeners();
  }

  /// Toggles the navigation pane between open and closed states.
  ///
  /// If the pane is currently open (animation value > 0.5), it will be closed.
  /// Otherwise, it will be opened.
  void toggle({Duration? duration, Curve curve = Curves.easeInOut}) {
    if (isPaneOpen) {
      close(duration: duration, curve: curve);
    } else {
      open(duration: duration, curve: curve);
    }
  }

  /// Immediately sets the pane to the open state without animation.
  void snapOpen() {
    _animationController.value = 1.0;
    notifyListeners();
  }

  /// Immediately sets the pane to the closed state without animation.
  void snapClosed() {
    _animationController.value = 0.0;
    notifyListeners();
  }

  /// Flings the pane open or closed based on the given velocity.
  ///
  /// A positive velocity opens the pane, a negative velocity closes it.
  /// This is typically used in response to drag gestures.
  void fling({double velocity = 1.0}) {
    _animationController.fling(velocity: velocity);
    notifyListeners();
  }

  /// The current offset of the pane animation.
  ///
  /// This represents how far the pane is from its rest position.
  /// Values range from 0.0 (fully closed) to 1.0 (fully open).
  double get offset => _animationController.value;
  set offset(double value) {
    assert(value >= 0.0 && value <= 1.0);
    if (value == offset) return;

    _animationController.value = value;
    notifyListeners();
  }

  /// Resets the controller to its initial state based on [destinationType].
  ///
  /// For [DestinationTypes.byIndex]: Sets the selected index back to 0 and closes the pane.
  /// For [DestinationTypes.byPath]: Clears the selected path and navigation history, then closes the pane.
  void reset() {
    if (destinationType == DestinationTypes.byIndex) {
      // Reset destination animations
      for (int i = 0; i < _destinationAnimations.length; i++) {
        if (i == 0) {
          _destinationAnimations[i].value = 1.0;
        } else {
          _destinationAnimations[i].value = 0.0;
        }
      }

      _selectedIndex = length > 0 ? 0 : null;
      _previousIndex = _selectedIndex;
      _previousIndices.clear();
    } else if (destinationType == DestinationTypes.byPath) {
      _selectedPath = null;
      _previousPath.clear();
    }

    snapClosed();
  }

  /// Clears the navigation history without changing the current selection.
  ///
  /// Works for both [DestinationTypes.byIndex] and [DestinationTypes.byPath].
  void clearHistory() {
    if (destinationType == DestinationTypes.byIndex) {
      _previousIndices.clear();
      notifyListeners();
    } else if (destinationType == DestinationTypes.byPath) {
      _previousPath.clear();
      notifyListeners();
    }
  }

  /// Navigates back to the previous destination in the history.
  ///
  /// Works for both [DestinationTypes.byIndex] and [DestinationTypes.byPath].
  /// Returns true if navigation was successful, false if there's no history to go back to.
  bool goBack() {
    if (destinationType == DestinationTypes.byIndex &&
        _previousIndices.isNotEmpty) {
      final previousIndex = _previousIndices.removeLast();
      _selectedIndex = previousIndex;
      _previousIndex = previousIndex;

      // Update animations
      for (int i = 0; i < _destinationAnimations.length; i++) {
        if (i == previousIndex) {
          _destinationAnimations[i].animateTo(1.0);
        } else {
          _destinationAnimations[i].animateTo(0.0);
        }
      }

      onDestinationIndex?.call(previousIndex);
      notifyListeners();
      return true;
    } else if (destinationType == DestinationTypes.byPath &&
        _previousPath.isNotEmpty) {
      final previousPath = _previousPath.removeLast();
      _selectedPath = previousPath;
      onDestinationPath?.call(previousPath);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Checks if there's navigation history available to go back to.
  ///
  /// Works for both [DestinationTypes.byIndex] and [DestinationTypes.byPath].
  bool get canGoBack {
    return (destinationType == DestinationTypes.byIndex &&
            _previousIndices.isNotEmpty) ||
        (destinationType == DestinationTypes.byPath &&
            _previousPath.isNotEmpty);
  }

  /// Gets the number of destinations in the navigation history.
  ///
  /// Works for both [DestinationTypes.byIndex] and [DestinationTypes.byPath].
  int get historyLength {
    if (destinationType == DestinationTypes.byIndex) {
      return _previousIndices.length;
    } else if (destinationType == DestinationTypes.byPath) {
      return _previousPath.length;
    }
    return 0;
  }

  /// Removes a specific index from the navigation history.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  /// Returns true if the index was found and removed, false otherwise.
  bool removeIndexFromHistory(int index) {
    if (destinationType == DestinationTypes.byIndex) {
      final removed = _previousIndices.remove(index);
      if (removed) {
        notifyListeners();
      }
      return removed;
    }
    return false;
  }

  /// Removes a specific path from the navigation history.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byPath].
  /// Returns true if the path was found and removed, false otherwise.
  bool removePathFromHistory(String path) {
    if (destinationType == DestinationTypes.byPath) {
      final removed = _previousPath.remove(path);
      if (removed) {
        notifyListeners();
      }
      return removed;
    }
    return false;
  }

  /// Gets an index from the history at the specified position.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  /// Returns null if the position is out of bounds.
  int? getIndexHistoryAt(int position) {
    if (destinationType == DestinationTypes.byIndex &&
        position >= 0 &&
        position < _previousIndices.length) {
      return _previousIndices[position];
    }
    return null;
  }

  /// Gets a path from the history at the specified position.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byPath].
  /// Returns null if the position is out of bounds.
  String? getPathHistoryAt(int position) {
    if (destinationType == DestinationTypes.byPath &&
        position >= 0 &&
        position < _previousPath.length) {
      return _previousPath[position];
    }
    return null;
  }

  /// Checks if a specific index exists in the navigation history.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byIndex].
  bool containsIndexInHistory(int index) {
    return destinationType == DestinationTypes.byIndex &&
        _previousIndices.contains(index);
  }

  /// Checks if a specific path exists in the navigation history.
  ///
  /// Only available when [destinationType] is [DestinationTypes.byPath].
  bool containsPathInHistory(String path) {
    return destinationType == DestinationTypes.byPath &&
        _previousPath.contains(path);
  }

  /// Gets the complete navigation history as a unified list.
  ///
  /// For [DestinationTypes.byIndex]: Returns indices as strings
  /// For [DestinationTypes.byPath]: Returns the actual paths
  List<String> get navigationHistory {
    if (destinationType == DestinationTypes.byIndex) {
      return _previousIndices.map((index) => index.toString()).toList();
    } else if (destinationType == DestinationTypes.byPath) {
      return List.from(_previousPath);
    }
    return const <String>[];
  }

  /// Gets the current selection as a string representation.
  ///
  /// For [DestinationTypes.byIndex]: Returns the selected index as string
  /// For [DestinationTypes.byPath]: Returns the selected path
  String? get currentSelection {
    if (destinationType == DestinationTypes.byIndex) {
      return _selectedIndex?.toString();
    } else if (destinationType == DestinationTypes.byPath) {
      return _selectedPath;
    }
    return null;
  }

  @override
  void dispose() {
    _animationController.dispose();

    // Dispose destination animations
    for (final controller in _destinationAnimations) {
      controller.dispose();
    }
    _destinationAnimations.clear();

    super.dispose();
  }
}
