import 'package:uuid/uuid.dart';

/// Stores and resolves Meiro session ids.
class MeiroSessionManager {
  /// Creates a session manager.
  MeiroSessionManager({
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  })  : _uuid = uuid,
        _clock = clock ?? DateTime.now;

  final Uuid _uuid;
  final DateTime Function() _clock;

  String? _sessionId;
  DateTime? _appBackgroundTime;
  DateTime? _lastEventSentTime;

  /// Returns the current session id, generating a new one when necessary.
  String getSessionId({DateTime? now}) {
    final effectiveNow = now ?? _clock();
    final localSessionId = _sessionId;
    if (localSessionId == null) {
      return _generateAndSaveSessionId();
    }

    final backgroundTime = _appBackgroundTime;
    if (backgroundTime != null &&
        effectiveNow.difference(backgroundTime) > _backgroundSessionTimeout) {
      return _generateAndSaveSessionId();
    }

    final lastEventSentTime = _lastEventSentTime;
    if (lastEventSentTime != null &&
        effectiveNow.difference(lastEventSentTime) > _eventSessionTimeout) {
      return _generateAndSaveSessionId();
    }

    return localSessionId;
  }

  /// Marks the app as backgrounded.
  void appBackgrounded() {
    _appBackgroundTime = _clock();
  }

  /// Marks the app as foregrounded.
  void appForegrounded() {
    _appBackgroundTime = null;
  }

  /// Marks an event as successfully sent or accepted into the durable queue.
  void eventSent() {
    _lastEventSentTime = _clock();
  }

  /// Clears the current session.
  void clear() {
    _sessionId = null;
    _appBackgroundTime = null;
    _lastEventSentTime = null;
  }

  String _generateAndSaveSessionId() {
    final generated = _uuid.v4();
    _sessionId = generated;
    _appBackgroundTime = null;
    _lastEventSentTime = null;
    return generated;
  }

  static const _eventSessionTimeout = Duration(minutes: 30);
  static const _backgroundSessionTimeout = Duration(seconds: 60);
}

