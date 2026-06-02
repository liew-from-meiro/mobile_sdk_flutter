import 'package:meiro_sdk/src/session_manager.dart';
import 'package:test/test.dart';

void main() {
  group('MeiroSessionManager', () {
    late DateTime now;
    late MeiroSessionManager manager;

    setUp(() {
      now = DateTime.utc(2026, 1, 1, 12);
      manager = MeiroSessionManager(clock: () => now);
    });

    test('generates a session id on first access', () {
      expect(manager.getSessionId(), isNotEmpty);
    });

    test('returns the same session id for consecutive calls', () {
      final first = manager.getSessionId();
      final second = manager.getSessionId();

      expect(second, first);
    });

    test('keeps session when backgrounded for less than 60 seconds', () {
      final first = manager.getSessionId();
      manager.appBackgrounded();
      now = now.add(const Duration(seconds: 30));

      expect(manager.getSessionId(), first);
    });

    test('generates new session when backgrounded for more than 60 seconds', () {
      final first = manager.getSessionId();
      manager.appBackgrounded();
      now = now.add(const Duration(seconds: 61));

      expect(manager.getSessionId(), isNot(first));
    });

    test('keeps session when last event is less than 30 minutes old', () {
      final first = manager.getSessionId();
      manager.eventSent();
      now = now.add(const Duration(minutes: 15));

      expect(manager.getSessionId(), first);
    });

    test('generates new session when last event is more than 30 minutes old', () {
      final first = manager.getSessionId();
      manager.eventSent();
      now = now.add(const Duration(minutes: 31));

      expect(manager.getSessionId(), isNot(first));
    });

    test('foreground clears background timeout', () {
      final first = manager.getSessionId();
      manager.appBackgrounded();
      manager.appForegrounded();
      now = now.add(const Duration(minutes: 10));

      expect(manager.getSessionId(), first);
    });
  });
}

