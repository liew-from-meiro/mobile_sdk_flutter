import 'dart:convert';

import 'package:http/http.dart' as http;

import 'event.dart';

/// HTTP client for the Meiro mobile event endpoint.
class MeiroEventsApi {
  /// Creates an event API client.
  MeiroEventsApi({required Uri endpoint, http.Client? client})
    : _client = client ?? http.Client(),
      _eventsUrl = endpoint.replace(
        pathSegments: [
          ...endpoint.pathSegments,
          'mobile-sdk',
        ].where((segment) => segment.isNotEmpty).toList(),
      );

  final http.Client _client;
  final Uri _eventsUrl;

  /// Event endpoint URL.
  Uri get eventsUrl => _eventsUrl;

  /// Sends an event object.
  Future<void> sendEvent(MeiroEvent event) {
    return sendPayload(event.toPayload());
  }

  /// Sends a serialized payload map.
  Future<void> sendPayload(Map<String, Object?> payload) async {
    final response = await _client.post(
      _eventsUrl,
      headers: const {'content-type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MeiroApiException(
        'Request failed with status ${response.statusCode}',
        response.statusCode,
        response.body,
      );
    }
  }
}

/// Error returned by the Meiro event endpoint.
class MeiroApiException implements Exception {
  /// Creates an API exception.
  const MeiroApiException(this.message, this.statusCode, this.body);

  /// Error message.
  final String message;

  /// HTTP status code.
  final int statusCode;

  /// Response body.
  final String body;

  @override
  String toString() => 'MeiroApiException($statusCode): $message';
}
