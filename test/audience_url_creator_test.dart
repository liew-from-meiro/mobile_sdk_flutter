import 'package:meiro_sdk/src/audience.dart';
import 'package:test/test.dart';

void main() {
  group('MeiroAudienceUrlCreator', () {
    test('creates URL without segment or custom parameters', () {
      final url = MeiroAudienceUrlCreator.buildUrl(
        userId: 'testUserId',
        instance: 'inst',
        segment: null,
        parameters: const {},
      );

      expect(
        url.toString(),
        'https://cdp.inst.meiro.io/wbs?attribute=ps_meiro_user_id&value=testUserId',
      );
    });

    test('creates URL with segment', () {
      final url = MeiroAudienceUrlCreator.buildUrl(
        userId: 'testUserId',
        instance: 'inst',
        segment: 42,
        parameters: const {},
      );

      expect(
        url.toString(),
        'https://cdp.inst.meiro.io/wbs?attribute=ps_meiro_user_id&value=testUserId&segment=42',
      );
    });

    test('creates URL with segment and custom parameters', () {
      final url = MeiroAudienceUrlCreator.buildUrl(
        userId: 'testUserId',
        instance: 'inst',
        segment: 42,
        parameters: const {'category_id': '1305'},
      );

      expect(
        url.toString(),
        'https://cdp.inst.meiro.io/wbs?attribute=ps_meiro_user_id&value=testUserId&segment=42&category_id=1305',
      );
    });
  });
}

