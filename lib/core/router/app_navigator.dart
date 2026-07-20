import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppNavigator {
  const AppNavigator._();

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String location, {
    Object? extra,
  }) {
    return GoRouter.of(context).push<T>(location, extra: extra);
  }

  static void go(
    BuildContext context,
    String location, {
    Object? extra,
  }) {
    GoRouter.of(context).go(location, extra: extra);
  }

  static void replace(
    BuildContext context,
    String location, {
    Object? extra,
  }) {
    GoRouter.of(context).replace(location, extra: extra);
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    GoRouter.of(context).pop<T>(result);
  }
}
