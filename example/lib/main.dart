import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar', 'DZ'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<int> _previousPageIndex = [0];

  LocalHistoryEntry? _historyEntry;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  void _ensureHistoryEntry() {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route != null) {
      _historyEntry = LocalHistoryEntry(
        onRemove: _handleHistoryEntryRemoved,
        impliesAppBarDismissal: false,
      );
      route.addLocalHistoryEntry(_historyEntry!);
      FocusScope.of(context).setFirstFocus(_focusScopeNode);
    }
  }

  void _handleHistoryEntryRemoved() {
    setState(() {
      _previousPageIndex.removeLast();
      _selectedIndex =
          _previousPageIndex.isNotEmpty ? _previousPageIndex.last : 0;
    });
  }

  Widget _buildLeading() {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? false;

    return Builder(
      builder: (context) => IconButton(
        onPressed: canPop
            ? () {
                Navigator.maybePop(context);
              }
            : null,
        icon: Icon(Icons.adaptive.arrow_back),
        tooltip: 'Voltar',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        centerTitle: false,
        titleSpacing: 10,
        additionalLending: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _buildLeading(),
        ),
        title: const Text('Navigation View Example'),
      ),
      pane: NavigationPane(
        onDestinationSelected: (value) => setState(() {
          _selectedIndex = value;
          _previousPageIndex.add(value);
          _ensureHistoryEntry();
        }),
        selectedIndex: _selectedIndex,
        footers: const [
          PaneItemDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text('Settings'),
          ),
        ],
        children: const [
          PaneItemDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
          PaneItemDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          Center(
            child: Text('Home'),
          ),
          Center(
            child: Text('Profile'),
          ),
          Center(
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
