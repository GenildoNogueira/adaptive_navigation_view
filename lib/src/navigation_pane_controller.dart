part of 'navigation_view.dart';

class NavigationPaneController extends ChangeNotifier {
  bool _isPaneOpen = false;

  bool get isPaneOpen => _isPaneOpen;

  void openOrClose(bool isOpened) {
    _isPaneOpen = isOpened;
    notifyListeners();
  }
}
