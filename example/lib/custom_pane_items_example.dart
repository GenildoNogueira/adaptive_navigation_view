import 'package:flutter/material.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

/// Example demonstrating complete customization of PaneItemDestination through theme
class CustomPaneItemsExample extends StatefulWidget {
  const CustomPaneItemsExample({super.key});

  @override
  State<CustomPaneItemsExample> createState() => _CustomPaneItemsExampleState();
}

class _CustomPaneItemsExampleState extends State<CustomPaneItemsExample>
    with TickerProviderStateMixin {
  late NavigationViewController controller;
  int _selectedTheme = 0;

  @override
  void initState() {
    super.initState();
    controller = NavigationViewController(
      length: 6,
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
        // Default Material 3 Theme
        const NavigationThemeData(),

        // Card-style Theme
        NavigationThemeData(
          itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue.withValues(alpha: 0.1);
            }
            return Colors.white;
          }),
          itemSelectedBackgroundColor: Colors.blue.withValues(alpha: 0.15),
          itemHoverBackgroundColor: Colors.grey.withValues(alpha: 0.05),
          itemPressedBackgroundColor: Colors.grey.withValues(alpha: 0.1),
          itemShape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          itemContentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemElevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return 4.0;
            if (states.contains(WidgetState.hovered)) return 2.0;
            return 1.0;
          }),
          itemShadowColor:
              WidgetStateProperty.all(Colors.blue.withValues(alpha: 0.2)),
          itemSpacing: 12.0,
          itemAnimationDuration: const Duration(milliseconds: 300),
          itemAnimationCurve: Curves.easeOutCubic,
        ),

        // Neumorphism Theme
        NavigationThemeData(
          itemBackgroundColor: WidgetStateProperty.all(const Color(0xFFE0E5EC)),
          itemSelectedBackgroundColor: const Color(0xFFE0E5EC),
          itemHoverBackgroundColor: const Color(0xFFE8EAED),
          itemShape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          itemContentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemElevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return 0.0;
            return 0.0; // Neumorphism uses custom shadows
          }),
          itemShadowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFA3B1C6);
            }
            return Colors.white;
          }),
          itemIconColor: const Color(0xFF6C7B7F),
          itemSelectedIconColor: const Color(0xFF4A90E2),
          itemLabelStyle: const TextStyle(
            color: Color(0xFF6C7B7F),
            fontWeight: FontWeight.w500,
          ),
          itemSelectedLabelStyle: const TextStyle(
            color: Color(0xFF4A90E2),
            fontWeight: FontWeight.bold,
          ),
          itemSpacing: 12.0,
          itemAnimationDuration: const Duration(milliseconds: 250),
        ),

        // Glassmorphism Theme
        NavigationThemeData(
          itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white.withValues(alpha: 0.2);
            }
            return Colors.white.withValues(alpha: 0.1);
          }),
          itemHoverBackgroundColor: Colors.white.withValues(alpha: 0.15),
          itemShape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          itemContentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          itemIconColor: Colors.white.withValues(alpha: 0.8),
          itemSelectedIconColor: Colors.white,
          itemLabelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
          itemSelectedLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          itemChevronColor: Colors.white.withValues(alpha: 0.6),
          itemSelectedChevronColor: Colors.white,
          itemSpacing: 16.0,
          itemAnimationDuration: const Duration(milliseconds: 400),
          itemAnimationCurve: Curves.easeOutCubic,
        ),

        // Minimal Theme
        NavigationThemeData(
          itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.black.withValues(alpha: 0.05);
            }
            return Colors.transparent;
          }),
          itemHoverBackgroundColor: Colors.black.withValues(alpha: 0.02),
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
          itemChevronSize: 16.0,
          itemChevronColor: Colors.grey[500],
          itemSelectedChevronColor: Colors.black54,
          itemAnimationDuration: const Duration(milliseconds: 200),
          itemAnimationCurve: Curves.easeInOut,
        ),
      ];

  List<String> get themeNames => [
        'Default Material 3',
        'Card Style',
        'Neumorphism',
        'Glassmorphism',
        'Gradient',
        'Minimal',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom PaneItemDestination Themes'),
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
      body: Container(
        decoration: _selectedTheme == 3 // Glassmorphism
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: NavigationTheme(
          data: themes[_selectedTheme],
          child: NavigationView(
            controller: controller,
            appBar: NavigationAppBar(title: Text("Teste")),
            pane: NavigationPane(
              destinations: [
                PaneItemDestination(
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Dashboard'),
                  path: '/dashboard',
                ),
                PaneItemDestination(
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analytics'),
                  path: '/analytics',
                ),
                PaneItemDestination(
                  icon: const Icon(Icons.people),
                  label: const Text('Users'),
                  path: '/users',
                ),
                PaneItemDestination(
                  icon: const Icon(Icons.folder),
                  label: const Text('Projects'),
                  path: '/projects',
                  initialExpanded: true,
                  children: [
                    PaneItemDestination(
                      icon: const Icon(Icons.web),
                      label: const Text('Web Apps'),
                      path: '/projects/web',
                    ),
                    PaneItemDestination(
                      icon: const Icon(Icons.mobile_friendly),
                      label: const Text('Mobile Apps'),
                      path: '/projects/mobile',
                    ),
                    PaneItemDestination(
                      icon: const Icon(Icons.desktop_windows),
                      label: const Text('Desktop Apps'),
                      path: '/projects/desktop',
                    ),
                  ],
                ),
                PaneItemDestination(
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  path: '/settings',
                ),
                PaneItemDestination(
                  icon: const Icon(Icons.help),
                  label: const Text('Help'),
                  path: '/help',
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Switch themes using the menu above to see different customizations!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _selectedTheme == 3 ? Colors.white : null,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int? index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.analytics;
      case 2:
        return Icons.people;
      case 3:
        return Icons.folder;
      case 4:
        return Icons.settings;
      case 5:
        return Icons.help;
      default:
        return Icons.home;
    }
  }

  String _getTitleForIndex(int? index) {
    switch (index) {
      case 0:
        return 'Dashboard Content';
      case 1:
        return 'Analytics Content';
      case 2:
        return 'Users Content';
      case 3:
        return 'Projects Content';
      case 4:
        return 'Settings Content';
      case 5:
        return 'Help Content';
      default:
        return 'Select a destination';
    }
  }
}

// Example app to run the custom pane items example
class CustomPaneItemsApp extends StatelessWidget {
  const CustomPaneItemsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom PaneItemDestination Themes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CustomPaneItemsExample(),
    );
  }
}

void main() {
  runApp(const CustomPaneItemsApp());
}
