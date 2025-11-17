import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

void main() {
  testWidgets('Teste se o NavigationView está funcionando',
      (WidgetTester tester) async {
    // Construa o widget
    await tester.pumpWidget(
      NavigationView(
        appBar: NavigationAppBar(),
        pane: const NavigationPane(
          destinations: [],
        ),
        controller: NavigationViewController(
          length: 6,
          initialPath: '/',
          vsync: const TestVSync(),
        ),
      ),
    );

    // Verifique se o widget está presente na árvore de widgets
    expect(find.byType(NavigationView), findsOneWidget);

    // Você pode adicionar mais verificações conforme necessário
    // Por exemplo, verificar se a barra de navegação está presente
    expect(find.byType(NavigationAppBar), findsOneWidget);

    // Ou verificar propriedades específicas do widget
    final navigationView =
        find.byType(NavigationView).evaluate().first.widget as NavigationView;
    expect(navigationView.appBar, isNotNull);
  });
}
