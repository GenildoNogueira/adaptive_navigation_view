import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //supportedLocales: const [Locale('ar', 'DZ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: NavigationView(
        appBar: NavigationAppBar(
          centerTitle: false,
          titleSpacing: 10,
          title: const Text('Navigation View Example'),
        ),
        pane: NavigationPane(
          onDestinationSelected: (value) => setState(() {
            _selectedIndex = value;
          }),
          selectedIndex: _selectedIndex,
          children: const [
            PaneItemDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            PaneItemDestination(
              icon: Icon(Icons.person),
              label: Text('Profile'),
            ),
            PaneItemDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        body: [
          const Center(
            child: Text('Home'),
          ),
          const Center(
            child: Text('Profile'),
          ),
          const Center(
            child: Text('Settings'),
          ),
        ][_selectedIndex],
      ),
    );
  }
}
