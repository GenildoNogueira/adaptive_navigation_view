import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';
import 'package:flutter/material.dart';

/// Simple example demonstrating PaneItemDestination customization through theme
class SimpleThemeExample extends StatefulWidget {
  const SimpleThemeExample({super.key});

  @override
  State<SimpleThemeExample> createState() => _SimpleThemeExampleState();
}

class _SimpleThemeExampleState extends State<SimpleThemeExample>
    with TickerProviderStateMixin {
  late NavigationViewController controller;
  int _selectedTheme = 0;

  @override
  void initState() {
    super.initState();
    controller = NavigationViewController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Different theme configurations
  List<NavigationThemeData> get themes => [
        // Default Theme
        const NavigationThemeData(),

        // Card Theme
        NavigationThemeData(
          itemSelectedBackgroundColor: Colors.blue.withValues(alpha: 0.1),
          itemHoverBackgroundColor: Colors.grey.withValues(alpha: 0.05),
          itemSelectedIconColor: Colors.blue,
          itemSelectedLabelStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          itemContentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemSpacing: 12.0,
        ),

        // Rounded Theme
        NavigationThemeData(
          itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.orange.withValues(alpha: 0.1);
            }
            return Colors.transparent;
          }),
          itemShape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          itemContentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          itemMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemIconColor: Colors.orange[700],
          itemSelectedIconColor: Colors.orange,
          itemLabelStyle: TextStyle(color: Colors.orange[700]),
          itemSelectedLabelStyle: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Minimal Theme
        NavigationThemeData(
          itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.black.withValues(alpha: 0.05);
            }
            return Colors.transparent;
          }),
          itemContentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemMargin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          itemIconSize: WidgetStateProperty.all(20.0),
          itemIconColor: Colors.grey[600],
          itemSelectedIconColor: Colors.black87,
          itemLabelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          itemSelectedLabelStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          itemSpacing: 8.0,
        ),
      ];

  List<String> get themeNames => [
        'Default',
        'Card Style',
        'Rounded',
        'Minimal',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Theme Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _selectedTheme = value;
              });
            },
            itemBuilder: (context) => List.generate(
              themes.length,
              (index) => PopupMenuItem(
                value: index,
                child: Text(themeNames[index]),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(themeNames[_selectedTheme]),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: NavigationTheme(
        data: themes[_selectedTheme],
        child: NavigationView(
          controller: controller,
          appBar: NavigationAppBar(title: Text('Example Theme')),
          pane: NavigationPane(
            destinations: [
              PaneItemDestination(
                icon: const Icon(Icons.home),
                label: const Text('Home'),
              ),
              PaneItemDestination(
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
              PaneItemDestination(
                icon: const Icon(Icons.favorite),
                label: const Text('Favorites'),
              ),
              PaneItemDestination(
                icon: const Icon(Icons.settings),
                label: const Text('Settings'),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getIconForIndex(controller.selectedIndex),
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getTitleForIndex(controller.selectedIndex),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current theme: ${themeNames[_selectedTheme]}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Switch themes using the menu above!',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int? index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.search;
      case 2:
        return Icons.favorite;
      case 3:
        return Icons.settings;
      default:
        return Icons.home;
    }
  }

  String _getTitleForIndex(int? index) {
    switch (index) {
      case 0:
        return 'Home Content';
      case 1:
        return 'Search Content';
      case 2:
        return 'Favorites Content';
      case 3:
        return 'Settings Content';
      default:
        return 'Select a destination';
    }
  }
}

/// Simple app to run the theme example
class SimpleThemeApp extends StatelessWidget {
  const SimpleThemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Theme Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SimpleThemeExample(),
    );
  }
}

void main() {
  runApp(const SimpleThemeApp());
}
