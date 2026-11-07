import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MainApp());
}

enum AppDesignPreset {
  materialPill('Material Pill'),
  fluentWinUI('Fluent / WinUI 3'),
  minimalCard('Minimal Card');

  const AppDesignPreset(this.label);
  final String label;
}

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppDesignPreset _preset = AppDesignPreset.materialPill;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  AppDesignPreset get preset => _preset;

  void toggleBrightness() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void nextPreset() {
    final nextIndex = (_preset.index + 1) % AppDesignPreset.values.length;
    _preset = AppDesignPreset.values[nextIndex];
    notifyListeners();
  }

  NavigationThemeData buildNavigationTheme() {
    final Color surface =
        isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);
    final Color onSurface =
        isDark ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);
    final Color onSurfaceVariant =
        isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);

    return switch (_preset) {
      AppDesignPreset.materialPill => NavigationThemeData(
          backgroundColor: surface,
          indicatorColor:
              isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE),
          indicatorShape: const StadiumBorder(),
          itemShape: const WidgetStatePropertyAll(StadiumBorder()),
          itemSelectedIconColor:
              isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
          itemIconColor: onSurfaceVariant,
        ),
      AppDesignPreset.fluentWinUI => NavigationThemeData(
          backgroundColor: surface,
          // Indicador estilo barra lateral fina na esquerda (WinUI 3)
          indicatorColor:
              isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
          indicatorSize: const Size(3.5, 18.0),
          menuIndicatorSize: const Size(3.5, 18.0),
          menuIndicatorAlignment: AlignmentDirectional.centerStart,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          itemSelectedBackgroundColor: onSurface.withAlpha(18),
          itemShape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          itemContentPadding: const EdgeInsets.symmetric(horizontal: 12),
          itemSelectedIconColor:
              isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
          itemIconColor: onSurfaceVariant,
        ),
      AppDesignPreset.minimalCard => NavigationThemeData(
          backgroundColor: surface,
          indicatorColor:
              isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isDark ? const Color(0xFF52525B) : const Color(0xFFA1A1AA),
            ),
          ),
          itemShape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          itemSelectedIconColor: onSurface,
          itemIconColor: onSurfaceVariant,
        ),
    };
  }
}

final ThemeController appThemeController = ThemeController();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appThemeController,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: appThemeController.themeMode,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'DZ'),
          ],
          localizationsDelegates: const [GlobalWidgetsLocalizations.delegate],
          locale: const Locale('en', 'US'),
          routerConfig: _router,
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.state, required this.child});
  final GoRouterState state;
  final Widget? child;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late NavigationViewController controller;

  void _navigateToPath(String? path) {
    if (path != null) {
      context.go(path);
    }
  }

  Widget _buildLeading() {
    return Builder(
      builder: (context) => IconButton(
        onPressed: controller.previousPaths.isNotEmpty &&
                controller.previousPaths.length > 1
            ? () {
                controller.goBack();
              }
            : null,
        icon: Icon(Icons.adaptive.arrow_back),
        tooltip: 'Back',
      ),
    );
  }

  @override
  void initState() {
    controller = NavigationViewController(
      length: 6,
      initialPath: '/',
      destinationType: DestinationTypes.byPath,
      onDestinationPath: _navigateToPath,
      vsync: this,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MyApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentPath = widget.state.matchedLocation;
    if (controller.selectedPath != currentPath) {
      controller.selectDestinationByPath(currentPath);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appThemeController,
      builder: (context, _) {
        final navTheme = appThemeController.buildNavigationTheme();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (controller.canGoBack) {
              controller.goBack();
            } else {
              SystemNavigator.pop();
            }
          },
          child: NavigationTheme(
            data: navTheme,
            child: NavigationView(
              controller: controller,
              appBar: NavigationAppBar(
                centerTitle: false,
                titleSpacing: 10,
                additionalLending: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: _buildLeading(),
                ),
                title: Text(
                  'Navigation View (${appThemeController.preset.label})',
                ),
                actions: [
                  // Botão para alternar entre os Presets de Design do NavigationTheme
                  IconButton(
                    onPressed: appThemeController.nextPreset,
                    tooltip:
                        'Change Design Preset (${appThemeController.preset.label})',
                    icon: const Icon(Icons.palette_outlined),
                  ),
                  const SizedBox(width: 4),
                  // Botão para alternar entre Dark e Light Mode
                  IconButton(
                    onPressed: appThemeController.toggleBrightness,
                    tooltip: appThemeController.isDark
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
                    icon: Icon(
                      appThemeController.isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                ],
              ),
              pane: const NavigationPane(
                footers: [
                  PaneItemDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                    path: '/settings',
                  ),
                ],
                destinations: [
                  PaneItemDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Home'),
                    path: '/',
                  ),
                  PaneItemDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profile'),
                    path: '/profile',
                  ),
                  PaneItemDestination(
                    icon: Icon(Icons.folder_outlined),
                    label: Text('Documents'),
                    children: [
                      PaneItemDestination(
                        icon: Icon(Icons.description_outlined),
                        selectedIcon: Icon(Icons.description),
                        label: Text('Files'),
                        path: '/files',
                      ),
                      PaneItemDestination(
                        icon: Icon(Icons.image_outlined),
                        selectedIcon: Icon(Icons.image),
                        label: Text('Images'),
                        path: '/images',
                      ),
                    ],
                  ),
                ],
              ),
              body: Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                child: widget.child!,
              ),
            ),
          ),
        );
      },
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return MyApp(state: state, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const Center(child: Text('Home')),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const Center(child: Text('Profile')),
        ),
        GoRoute(
          path: '/files',
          builder: (context, state) => const Center(child: Text('Files')),
        ),
        GoRoute(
          path: '/images',
          builder: (context, state) => const Center(child: Text('Images')),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Center(child: Text('Settings')),
        ),
      ],
    ),
  ],
);
