import 'package:flutter/widgets.dart';

import 'meiro_sdk.dart';

/// Navigator observer that tracks screen view events.
///
/// Add this observer to `MaterialApp.navigatorObservers` or a compatible
/// router configuration.
class MeiroNavigatorObserver extends NavigatorObserver {
  /// Creates a Meiro screen tracking observer.
  MeiroNavigatorObserver({this.screenNameResolver});

  /// Converts a route to a screen name. By default it uses `route.settings.name`.
  final String? Function(Route<dynamic> route)? screenNameResolver;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _track(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _track(previousRoute);
    }
  }

  void _track(Route<dynamic> route) {
    if (!MeiroSdk.isInitialized) {
      return;
    }
    if (!MeiroSdk.configuration.automaticTrackingOptions.screenViewTracking) {
      return;
    }
    final name = screenNameResolver?.call(route) ?? route.settings.name;
    if (name != null && name.isNotEmpty) {
      MeiroSdk.trackScreenView(name);
    }
  }
}

