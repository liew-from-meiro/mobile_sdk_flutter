import 'dart:convert';

import 'package:http/http.dart' as http;

/// Meiro Audience API client.
abstract interface class MeiroAudience {
  /// Sends a WBS request to the Audience API.
  Future<MeiroAudienceResult> wbs({
    required String instance,
    Map<String, String> parameters = const <String, String>{},
    int? segment,
  });
}

/// Meiro Audience API result.
class MeiroAudienceResult {
  /// Creates an Audience API result.
  const MeiroAudienceResult({
    required this.returnedAttributes,
    required this.data,
  });

  /// `returned_attributes` object returned by Audience API.
  final Map<String, Object?> returnedAttributes;

  /// `data` object returned by Audience API.
  final Map<String, Object?> data;
}

/// Audience API error.
class MeiroAudienceError implements Exception {
  /// Creates an Audience API error.
  const MeiroAudienceError(this.message, this.code);

  /// Error message.
  final String message;

  /// HTTP status code.
  final int code;

  @override
  String toString() => 'MeiroAudienceError($code): $message';
}

/// Default Audience API implementation.
class MeiroAudienceImpl implements MeiroAudience {
  /// Creates an Audience API implementation.
  MeiroAudienceImpl({
    required String Function() userIdProvider,
    http.Client? client,
  })  : _userIdProvider = userIdProvider,
        _client = client ?? http.Client();

  final String Function() _userIdProvider;
  final http.Client _client;

  @override
  Future<MeiroAudienceResult> wbs({
    required String instance,
    Map<String, String> parameters = const <String, String>{},
    int? segment,
  }) async {
    final url = MeiroAudienceUrlCreator.buildUrl(
      userId: _userIdProvider(),
      instance: instance,
      segment: segment,
      parameters: parameters,
    );
    final response = await _client.get(url);
    final responseBody = response.body;
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) {
      throw MeiroAudienceError(
        'Audience response is not a JSON object',
        response.statusCode,
      );
    }
    final json = decoded.cast<String, Object?>();
    if (json['status'] == 'ok') {
      return MeiroAudienceResult(
        returnedAttributes:
            ((json['returned_attributes'] as Map?) ?? const {})
                .cast<String, Object?>(),
        data: ((json['data'] as Map?) ?? const {}).cast<String, Object?>(),
      );
    }

    throw MeiroAudienceError(
      json['message']?.toString() ?? 'Audience request failed',
      response.statusCode,
    );
  }
}

/// Builds Audience WBS API URLs.
class MeiroAudienceUrlCreator {
  const MeiroAudienceUrlCreator._();

  /// Builds the Audience WBS URL.
  static Uri buildUrl({
    required String userId,
    required String instance,
    required int? segment,
    required Map<String, String> parameters,
  }) {
    return Uri.https('cdp.$instance.meiro.io', '/wbs', {
      'attribute': 'ps_meiro_user_id',
      'value': userId,
      if (segment != null) 'segment': segment.toString(),
      ...parameters,
    });
  }
}
