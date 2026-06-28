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
      expect(controller.previousIndices, [0]);

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

        // Verify PaneIndicator is present within the child's InkWell
        final childTextFinder = find.text('Child');
        expect(childTextFinder, findsOneWidget);

        final inkWellFinder = find.ancestor(
          of: childTextFinder,
          matching: find.byType(InkWell),
        );
        expect(inkWellFinder, findsWidgets);

        final indicatorFinder = find.descendant(
          of: inkWellFinder,
          matching: find.byType(PaneIndicator),
        );
        expect(indicatorFinder, findsWidgets);
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

        // The menu is opened in an overlay. Tap 'File B'.
        // find.last is used because MenuAnchor retains the widget in the tree (hidden) as well as the overlay
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

        // Find 'File A' in the overlay
        final fileAItem = find.ancestor(
          of: find.text('File A').last,
          matching: find.byType(MenuItemButton),
        );

        // Find 'File B' in the overlay
        final fileBItem = find.ancestor(
          of: find.text('File B').last,
          matching: find.byType(MenuItemButton),
        );

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

      // Expande a pasta (Folder)
      await tester.tap(find.text('Folder'));
      await tester.pumpAndSettle();

      // Clica no segundo sub-item (File 2)
      await tester.tap(find.text('File 2'));
      await tester.pumpAndSettle();

      // O índice flat esperado é 2 (Folder = 0, File 1 = 1, File 2 = 2)
      expect(controller.selectedIndex, 2);

      // (Opcional) Verifica se o indicador foi renderizado corretamente para o File 2
      final file2TextFinder = find.text('File 2');
      final inkWellFinder = find.ancestor(
        of: file2TextFinder,
        matching: find.byType(InkWell),
      );
      final indicatorFinder = find.descendant(
        of: inkWellFinder,
        matching: find.byType(PaneIndicator),
      );
      expect(indicatorFinder, findsWidgets);
    },
  );

  testWidgets(
    'Em RTL, o Stack do PaneItem usa Alignment.centerRight para evitar glitches',
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
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        MaterialApp(
          // Força a direção de texto para RTL (Árabe, Hebraico, etc.)
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

      // Encontra o indicador visual para ter certeza de que pegamos o Stack correto
      final indicatorFinder = find.byType(PaneIndicator);
      expect(indicatorFinder, findsOneWidget);

      // Pega o Stack que envolve o Indicador e o Conteúdo
      final stackFinder = find
          .ancestor(of: indicatorFinder, matching: find.byType(Stack))
          .first;

      final Stack stackWidget = tester.widget<Stack>(stackFinder);

      // ASSERTIVA PRINCIPAL:
      // Garante que o alinhamento foi resolvido e não é AlignmentDirectional.centerStart
      expect(
        stackWidget.alignment,
        isNot(equals(AlignmentDirectional.centerStart)),
      );
      // Garante que o alinhamento fixo correto para RTL foi aplicado
      expect(stackWidget.alignment, equals(Alignment.centerRight));
    },
  );
}
