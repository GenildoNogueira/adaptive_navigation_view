import 'package:flutter/material.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

/// Example demonstrating how to customize PaneIndicator dimensions
/// by modifying the centralized constants _kIndicatorHeight
class IndicatorCustomizationExample extends StatefulWidget {
  const IndicatorCustomizationExample({super.key});

  @override
  State<IndicatorCustomizationExample> createState() =>
      _IndicatorCustomizationExampleState();
}

class _IndicatorCustomizationExampleState
    extends State<IndicatorCustomizationExample>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  void _navigateToIndex(int? index) {
    if (index != null) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicator Customization Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: NavigationView(
        controller: NavigationViewController(
          length: 6,
          initialPath: '/',
          onDestinationIndex: _navigateToIndex,
          vsync: this,
        ),
        appBar: NavigationAppBar(
          title: const Text('Custom Indicator Dimensions'),
        ),
        pane: NavigationPane(
          footers: const [
            PaneItemDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
              path: '/settings',
            ),
            PaneItemDestination(
              icon: Icon(Icons.help_outline),
              selectedIcon: Icon(Icons.help),
              label: Text('Help'),
              path: '/help',
            ),
          ],
          destinations: const [
            PaneItemDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('Home'),
              path: '/home',
            ),
            PaneItemDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
              path: '/dashboard',
            ),
            PaneItemDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: Text('Analytics'),
              path: '/analytics',
            ),
            PaneItemDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: Text('Documents'),
              children: [
                PaneItemDestination(
                  icon: Icon(Icons.description_outlined),
                  selectedIcon: Icon(Icons.description),
                  label: Text('Text Files'),
                  path: '/documents/text',
                ),
                PaneItemDestination(
                  icon: Icon(Icons.image_outlined),
                  selectedIcon: Icon(Icons.image),
                  label: Text('Images'),
                  path: '/documents/images',
                ),
                PaneItemDestination(
                  icon: Icon(Icons.video_library_outlined),
                  selectedIcon: Icon(Icons.video_library),
                  label: Text('Videos'),
                  path: '/documents/videos',
                ),
              ],
            ),
            PaneItemDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('Team'),
              path: '/team',
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Indicator Customization',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The PaneIndicator dimensions are now controlled by centralized constants:',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'const double _kIndicatorHeight = 46;\n'
                      'const double _kIndicatorWidth = 72;',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benefits',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const _BenefitItem(
                    icon: Icons.dashboard_customize,
                    title: 'Consistent Sizing',
                    description:
                        'All indicators use the same dimensions across the app',
                  ),
                  const _BenefitItem(
                    icon: Icons.tune,
                    title: 'Easy Customization',
                    description:
                        'Change dimensions in one place to affect all indicators',
                  ),
                  const _BenefitItem(
                    icon: Icons.palette_outlined,
                    title: 'Theme Integration',
                    description:
                        'Proper integration with Material Design system',
                  ),
                  const _BenefitItem(
                    icon: Icons.build_outlined,
                    title: 'Maintenance',
                    description:
                        'Easier to maintain and update indicator specifications',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Selection: Index $selectedIndex',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try selecting different items to see the indicator animation in action. '
                    'Notice how all indicators have consistent dimensions thanks to the '
                    'centralized constants.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// How to use this example:
///
/// 1. Add this file to your example app
/// 2. Import and use IndicatorCustomizationExample in your main app
/// 3. To customize indicator dimensions globally:
///    - Navigate to lib/src/navigation_view.dart
///    - Modify the constants:
///      ```dart
///      const double _kIndicatorHeight = 40; // Your custom height
///      const double _kIndicatorWidth = 64;  // Your custom width
///      ```
/// 4. All indicators will automatically use the new dimensions
/// 5. Hot reload to see the changes instantly
