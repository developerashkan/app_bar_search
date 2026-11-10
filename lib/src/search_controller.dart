import 'package:flutter/foundation.dart';

/// Opens and closes an [AppBarSearch] from anywhere (a FAB, a shortcut,
/// a deep link) and reports its state.
///
/// ```dart
/// final search = AppBarSearchController();
/// AppBarSearch(title: 'Mail', searchController: search);
/// // later
/// search.open();
/// ```
class AppBarSearchController extends ChangeNotifier {
  AppBarSearchController({bool isOpen = false}) : _isOpen = isOpen;

  bool _isOpen;

  /// Whether the search field is shown.
  bool get isOpen => _isOpen;

  void open() => _set(true);

  void close() => _set(false);

  void toggle() => _set(!_isOpen);

  void _set(bool value) {
    if (_isOpen == value) return;
    _isOpen = value;
    notifyListeners();
  }
}
