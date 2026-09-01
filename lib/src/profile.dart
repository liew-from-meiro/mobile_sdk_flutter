import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client for a Meiro Pipes Profile API endpoint.
class MeiroProfile {
  /// Pipes identifier type created by the Mobile SDK source template.
  static const mobileUserIdIdentifierType = 'mobile_user_id';

  /// Creates a Profile API client for one configured Pipes endpoint.
  MeiroProfile({
    required Uri endpoint,
    http.Client? client,
    String identifierType = mobileUserIdIdentifierType,
    String? apiKey,
  })  : _endpoint = endpoint,
        _client = client ?? http.Client(),
        _identifierType = identifierType,
        _apiKey = apiKey {
    if (!endpoint.hasScheme || endpoint.host.isEmpty) {
      throw ArgumentError.value(
        endpoint,
        'endpoint',
        'Must be an absolute Profile API endpoint URL',
      );
    }
    if (identifierType.isEmpty) {
      throw ArgumentError.value(
        identifierType,
        'identifierType',
        'Must not be empty',
      );
    }
  }

  static const _minimumSuccessStatusCode = 200;
  static const _maximumSuccessStatusCode = 299;
  static const _apiKeyHeader = 'X-API-Token';

  final Uri _endpoint;
  final http.Client _client;
  final String _identifierType;
  final String? _apiKey;

  /// Gets the profile identified by [identifierValue].
  Future<MeiroProfileResult> getProfile({
    required String identifierValue,
  }) async {
    if (identifierValue.isEmpty) {
      throw ArgumentError.value(
        identifierValue,
        'identifierValue',
        'Must not be empty',
      );
    }

    final url = _endpoint.replace(
      queryParameters: <String, String>{
        ..._endpoint.queryParameters,
        'identifier_type': _identifierType,
        'identifier_value': identifierValue,
      },
    );
    final response = await _client.get(
      url,
      headers: <String, String>{
        if (_apiKey != null) _apiKeyHeader: _apiKey,
      },
    );
    final json = _decodeResponse(response);

    if (response.statusCode < _minimumSuccessStatusCode ||
        response.statusCode > _maximumSuccessStatusCode) {
      throw MeiroProfileError(
        message: json['error']?.toString() ?? 'Profile API request failed',
        statusCode: response.statusCode,
        code: json['code']?.toString() ?? 'request_failed',
      );
    }

    final profileId = json['profile_id'];
    final attributes = json['attributes'];
    final audiences = json['audiences'];
    if (profileId is! String ||
        profileId.isEmpty ||
        attributes is! Map ||
        audiences is! List ||
        audiences.any((audience) => audience is! String)) {
      throw MeiroProfileError(
        message: 'Profile API response has an invalid shape',
        statusCode: response.statusCode,
        code: 'invalid_response',
      );
    }

    return MeiroProfileResult(
      profileId: profileId,
      attributes: attributes.cast<String, Object?>(),
      audiences: List<String>.from(audiences),
    );
  }

  Map<String, Object?> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return decoded.cast<String, Object?>();
      }
    } on FormatException {
      // Converted to a typed SDK error below.
    }

    throw MeiroProfileError(
      message: 'Profile API response is not a JSON object',
      statusCode: response.statusCode,
      code: 'invalid_response',
    );
  }
}

/// Profile returned by a Meiro Pipes Profile API endpoint.
class MeiroProfileResult {
  /// Creates a Profile API result.
  const MeiroProfileResult({
    required this.profileId,
    required this.attributes,
    required this.audiences,
  });

  /// Pipes profile identifier.
  final String profileId;

  /// Attributes selected in the Pipes Profile API endpoint configuration.
  final Map<String, Object?> attributes;

  /// Audience identifiers matched by the profile.
  final List<String> audiences;
}

/// Error returned by a Meiro Pipes Profile API endpoint.
class MeiroProfileError implements Exception {
  /// Creates a Profile API error.
  const MeiroProfileError({
    required this.message,
    required this.statusCode,
    required this.code,
  });

  /// Human-readable error message.
  final String message;

  /// HTTP status code.
  final int statusCode;

  /// Stable Pipes error code.
  final String code;

  @override
  String toString() => 'MeiroProfileError($statusCode, $code): $message';
}
