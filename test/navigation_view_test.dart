import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

void main() {
  group('NavigationViewController Tests', () {
    test('Navigation by Index and History Tracking', () {
      final controller = NavigationViewController(
        length: 3,
        initialIndex: 0,
        destinationType: DestinationTypes.byIndex,
        vsync: const TestVSync(),
      );

      // Initial state
      expect(controller.selectedIndex, 0);
      // The constructor adds the initial index
      expect(
        controller.previousIndices,
        [0],
      );

      // Navigate to index 1
      controller.selectDestinationByIndex(1);
      expect(controller.selectedIndex, 1);
      expect(controller.previousIndices, [0, 1]); // Now history is [0, 1]

      // Navigate to index 2
      controller.selectDestinationByIndex(2);
      expect(controller.selectedIndex, 2);
      expect(controller.previousIndices, [0, 1, 2]);

      // Test goBack
      final success = controller.goBack();
      expect(success, isTrue);
      // It popped the last item (2), so it goes back to 1.
      expect(controller.selectedIndex, 1);
      expect(controller.previousIndices, [0, 1]);
    });

    test('Path navigation and history tracking', () {
      final controller = NavigationViewController(
        initialPath: '/home',
        destinationType: DestinationTypes.byPath,
        vsync: const TestVSync(),
      );

      // Initial state
      expect(controller.selectedPath, '/home');
      expect(controller.previousPaths, ['/home']);

      // Navigate to settings
      controller.selectDestinationByPath('/settings');
      expect(controller.selectedPath, '/settings');
      expect(controller.previousPaths, ['/home', '/settings']);

      // Test goBack
      controller.goBack();
      // It popped the last item (/settings), so it goes back to /home.
      expect(controller.selectedPath, '/home');
      expect(controller.previousPaths, ['/home']);
    });

    test('Pane opening and closing control (isPaneOpen)', () {
      final controller = NavigationViewController(
        length: 2,
        initialIndex: 0,
        vsync: const TestVSync(),
      );

      // Initially closed (animation value is 0.0)
      expect(controller.isPaneOpen, isFalse);

      // Snap open
      controller.snapOpen();
      expect(controller.isPaneOpen, isTrue);
      expect(controller.offset, 1.0);

      // Snap closed
      controller.snapClosed();
      expect(controller.isPaneOpen, isFalse);
    });
  });

  group('NavigationView Widget Tests', () {
    Widget buildTestApp({
      required NavigationViewController controller,
      Size size = const Size(1200, 800),
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(
            body: NavigationView(
              appBar: const PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: SizedBox(),
              ),
              pane: const NavigationPane(
                destinations: [
                  PaneItemDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  PaneItemDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),
              controller: controller,
              body: const Center(child: Text('Body Content')),
            ),
          ),
        ),
      );
    }

    testWidgets('Renders the NavigationView correctly.',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final controller = NavigationViewController(
        length: 2,
        initialIndex: 0,
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(buildTestApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationView), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Tapping on a PaneItemDestination changes the selectedIndex.',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final controller = NavigationViewController(
        length: 2,
        initialIndex: 0,
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(buildTestApp(controller: controller));
      await tester.pumpAndSettle();

      expect(controller.selectedIndex, 0);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(controller.selectedIndex, 1);
    });

    testWidgets('Adaptive layout changes the display mode based on width.',
        (WidgetTester tester) async {
      final controller = NavigationViewController(
        length: 2,
        initialIndex: 0,
        vsync: const TestVSync(),
      );

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
          buildTestApp(controller: controller, size: const Size(400, 800)));
      await tester.pumpAndSettle();

      final navigationViewState =
          tester.state<NavigationViewState>(find.byType(NavigationView));

      expect(navigationViewState.isPaneOpen, isFalse);
    });
  });
}
