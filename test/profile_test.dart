import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meiro_sdk/src/profile.dart';
import 'package:test/test.dart';

void main() {
  group('MeiroProfile', () {
    test('gets a mobile profile from the configured Pipes endpoint', () async {
      final api = MeiroProfile(
        endpoint: Uri.parse(
          'https://pipes.example.com/profile-api/mobile-app',
        ),
        apiKey: 'mppak_test',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'https://pipes.example.com/profile-api/mobile-app?identifier_type=mobile_user_id&identifier_value=user-123',
          );
          expect(request.headers['X-API-Token'], 'mppak_test');
          return http.Response(
            jsonEncode({
              'profile_id': 'profile-123',
              'attributes': {'lifetime_value': 42},
              'audiences': ['vip'],
            }),
            200,
          );
        }),
      );

      final result = await api.getProfile(identifierValue: 'user-123');

      expect(result.profileId, 'profile-123');
      expect(result.attributes, {'lifetime_value': 42});
      expect(result.audiences, ['vip']);
    });

    test('throws a typed Pipes error', () async {
      final api = MeiroProfile(
        endpoint: Uri.parse(
          'https://pipes.example.com/profile-api/mobile-app',
        ),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'error': 'Invalid API key',
              'code': 'invalid_api_key',
            }),
            401,
          ),
        ),
      );

      expect(
        api.getProfile(identifierValue: 'user-123'),
        throwsA(
          isA<MeiroProfileError>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.code, 'code', 'invalid_api_key'),
        ),
      );
    });
  });
}
