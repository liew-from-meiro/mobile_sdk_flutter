import 'dart:convert';

import 'package:http/http.dart' as http;

import 'event.dart';

/// HTTP client for the Meiro mobile event endpoint.
class MeiroEventsApi {
  /// Creates an event API client.
  MeiroEventsApi({
    required Uri endpoint,
    http.Client? client,
  })
    : _client = client ?? http.Client(),
      _eventsUrl = _normalizeEndpoint(endpoint),
      _pushEventsUrl = _derivePipesPushEventsEndpoint(endpoint);

  final http.Client _client;
  final Uri _eventsUrl;
  final Uri? _pushEventsUrl;

  static final _mobilePushReportEventTypeIds = <String>{
    MeiroEventType.fcmTokenRegistered.id,
    MeiroEventType.fcmMessageReceived.id,
    MeiroEventType.fcmMessageClick.id,
  };

  /// Event endpoint URL.
  Uri get eventsUrl => _eventsUrl;

  /// Sends an event object.
  Future<void> sendEvent(MeiroEvent event) {
    return sendPayload(event.toPayload());
  }

  /// Sends a serialized payload map.
  Future<void> sendPayload(Map<String, Object?> payload) async {
    final response = await _client.post(
      _resolveEndpoint(payload),
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

  Uri _resolveEndpoint(Map<String, Object?> payload) {
    final pushEventsUrl = _pushEventsUrl;
    if (pushEventsUrl != null &&
        _mobilePushReportEventTypeIds.contains(payload['event_type'])) {
      return pushEventsUrl;
    }
    return _eventsUrl;
  }

  static Uri _normalizeEndpoint(Uri endpoint) {
    return endpoint.replace(
      pathSegments: endpoint.pathSegments
          .where((segment) => segment.isNotEmpty)
          .toList(),
    );
  }

  static Uri? _derivePipesPushEventsEndpoint(Uri endpoint) {
    final pathSegments = endpoint.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    final collectIndex = pathSegments.lastIndexOf('collect');
    if (collectIndex < 0 || collectIndex != pathSegments.length - 2) {
      return null;
    }

    // ponytail: derive only standard Pipes URLs; add an override if custom
    // gateways need a different push-report route.
    return Uri.parse(endpoint.origin).replace(
      pathSegments: <String>[
        ...pathSegments.take(collectIndex),
        'api',
        'channels',
        'push',
        'events',
      ],
    );
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
