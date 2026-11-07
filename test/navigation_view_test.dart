import 'package:flutter/gestures.dart';
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
      expect(controller.previousIndices, [0]);

      // Navigate to index 1
      controller.selectDestinationByIndex(1);
      expect(controller.selectedIndex, 1);
      expect(controller.previousIndices, [0, 1]);

      // Navigate to index 2
      controller.selectDestinationByIndex(2);
      expect(controller.selectedIndex, 2);
      expect(controller.previousIndices, [0, 1, 2]);

      // Test goBack
      final success = controller.goBack();
      expect(success, isTrue);
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

    testWidgets('Renders the NavigationView correctly.', (
      WidgetTester tester,
    ) async {
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

    testWidgets('Tapping on a PaneItemDestination changes the selectedIndex.', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final controller = NavigationViewController(
        length: 2,
        initialIndex: 0,
        destinationType: DestinationTypes.byIndex,
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(buildTestApp(controller: controller));
      await tester.pumpAndSettle();

      expect(controller.selectedIndex, 0);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(controller.selectedIndex, 1);
    });

    testWidgets('Adaptive layout changes the display mode based on width.', (
      WidgetTester tester,
    ) async {
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
        buildTestApp(controller: controller, size: const Size(400, 800)),
      );
      await tester.pumpAndSettle();

      final navigationViewState = tester.state<NavigationViewState>(
        find.byType(NavigationView),
      );

      expect(navigationViewState.isPaneOpen, isFalse);
    });

    testWidgets(
      'Shows selected indicator for a child PaneItemDestination in expanded mode',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final controller = NavigationViewController(
          length: 2, // Parent (0), Child (1)
          initialIndex: 0,
          destinationType: DestinationTypes.byIndex,
          vsync: const TestVSync(),
        );

        const child = PaneItemDestination(
          icon: Icon(Icons.person),
          label: Text('Child'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Scaffold(
                body: NavigationView(
                  appBar: const PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: SizedBox(),
                  ),
                  controller: controller,
                  pane: const NavigationPane(
                    destinations: [
                      PaneItemDestination(
                        icon: Icon(Icons.home),
                        label: Text('Parent'),
                        children: [child],
                      ),
                    ],
                  ),
                  body: const SizedBox(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open the parent to reveal the child
        await tester.tap(find.text('Parent'));
        await tester.pumpAndSettle();

        // Select the child
        await tester.tap(find.text('Child'));
        await tester.pumpAndSettle();

        // Flat index check: Parent = 0, Child = 1
        expect(controller.selectedIndex, 1);

        // Verify PaneIndicator is present and active within the child's PaneItemDestination
        final childTextFinder = find.text('Child');
        expect(childTextFinder, findsOneWidget);

        final childDestinationFinder = find
            .ancestor(
              of: childTextFinder,
              matching: find.byType(PaneItemDestination),
            )
            .first;

        final indicatorFinder = find.descendant(
          of: childDestinationFinder,
          matching: find.byType(PaneIndicator),
        );
        expect(indicatorFinder, findsOneWidget);

        final PaneIndicator indicator = tester.widget<PaneIndicator>(
          indicatorFinder,
        );
        expect(indicator.animation.value, 1.0);
      },
    );

    testWidgets(
      'Tapping child in compact mode popup selects correct flat index',
      (WidgetTester tester) async {
        // 700px width triggers Medium/Compact mode
        tester.view.physicalSize = const Size(700, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final controller = NavigationViewController(
          length: 3, // Folder (0), File A (1), File B (2)
          initialIndex: 0,
          destinationType: DestinationTypes.byIndex,
          vsync: const TestVSync(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(700, 800)),
              child: Scaffold(
                body: NavigationView(
                  appBar: const PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: SizedBox(),
                  ),
                  controller: controller,
                  pane: const NavigationPane(
                    destinations: [
                      PaneItemDestination(
                        icon: Icon(Icons.folder),
                        label: Text('Folder'),
                        children: [
                          PaneItemDestination(
                            icon: Icon(Icons.insert_drive_file),
                            label: Text('File A'),
                          ),
                          PaneItemDestination(
                            icon: Icon(Icons.insert_drive_file),
                            label: Text('File B'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap parent to open popup menu
        await tester.tap(find.byIcon(Icons.folder));
        await tester.pumpAndSettle();

        // Tap 'File B' in the flyout overlay
        await tester.tap(find.text('File B').last);
        await tester.pumpAndSettle();

        // Parent is 0, File A is 1, File B is 2.
        expect(controller.selectedIndex, 2);
      },
    );

    testWidgets(
      'Child selection indicator (AnimatedOpacity) is visible in compact mode popup',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(700, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Start with Child A (index 1) already selected
        final controller = NavigationViewController(
          length: 3,
          initialIndex: 1,
          destinationType: DestinationTypes.byIndex,
          vsync: const TestVSync(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(700, 800)),
              child: Scaffold(
                body: NavigationView(
                  appBar: const PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: SizedBox(),
                  ),
                  controller: controller,
                  pane: const NavigationPane(
                    destinations: [
                      PaneItemDestination(
                        icon: Icon(Icons.folder),
                        label: Text('Folder'),
                        children: [
                          PaneItemDestination(
                            icon: Icon(Icons.insert_drive_file),
                            label: Text('File A'),
                          ),
                          PaneItemDestination(
                            icon: Icon(Icons.insert_drive_file),
                            label: Text('File B'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open the popup menu
        await tester.tap(find.byIcon(Icons.folder));
        await tester.pumpAndSettle();

        // Find 'File A' item container in the low-level flyout overlay
        final fileAItem = find
            .ancestor(
              of: find.text('File A').last,
              matching: find.byType(GestureDetector),
            )
            .first;

        // Find 'File B' item container in the low-level flyout overlay
        final fileBItem = find
            .ancestor(
              of: find.text('File B').last,
              matching: find.byType(GestureDetector),
            )
            .first;

        // Verify File A's indicator opacity is 1.0 (visible)
        final fileAOpacity = tester.widget<AnimatedOpacity>(
          find.descendant(
            of: fileAItem,
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(fileAOpacity.opacity, 1.0);

        // Verify File B's indicator opacity is 0.0 (hidden)
        final fileBOpacity = tester.widget<AnimatedOpacity>(
          find.descendant(
            of: fileBItem,
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(fileBOpacity.opacity, 0.0);
      },
    );

    testWidgets(
      'Tapping child in compact mode popup navigates by path correctly',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(700, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final controller = NavigationViewController(
          initialPath: '/home',
          destinationType: DestinationTypes.byPath,
          vsync: const TestVSync(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(700, 800)),
              child: Scaffold(
                body: NavigationView(
                  appBar: const PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: SizedBox(),
                  ),
                  controller: controller,
                  pane: const NavigationPane(
                    destinations: [
                      PaneItemDestination(
                        icon: Icon(Icons.folder),
                        label: Text('Folder'),
                        children: [
                          PaneItemDestination(
                            icon: Icon(Icons.insert_drive_file),
                            label: Text('File A'),
                            path: '/folder/file-a',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap parent to open popup menu
        await tester.tap(find.byIcon(Icons.folder));
        await tester.pumpAndSettle();

        // Tap 'File A'
        await tester.tap(find.text('File A').last);
        await tester.pumpAndSettle();

        // Check if the path was successfully updated
        expect(controller.selectedPath, '/folder/file-a');
      },
    );
  });

  testWidgets(
    'Tapping second child in expanded mode selects correct flat index',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Folder (0), File 1 (1), File 2 (2)
      final controller = NavigationViewController(
        length: 3,
        initialIndex: 0,
        destinationType: DestinationTypes.byIndex,
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Scaffold(
              body: NavigationView(
                appBar: const PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: SizedBox(),
                ),
                controller: controller,
                pane: const NavigationPane(
                  destinations: [
                    PaneItemDestination(
                      icon: Icon(Icons.folder),
                      label: Text('Folder'),
                      children: [
                        PaneItemDestination(
                          icon: Icon(Icons.insert_drive_file),
                          label: Text('File 1'),
                        ),
                        PaneItemDestination(
                          icon: Icon(Icons.insert_drive_file),
                          label: Text('File 2'),
                        ),
                      ],
                    ),
                  ],
                ),
                body: const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand the parent folder
      await tester.tap(find.text('Folder'));
      await tester.pumpAndSettle();

      // Tap the second sub-item (File 2)
      await tester.tap(find.text('File 2'));
      await tester.pumpAndSettle();

      // Expected flat index is 2 (Folder = 0, File 1 = 1, File 2 = 2)
      expect(controller.selectedIndex, 2);

      // Verify that File 2's indicator is active (1.0) and File 1's indicator is inactive (0.0)
      final file2ItemFinder = find
          .ancestor(
            of: find.text('File 2'),
            matching: find.byType(PaneItemDestination),
          )
          .first;
      final file2Indicator = tester.widget<PaneIndicator>(
        find.descendant(
          of: file2ItemFinder,
          matching: find.byType(PaneIndicator),
        ),
      );
      expect(file2Indicator.animation.value, 1.0);

      final file1ItemFinder = find
          .ancestor(
            of: find.text('File 1'),
            matching: find.byType(PaneItemDestination),
          )
          .first;
      final file1Indicator = tester.widget<PaneIndicator>(
        find.descendant(
          of: file1ItemFinder,
          matching: find.byType(PaneIndicator),
        ),
      );
      expect(file1Indicator.animation.value, 0.0);
    },
  );

  testWidgets(
    'In RTL, PaneItem RenderBox positions leading icon to the right of the label and resolves alignment properly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final controller = NavigationViewController(
        length: 1,
        initialIndex: 0,
        destinationType: DestinationTypes.byIndex,
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        MaterialApp(
          // Force RTL text direction (Arabic, Hebrew, etc.)
          builder: (context, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          home: Scaffold(
            body: NavigationView(
              appBar: const PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: SizedBox(),
              ),
              controller: controller,
              pane: const NavigationPane(
                destinations: [
                  PaneItemDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final indicatorFinder = find.byType(PaneIndicator);
      expect(indicatorFinder, findsOneWidget);

      final PaneIndicator indicator = tester.widget<PaneIndicator>(
        indicatorFinder,
      );

      // In RTL, AlignmentDirectional.centerStart resolves to Alignment.centerRight
      expect(
        indicator.alignment.resolve(TextDirection.rtl),
        equals(Alignment.centerRight),
      );

      // Verify in the custom RenderBox that in RTL the icon is positioned to the right (greater dx) of the 'Home' label
      final Offset iconPos = tester.getTopLeft(find.byIcon(Icons.home));
      final Offset labelPos = tester.getTopLeft(find.text('Home'));
      expect(iconPos.dx, greaterThan(labelPos.dx));
    },
  );

  group('Material-Free Tests', () {
    testWidgets(
      'Renders and navigates inside a pure WidgetsApp without MaterialApp or Scaffold',
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
          destinationType: DestinationTypes.byIndex,
          vsync: const TestVSync(),
        );

        await tester.pumpWidget(
          WidgetsApp(
            color: const Color(0xFF000000),
            builder: (context, _) => Directionality(
              textDirection: TextDirection.ltr,
              child: NavigationView(
                controller: controller,
                appBar: NavigationAppBar(
                  title: const Text('Pure WidgetsApp Title'),
                ),
                pane: const NavigationPane(
                  destinations: [
                    PaneItemDestination(
                      icon: SizedBox(width: 24, height: 24),
                      label: Text('First Item'),
                    ),
                    PaneItemDestination(
                      icon: SizedBox(width: 24, height: 24),
                      label: Text('Second Item'),
                    ),
                  ],
                ),
                body: const Center(child: Text('Material-Free Body')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pure WidgetsApp Title'), findsOneWidget);
        expect(find.text('Material-Free Body'), findsOneWidget);
        expect(controller.selectedIndex, 0);

        await tester.tap(find.text('Second Item'));
        await tester.pumpAndSettle();

        expect(controller.selectedIndex, 1);
      },
    );

    testWidgets(
      'Supports custom indicatorBuilder, chevronBuilder, trailing slot, and itemBuilder',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Total flat slots = 4:
        // 0: Custom Indicator Item
        // 1: Custom Chevron Parent
        // 2: Nested Child
        // 3: Custom ItemBuilder Item
        final controller = NavigationViewController(
          length: 4,
          initialIndex: 0,
          destinationType: DestinationTypes.byIndex,
          vsync: const TestVSync(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: NavigationView(
              controller: controller,
              appBar: NavigationAppBar(title: const Text('Custom Builders')),
              pane: NavigationPane(
                destinations: [
                  PaneItemDestination(
                    icon: const Icon(Icons.star),
                    label: const Text('Custom Indicator Item'),
                    trailing: const Text('99+'),
                    indicatorBuilder: (context, details) => Container(
                      key: const ValueKey('custom_winui_indicator'),
                    ),
                  ),
                  PaneItemDestination(
                    icon: const Icon(Icons.folder),
                    label: const Text('Custom Chevron Parent'),
                    chevronBuilder: (context, details) => const Text(
                      '>>',
                      key: ValueKey('custom_chevron'),
                    ),
                    children: const [
                      PaneItemDestination(
                        icon: Icon(Icons.file_open),
                        label: Text('Nested Child'),
                      ),
                    ],
                  ),
                  PaneItemDestination(
                    icon: const SizedBox.shrink(),
                    label: const SizedBox.shrink(),
                    itemBuilder: (context, details) => Text(
                      details.isSelected ? 'ACTIVE_CUSTOM' : 'INACTIVE_CUSTOM',
                      key: const ValueKey('full_custom_item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify that indicatorBuilder, trailing, and chevronBuilder are rendered
        expect(
          find.byKey(const ValueKey('custom_winui_indicator')),
          findsOneWidget,
        );
        expect(find.text('99+'), findsOneWidget);
        expect(find.byKey(const ValueKey('custom_chevron')), findsOneWidget);
        expect(find.text('INACTIVE_CUSTOM'), findsOneWidget);

        // Tap the custom itemBuilder destination (flat index = 3)
        await tester.tap(find.byKey(const ValueKey('full_custom_item')));
        await tester.pumpAndSettle();

        expect(controller.selectedIndex, 3);
        expect(find.text('ACTIVE_CUSTOM'), findsOneWidget);
      },
    );

    testWidgets(
      'WidgetStatesController tracks hover, selected, and disabled states accurately',
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
          destinationType: DestinationTypes.byIndex,
          vsync: const TestVSync(),
        );
        final firstStates = WidgetStatesController();
        final disabledStates = WidgetStatesController();

        await tester.pumpWidget(
          MaterialApp(
            home: NavigationView(
              controller: controller,
              appBar: NavigationAppBar(title: const Text('States Test')),
              pane: NavigationPane(
                destinations: [
                  PaneItemDestination(
                    icon: const Icon(Icons.home),
                    label: const Text('Interactive Home'),
                    statesController: firstStates,
                  ),
                  PaneItemDestination(
                    icon: const Icon(Icons.lock),
                    label: const Text('Locked Item'),
                    enabled: false,
                    statesController: disabledStates,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify initial states
        expect(firstStates.value.contains(WidgetState.selected), isTrue);
        expect(disabledStates.value.contains(WidgetState.disabled), isTrue);

        // Simulate mouse hover over the first item
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.text('Interactive Home')));
        await tester.pumpAndSettle();

        expect(firstStates.value.contains(WidgetState.hovered), isTrue);

        // Attempt to tap the disabled item and ensure selection does not change
        await tester.tap(find.text('Locked Item'));
        await tester.pumpAndSettle();
        expect(controller.selectedIndex, 0);
      },
    );

    testWidgets(
      'NavigationAppBar adapts title text color automatically when background luminance changes',
      (WidgetTester tester) async {
        final controller = NavigationViewController(
          length: 1,
          initialIndex: 0,
          destinationType: DestinationTypes.byIndex,
          vsync: const TestVSync(),
        );
        final ValueNotifier<Color> bgNotifier = ValueNotifier<Color>(
          const Color(0xFF18181B), // Dark background initially
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ValueListenableBuilder<Color>(
              valueListenable: bgNotifier,
              builder: (context, bgColor, _) {
                return NavigationTheme(
                  data: NavigationThemeData(backgroundColor: bgColor),
                  child: NavigationView(
                    controller: controller,
                    appBar: NavigationAppBar(
                      title: const Text('Adaptive Title'),
                    ),
                    pane: const NavigationPane(
                      destinations: [
                        PaneItemDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // With dark background, title text color should be light (luminance > 0.5)
        final DefaultTextStyle titleStyleDark = tester.widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text('Adaptive Title'),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        );
        expect(
          titleStyleDark.style.color!.computeLuminance(),
          greaterThan(0.5),
        );

        // Switch to light background
        bgNotifier.value = const Color(0xFFF8F9FA);
        await tester.pumpAndSettle();

        // With light background, title text color should react and become dark (luminance < 0.5)
        final DefaultTextStyle titleStyleLight = tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('Adaptive Title'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            );
        expect(titleStyleLight.style.color!.computeLuminance(), lessThan(0.5));
      },
    );
  });
}
