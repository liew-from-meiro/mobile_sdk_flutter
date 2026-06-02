import 'package:meiro_sdk/src/event.dart';
import 'package:test/test.dart';

void main() {
  test('maps events to Meiro mobile endpoint payload', () {
    final event = MeiroEvent(
      type: MeiroEventType.custom,
      timestamp: DateTime.utc(2026, 1, 1, 12),
      properties: const {'name': 'Opened', 'count': 2},
      app: const MeiroAppInfo(
        id: 'app-id',
        name: 'Example',
        version: '1.0.0',
        language: 'en',
        adId: 'ad-id',
      ),
      os: const MeiroOsInfo(type: 'android', version: '15'),
      device: const MeiroDeviceInfo(manufacturer: 'Google', model: 'Pixel'),
      firebase: const MeiroFirebaseInfo(
        projectId: 'project-id',
        token: 'token',
      ),
      user: const MeiroUserInfo(userId: 'user-id', sessionId: 'session-id'),
    );

    expect(event.toPayload(), {
      'user_id': 'user-id',
      'session_id': 'session-id',
      'event_type': 'event_custom',
      'event_timestamp': '2026-01-01T12:00:00.000Z',
      'event_data': {'name': 'Opened', 'count': 2},
      'version': '1.0.0',
      'app': {
        'id': 'app-id',
        'name': 'Example',
        'version': '1.0.0',
        'language': 'en',
        'ad_id': 'ad-id',
      },
      'os': {'type': 'android', 'version': '15'},
      'device': {'manufacturer': 'Google', 'model': 'Pixel'},
      'firebase': {
        'project_id': 'project-id',
        'registration_token': 'token',
      },
    });
  });
}

