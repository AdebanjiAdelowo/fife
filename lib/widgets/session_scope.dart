import 'package:flutter/material.dart';

import '../core/state/session.dart';

/// InheritedNotifier wrapper that exposes the [Session] to descendants and
/// rebuilds them whenever the session changes.
class SessionScope extends InheritedNotifier<Session> {
  const SessionScope({
    super.key,
    required Session session,
    required super.child,
  }) : super(notifier: session);

  static Session of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<SessionScope>()
        : context.getInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'No SessionScope found above this widget.');
    return scope!.notifier!;
  }
}
