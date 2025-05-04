import 'package:web/helpers.dart';
import 'dart:js_interop';
import 'color_extractor.dart';
import 'dart:math' as math;
import 'package:web/web.dart' as web;

enum AppSession {
  main,
  loaded
}

class SessionManager {
  final Map<AppSession, web.HTMLElement> _sessionContainers;
  AppSession _currentSession;

  SessionManager(this._sessionContainers, {required AppSession initialSession}) : _currentSession = initialSession {
    updateSession();
  }

  void changeSession(AppSession session) {
    if(_currentSession == session) return;
    _currentSession = session;
    updateSession();
  } 

  void updateSession() {
    _sessionContainers.forEach((s, c) {
      if(s == _currentSession) {
        c.classList.add('session-active');
        c.classList.remove('session-inactive');
      } else {
        c.classList.add('session-inactive');
        c.classList.remove('session-active');
      }
    });
  }
}