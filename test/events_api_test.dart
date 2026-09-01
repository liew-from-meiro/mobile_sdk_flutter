import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meiro_sdk/src/event.dart';
import 'package:meiro_sdk/src/events_api.dart';
import 'package:test/test.dart';

void main() {
  group('MeiroEventsApi', () {
    test('derives the Pipes push endpoint from the collection URL', () async {
      final requestedUrls = <Uri>[];
      final api = MeiroEventsApi(
        endpoint: Uri.parse('https://pipes.example.com/collect/mobile-app'),
        client: MockClient((request) async {
          requestedUrls.add(request.url);
          return http.Response('{}', 200);
        }),
      );

      await api.sendPayload({'event_type': MeiroEventType.screenView.id});
      await api.sendPayload({
        'event_type': MeiroEventType.fcmTokenRegistered.id,
      });

      expect(requestedUrls, [
        Uri.parse('https://pipes.example.com/collect/mobile-app'),
        Uri.parse('https://pipes.example.com/api/channels/push/events'),
      ]);
    });

    test('keeps legacy push routing for non-Pipes endpoints', () async {
      late Uri requestedUrl;
      final api = MeiroEventsApi(
        endpoint: Uri.parse('https://events.example.com/meiro_mobile'),
        client: MockClient((request) async {
          requestedUrl = request.url;
          return http.Response('{}', 200);
        }),
      );

      await api.sendPayload({
        'event_type': MeiroEventType.fcmMessageClick.id,
      });

      expect(
        requestedUrl,
        Uri.parse('https://events.example.com/meiro_mobile'),
      );
    });
  });
}
