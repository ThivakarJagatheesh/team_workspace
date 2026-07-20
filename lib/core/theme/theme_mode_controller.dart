import 'package:flutter/widgets.dart';

class ThemeModeController extends InheritedWidget {
  const ThemeModeController({
    super.key,
    required super.child,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback toggleTheme;

  static ThemeModeController of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<ThemeModeController>();
    assert(result != null, 'No ThemeModeController found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ThemeModeController oldWidget) {
    return isDarkMode != oldWidget.isDarkMode;
  }
}
