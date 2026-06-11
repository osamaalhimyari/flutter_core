import 'package:flutter/foundation.dart';

/// Coarse session state for routing decisions.
enum SessionStatus { unknown, authenticated, unauthenticated }

/// The single source of truth a router redirects on. Use it as a GoRouter
/// `refreshListenable` and read [status] in the redirect:
///  - `unknown`        → hold on a splash while a token check runs,
///  - `unauthenticated`→ force the login route,
///  - `authenticated`  → allow the app.
///
/// `FlutterCore.init` creates one, surfaces it on `CoreContext.sessionStatus`,
/// and **auto-flips it to [markUnauthenticated] on any 401** (alongside your
/// optional `onUnauthorized` callback) — so a stale/revoked token returns the
/// user to login from anywhere without per-caller handling. Your auth flow calls
/// [markAuthenticated] on login and [markUnauthenticated] on logout / failed
/// token check.
class SessionStatusNotifier extends ChangeNotifier {
  SessionStatus _status;

  SessionStatusNotifier([this._status = SessionStatus.unknown]);

  SessionStatus get status => _status;

  bool get isAuthenticated => _status == SessionStatus.authenticated;

  void _set(SessionStatus next) {
    if (_status == next) return;
    _status = next;
    notifyListeners();
  }

  void markAuthenticated() => _set(SessionStatus.authenticated);
  void markUnauthenticated() => _set(SessionStatus.unauthenticated);
  void reset() => _set(SessionStatus.unknown);
}
