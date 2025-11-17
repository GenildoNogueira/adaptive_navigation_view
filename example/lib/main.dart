import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'DZ'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale('en', 'US'),
      //locale: Locale('ar', 'DZ'),
      routerConfig: _router,
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
        onPressed: controller.previousPaths.isNotEmpty
            ? () {
                controller.selectDestinationByPath(controller.lastVisitedPath!);
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
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      controller: controller,
      appBar: NavigationAppBar(
        centerTitle: false,
        titleSpacing: 10,
        additionalLending: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8.0),
          child: _buildLeading(),
        ),
        title: const Text('Navigation View Example'),
      ),
      pane: NavigationPane(
        footers: const [
          PaneItemDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text('Settings'),
            path: '/settings',
          ),
        ],
        destinations: const [
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
          builder: (context, state) {
            return const Center(
              child: Text('Home'),
            );
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) {
            return const Center(
              child: Text('Profile'),
            );
          },
        ),
        GoRoute(
          path: '/files',
          builder: (context, state) {
            return const Center(
              child: Text('Files'),
            );
          },
        ),
        GoRoute(
          path: '/images',
          builder: (context, state) {
            return const Center(
              child: Text('Images'),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) {
            return const Center(
              child: Text('Settings'),
            );
          },
        ),
      ],
    ),
  ],
);
