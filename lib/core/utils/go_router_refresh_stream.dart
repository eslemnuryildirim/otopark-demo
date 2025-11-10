import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// GoRouter için Stream-based refresh helper
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

