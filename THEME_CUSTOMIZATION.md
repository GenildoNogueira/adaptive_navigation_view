# Theme-Based Customization for PaneItemDestination

O `PaneItemDestination` agora é completamente customizável através do sistema de tema `PaneThemeData`. Esta abordagem permite criar experiências de navegação únicas mantendo a consistência em toda a aplicação.

## Visão Geral

O sistema de tema expandido oferece controle completo sobre todos os aspectos da aparência e comportamento do `PaneItemDestination`:

- **Cores e Fundos**: Controle cores de fundo, gradientes e cores específicas por estado
- **Formas e Bordas**: Personalize formas, raio de borda e bordas para diferentes estados
- **Layout e Espaçamento**: Controle padding, margins, alturas e espaçamento entre elementos
- **Ícones e Labels**: Personalize tamanhos de ícones, cores e estilos de texto por estado
- **Animações**: Controle duração e curvas de animação
- **Elevação e Sombras**: Adicione elevação e efeitos de sombra personalizados
- **Itens Hierárquicos**: Personalize aparência do chevron e indentação de filhos

## Propriedades do Tema

### Cores de Fundo e Efeitos Visuais

```dart
// Cores básicas de fundo
Color? itemBackgroundColor              // Fundo padrão
Color? itemSelectedBackgroundColor      // Fundo do estado selecionado
Color? itemHoverBackgroundColor         // Fundo do estado hover
Color? itemPressedBackgroundColor       // Fundo do estado pressionado

// Efeitos avançados de fundo
WidgetStateProperty<Gradient?>? itemGradient     // Gradientes baseados em estado
Gradient? itemSelectedGradient                   // Gradiente selecionado
Gradient? itemHoverGradient                      // Gradiente hover

// Elevação e sombras
WidgetStateProperty<double?>? itemElevation      // Elevação baseada em estado
WidgetStateProperty<Color?>? itemShadowColor     // Cores de sombra
```

### Formas e Bordas

```dart
// Forma e raio de borda
WidgetStateProperty<ShapeBorder?>? itemShape           // Formas personalizadas
WidgetStateProperty<BorderRadiusGeometry?>? itemBorderRadius  // Raio de borda

// Bordas para diferentes estados
WidgetStateProperty<BorderSide?>? itemBorder     // Bordas baseadas em estado
BorderSide? itemSelectedBorder                   // Borda selecionada
BorderSide? itemHoverBorder                      // Borda hover
```

### Layout e Dimensões

```dart
// Padding e margins
WidgetStateProperty<EdgeInsetsGeometry?>? itemPadding   // Padding interno
WidgetStateProperty<EdgeInsetsGeometry?>? itemMargin    // Margins externas

// Restrições de altura
double? itemHeight        // Altura fixa
double? itemMinHeight     // Altura mínima
double? itemMaxHeight     // Altura máxima

// Espaçamento
double? itemSpacing       // Espaço entre ícone e label
```

### Ícones

```dart
// Propriedades do ícone
WidgetStateProperty<double?>? itemIconSize    // Tamanhos de ícone por estado
Color? itemIconColor                          // Cor padrão do ícone
Color? itemSelectedIconColor                  // Cor do ícone selecionado
Color? itemHoverIconColor                     // Cor do ícone hover
Color? itemDisabledIconColor                  // Cor do ícone desabilitado
```

### Labels

```dart
// Estilos de texto para diferentes estados
TextStyle? itemLabelStyle              // Estilo padrão do label
TextStyle? itemSelectedLabelStyle      // Estilo do label selecionado
TextStyle? itemHoverLabelStyle         // Estilo do label hover
TextStyle? itemDisabledLabelStyle      // Estilo do label desabilitado
```

### Chevron (Itens Expansíveis)

```dart
// Personalização do chevron
double? itemChevronSize                // Tamanho do ícone chevron
Color? itemChevronColor               // Cor padrão do chevron
Color? itemChevronHoverColor          // Cor do chevron hover
Color? itemSelectedChevronColor       // Cor do chevron selecionado
```

### Filhos (Navegação Hierárquica)

```dart
// Layout dos filhos
double? itemChildrenIndent      // Indentação para itens filhos
double? itemChildrenSpacing     // Espaçamento entre itens filhos
```

### Animações

```dart
// Personalização de animação
Duration? itemAnimationDuration     // Duração da animação
Curve? itemAnimationCurve          // Curva de animação
```

## Uso Básico

### Personalização Simples de Cores

```dart
PaneTheme(
  data: PaneThemeData(
    itemSelectedBackgroundColor: Colors.blue.withOpacity(0.1),
    itemHoverBackgroundColor: Colors.grey.withOpacity(0.05),
    itemSelectedIconColor: Colors.blue,
    itemSelectedLabelStyle: const TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    ),
  ),
  child: NavigationView(
    // Seu conteúdo de navegação
  ),
)
```

### Personalização Baseada em Estado

```dart
PaneTheme(
  data: PaneThemeData(
    itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.blue.withOpacity(0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return Colors.grey.withOpacity(0.05);
      }
      return Colors.transparent;
    }),
    itemPadding: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const EdgeInsets.all(16);
      }
      return const EdgeInsets.all(12);
    }),
  ),
  child: NavigationView(
    // Seu conteúdo de navegação
  ),
)
```

## Exemplos de Temas Completos

### Tema Estilo Card

```dart
PaneThemeData(
  itemBackgroundColor: WidgetStateProperty.all(Colors.white),
  itemSelectedBackgroundColor: Colors.blue.withOpacity(0.1),
  itemHoverBackgroundColor: Colors.grey.withOpacity(0.05),
  itemShape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  itemBorder: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const BorderSide(color: Colors.blue, width: 2);
    }
    return BorderSide(color: Colors.grey.withOpacity(0.2));
  }),
  itemPadding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  itemMargin: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  itemElevation: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return 4.0;
    if (states.contains(WidgetState.hovered)) return 2.0;
    return 1.0;
  }),
  itemShadowColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.2)),
  itemAnimationDuration: const Duration(milliseconds: 300),
  itemAnimationCurve: Curves.easeOutCubic,
)
```

### Tema com Gradiente

```dart
PaneThemeData(
  itemGradient: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }),
  itemShape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  itemPadding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  ),
  itemMargin: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  itemIconColor: Colors.white,
  itemSelectedIconColor: Colors.white,
  itemLabelStyle: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  ),
  itemAnimationDuration: const Duration(milliseconds: 350),
)
```

### Tema Minimalista

```dart
PaneThemeData(
  itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.black.withOpacity(0.05);
    }
    return Colors.transparent;
  }),
  itemHoverBackgroundColor: Colors.black.withOpacity(0.02),
  itemPadding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  itemMargin: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  ),
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
)
```

## Melhores Práticas

### 1. Consistência

- Use espaçamento e dimensionamento consistentes em todas as propriedades do tema
- Mantenha hierarquia visual com estilos de texto e tamanhos de ícone apropriados
- Mantenha durações de animação consistentes para uma experiência coesa

### 2. Acessibilidade

- Garanta contraste de cor suficiente entre texto e fundos
- Forneça feedback visual claro para diferentes estados (hover, selecionado, desabilitado)
- Use cores semânticas que transmitam significado

### 3. Performance

- Use `WidgetStateProperty.all()` quando o mesmo valor se aplica a todos os estados
- Evite cálculos complexos em resolvers de estado
- Cache dados de tema quando possível

### 4. Design Responsivo

- Considere diferentes modos de exibição (expandido, compacto, minimal)
- Teste temas em diferentes tamanhos de tela
- Use espaçamento e dimensionamento apropriados para alvos de toque

## Exemplo de Uso Completo

```dart
import 'package:flutter/material.dart';
import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaneTheme(
        data: PaneThemeData(
          // Personalização de cores
          itemSelectedBackgroundColor: Colors.blue.withOpacity(0.1),
          itemHoverBackgroundColor: Colors.grey.withOpacity(0.05),
          itemSelectedIconColor: Colors.blue,
          itemSelectedLabelStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          
          // Personalização de layout
          itemPadding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          itemMargin: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          itemSpacing: 12.0,
          
          // Personalização de animação
          itemAnimationDuration: const Duration(milliseconds: 250),
          itemAnimationCurve: Curves.easeOutCubic,
        ),
        child: NavigationView(
          controller: NavigationViewController(
            length: 3,
            vsync: this, // Assumindo que o widget é um TickerProvider
          ),
          pane: NavigationPane(
            destinations: [
              PaneItemDestination(
                icon: const Icon(Icons.home),
                label: const Text('Home'),
                path: '/home',
              ),
              PaneItemDestination(
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                path: '/search',
              ),
              PaneItemDestination(
                icon: const Icon(Icons.settings),
                label: const Text('Settings'),
                path: '/settings',
              ),
            ],
          ),
          builder: (context, selectedIndex, child) {
            return Center(
              child: Text('Conteúdo para índice $selectedIndex'),
            );
          },
        ),
      ),
    );
  }
}
```

Este sistema de tema oferece flexibilidade completa para personalizar a aparência do `PaneItemDestination` mantendo a funcionalidade de navegação e seguindo os padrões de tema do Flutter.