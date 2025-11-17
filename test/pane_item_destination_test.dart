import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

/// A helper function to pump a `NavigationView` with a given configuration.
///
/// This reduces boilerplate code in tests by setting up a standard `MaterialApp`
/// and `Scaffold` environment for the `NavigationView`.
///
/// It returns the `NavigationViewController` used in the widget tree, allowing
/// tests to interact with it programmatically.
Future<NavigationViewController> pumpNavigationView(
  WidgetTester tester, {
  required List<PaneItemDestination> destinations,
  NavigationViewController? controller,
  DisplayMode? displayMode,
  void Function(int? index)? onDestinationIndex,
  void Function(String? path)? onDestinationPath,
  int initialIndex = 0,
  String? initialPath,
}) async {
  final effectiveController = controller ??
      NavigationViewController(
        vsync: const TestVSync(),
        initialIndex: initialIndex,
        initialPath: initialPath,
        onDestinationIndex: onDestinationIndex,
        onDestinationPath: onDestinationPath,
      );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NavigationView(
          controller: effectiveController,
          appBar: NavigationAppBar(title: const Text('Test')),
          pane: NavigationPane(
            destinations: destinations,
          ),
          body: const Center(child: Text('Body Content')),

        ),
      ),
    ),
  );

  // A single pump is needed to settle the initial state.
  await tester.pump();

  return effectiveController;
}

void main() {
  group('PaneItemDestination Properties', () {
    test('hasChildren should return correct value based on children list', () {
      const destinationWithChildren = PaneItemDestination(
        icon: Icon(Icons.folder),
        label: Text('Folder'),
        children: [
          PaneItemDestination(icon: Icon(Icons.file_copy), label: Text('File')),
        ],
      );

      const destinationWithoutChildren = PaneItemDestination(
        icon: Icon(Icons.home),
        label: Text('Home'),
      );

      const destinationWithEmptyChildren = PaneItemDestination(
        icon: Icon(Icons.folder_open),
        label: Text('Empty'),
        children: [],
      );

      expect(destinationWithChildren.hasChildren, isTrue);
      expect(destinationWithoutChildren.hasChildren, isFalse);
      expect(destinationWithEmptyChildren.hasChildren, isFalse);
    });

    test('isSelectable should return correct value based on state', () {
      const selectable = PaneItemDestination(
        icon: Icon(Icons.home),
        label: Text('Home'),
        enabled: true,
      );

      const disabled = PaneItemDestination(
        icon: Icon(Icons.home),
        label: Text('Home'),
        enabled: false,
      );

      const parentWithoutOnTap = PaneItemDestination(
        icon: Icon(Icons.folder),
        label: Text('Folder'),
        enabled: true,
        children: [
          PaneItemDestination(icon: Icon(Icons.file_copy), label: Text('File')),
        ],
      );

      const parentWithOnTap = PaneItemDestination(
        icon: Icon(Icons.folder),
        label: Text('Folder'),
        enabled: true,
        children: [
          PaneItemDestination(icon: Icon(Icons.file_copy), label: Text('File')),
        ],
      );

      expect(selectable.isSelectable, isTrue);
      expect(disabled.isSelectable, isFalse);
      expect(parentWithoutOnTap.isSelectable, isFalse,
          reason: 'Parent without onTap should not be selectable',);
      expect(parentWithOnTap.isSelectable, isTrue,
          reason: 'Parent with onTap should be selectable',);
    });
  });

  group('Basic Rendering and Behavior', () {
    testWidgets('should render icon and label', (tester) async {
      await pumpNavigationView(
        tester,
        destinations: const [
          PaneItemDestination(
            icon: Icon(Icons.home),
            label: Text('Home'),
          ),
        ],
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should show selectedIcon when selected', (tester) async {
      await pumpNavigationView(
        tester,
        destinations: const [
          PaneItemDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
        ],
        initialIndex: 0, // Explicitly select the first item
      );

      expect(find.byIcon(Icons.home), findsOneWidget,
          reason: 'Selected icon should be visible',);
      expect(find.byIcon(Icons.home_outlined), findsNothing,
          reason: 'Regular icon should not be visible',);
    });

    testWidgets('should handle disabled state correctly', (tester) async {
      int tapCount = 0;
      await pumpNavigationView(
        tester,
        destinations: [
          PaneItemDestination(
            icon: const Icon(Icons.home),
            label: const Text('Home'),
            onTap: () => tapCount++,
            enabled: false,
          ),
        ],
      );

      // Verify the widget property
      final destinationWidget =
          tester.widget<PaneItemDestination>(find.byType(PaneItemDestination));
      expect(destinationWidget.enabled, isFalse);

      // Attempt to tap the disabled item
      await tester.tap(find.text('Home'));
      await tester.pump();

      // The tap callback should not have been called
      expect(tapCount, 0, reason: 'Disabled destination should not be tappable');
    });

    testWidgets('should call custom onTap when provided', (tester) async {
      bool wasTapped = false;
      await pumpNavigationView(
        tester,
        destinations: [
          PaneItemDestination(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            onTap: () {
              wasTapped = true;
            },
          ),
        ],
      );

      await tester.tap(find.text('Logout'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('should dispose animation controllers without error',
        (tester) async {
      await pumpNavigationView(
        tester,
        destinations: const [
          PaneItemDestination(
            icon: Icon(Icons.folder),
            label: Text('Documents'),
            children: [
              PaneItemDestination(
                icon: Icon(Icons.description),
                label: Text('Files'),
              ),
            ],
          ),
        ],
      );

      // Dispose by pumping a different widget tree
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // No exceptions should be thrown, especially related to Ticker disposal
      expect(tester.takeException(), isNull);
    });
  });

  group('Selection', () {
    final destinations = [
      const PaneItemDestination(
        icon: Icon(Icons.home),
        label: Text('Home'),
        path: '/home',
      ),
      const PaneItemDestination(
        icon: Icon(Icons.settings),
        label: Text('Settings'),
        path: '/settings',
      ),
    ];

    testWidgets('should handle path-based selection on tap', (tester) async {
      String? selectedPath;
      final controller = NavigationViewController(
        onDestinationPath: (path) => selectedPath = path,
        vsync: const TestVSync(),
      );

      await pumpNavigationView(tester,
          destinations: destinations, controller: controller,);

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(selectedPath, '/settings');
      expect(controller.selectedPath, '/settings');
    });

    testWidgets('should handle index-based selection on tap', (tester) async {
      int? selectedIndex;
      final controller = NavigationViewController(
        onDestinationIndex: (index) => selectedIndex = index,
        vsync: const TestVSync(),
      );

      await pumpNavigationView(tester,
          destinations: destinations, controller: controller,);

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(selectedIndex, 1);
      expect(controller.selectedIndex, 1);
    });

    testWidgets('should call onDestinationSelected callback', (tester) async {
      String? selectedPath;
      int? selectedIndex;

      await pumpNavigationView(
        tester,
        destinations: destinations,
        onDestinationSelected: ({index, path}) {
          selectedIndex = index;
          selectedPath = path;
        },
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(selectedIndex, 1);
      expect(selectedPath, '/settings');
    });

    testWidgets('should update selection programmatically via controller',
        (tester) async {
      final controller = await pumpNavigationView(tester,
          destinations: destinations, initialIndex: 0,);

      // Verify initial state
      expect(controller.selectedIndex, 0);

      // Programmatically change selection
      controller.selectedIndex = 1;
      await tester.pumpAndSettle();

      // Find the indicator, which is a descendant of the selected PaneItemDestination
      final indicator = find.byType(PaneIndicator);
      final settingsItem = find.ancestor(
        of: find.text('Settings'),
        matching: find.byType(PaneItemDestination),
      );
      final indicatorAncestor = find.ancestor(
        of: indicator,
        matching: settingsItem,
      );

      expect(indicatorAncestor, findsOneWidget,
          reason:
              'Indicator should be a child of the programmatically selected destination',);
    });
  });

  group('Hierarchy and Expansion', () {
    final hierarchicalDestinations = [
      const PaneItemDestination(
        icon: Icon(Icons.folder),
        label: Text('Documents'),
        children: [
          PaneItemDestination(
            icon: Icon(Icons.description),
            label: Text('Files'),
            path: '/documents/files',
          ),
          PaneItemDestination(
            icon: Icon(Icons.image),
            label: Text('Images'),
            path: '/documents/images',
          ),
        ],
      ),
    ];

    testWidgets('should expand and collapse children on tap', (tester) async {
      await pumpNavigationView(tester, destinations: hierarchicalDestinations);

      // Initially, children should not be visible
      expect(find.text('Files'), findsNothing);
      expect(find.text('Images'), findsNothing);

      // Tap parent to expand
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Children should now be visible
      expect(find.text('Files'), findsOneWidget);
      expect(find.text('Images'), findsOneWidget);

      // Tap parent again to collapse
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Children should be hidden again
      expect(find.text('Files'), findsNothing);
      expect(find.text('Images'), findsNothing);
    });

    testWidgets('should respect initialExpanded state', (tester) async {
      await pumpNavigationView(
        tester,
        destinations: const [
          PaneItemDestination(
            icon: Icon(Icons.folder),
            label: Text('Documents'),
            initialExpanded: true,
            children: [
              PaneItemDestination(
                icon: Icon(Icons.description),
                label: Text('Files'),
                path: '/files',
              ),
            ],
          ),
        ],
      );

      // Children should be visible initially
      expect(find.text('Files'), findsOneWidget);
    });

    testWidgets('should select child destination correctly', (tester) async {
      String? selectedPath;
      await pumpNavigationView(
        tester,
        destinations: hierarchicalDestinations,
        onDestinationSelected: ({path, ...}) => selectedPath = path,
      );

      // Expand parent
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Tap child
      await tester.tap(find.text('Images'));
      await tester.pump();

      expect(selectedPath, '/documents/images');
    });
  });

  group('Display Modes', () {
    const destinations = [
      PaneItemDestination(icon: Icon(Icons.home), label: Text('Home')),
      PaneItemDestination(
        icon: Icon(Icons.folder),
        label: Text('Folder'),
        children: [
          PaneItemDestination(
              icon: Icon(Icons.file_copy), label: Text('File'),),
        ],
      ),
    ];

    testWidgets('should only show icons in compact mode', (tester) async {
      await pumpNavigationView(
        tester,
        destinations: destinations,
        displayMode: DisplayMode.compact,
      );

      // Labels should not be visible in compact mode
      expect(find.text('Home'), findsNothing);
      expect(find.text('Folder'), findsNothing);

      // Icons should be visible
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('should show icon and label in expanded mode', (tester) async {
      await pumpNavigationView(
        tester,
        destinations: destinations,
        displayMode: DisplayMode.expanded,
      );

      // Labels should be visible in expanded mode
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Folder'), findsOneWidget);

      // Icons should also be visible
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('should show chevron for expandable items', (tester) async {
      await pumpNavigationView(tester, destinations: destinations);

      // The home destination has no children, so no chevron
      final homeItem = find.ancestor(
        of: find.text('Home'),
        matching: find.byType(PaneItemDestination),
      );
      expect(find.descendant(of: homeItem, matching: find.byIcon(Icons.chevron_right)), findsNothing);


      // The folder destination has children, so it should have a chevron
      final folderItem = find.ancestor(
        of: find.text('Folder'),
        matching: find.byType(PaneItemDestination),
      );
      expect(find.descendant(of: folderItem, matching: find.byIcon(Icons.chevron_right)), findsOneWidget);
    });
  });

  group('PaneIndicator', () {
    testWidgets('should animate in and out correctly', (tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: const TestVSync(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaneIndicator(
              animation: controller,
              color: Colors.blue,
              shape: const RoundedRectangleBorder(),
              width: 64,
              height: 46,
            ),
          ),
        ),
      );

      // Helper to get current opacity
      Opacity getOpacity() => tester.widget<Opacity>(find.byType(Opacity));

      // Initially not visible (value 0)
      controller.value = 0.0;
      await tester.pump();
      expect(getOpacity().opacity, closeTo(0.0, 0.001));

      // Animate in (value 1)
      controller.forward();
      await tester.pumpAndSettle();
      expect(getOpacity().opacity, closeTo(1.0, 0.001));

      // Animate out (value 0)
      controller.reverse();
      await tester.pumpAndSettle();
      expect(getOpacity().opacity, closeTo(0.0, 0.001));
    });
  });
}
