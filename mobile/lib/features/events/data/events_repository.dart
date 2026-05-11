import 'package:dio/dio.dart';
import 'package:hst_scribe/core/net/api_client.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events_repository.g.dart';

/// REST data layer for the per-event mutation endpoints per CONTRACT.md §1:
///
///  * `PATCH  /sessions/{id}/events/{event_id}`           — edit fields
///  * `POST   /sessions/{id}/events/{event_id}/confirm`   — confirm draft
///  * `POST   /sessions/{id}/events/{event_id}/reject`    — reject draft
///
/// PHI-safety: request bodies (which may contain edited field values that
/// echo the source utterance) are NEVER logged. We log only event_id and
/// HTTP status — the api_client interceptor already enforces this at the
/// transport layer but we add explicit guards here too.
class EventsRepository {
  EventsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  static const AppLogger _log = AppLogger('EventsRepository');

  final ApiClient _apiClient;

  /// `POST /sessions/{sessionId}/events/{eventId}/confirm`
  ///
  /// Promotes a draft event to a chart-write candidate. Returns nothing
  /// useful (the contract response is just `{event_id, status}`); throws
  /// [AppFailure] on any non-2xx.
  Future<void> confirm({
    required String sessionId,
    required String eventId,
  }) async {
    _log.info(
      'event confirm',
      data: <String, Object?>{'session_id': sessionId, 'event_id': eventId},
    );
    try {
      await _apiClient.dio.post<Map<String, Object?>>(
        '/sessions/$sessionId/events/$eventId/confirm',
      );
    } on DioException catch (e, st) {
      throw _apiClient.mapError(e, st);
    }
  }

  /// `POST /sessions/{sessionId}/events/{eventId}/reject`
  Future<void> reject({
    required String sessionId,
    required String eventId,
  }) async {
    _log.info(
      'event reject',
      data: <String, Object?>{'session_id': sessionId, 'event_id': eventId},
    );
    try {
      await _apiClient.dio.post<Map<String, Object?>>(
        '/sessions/$sessionId/events/$eventId/reject',
      );
    } on DioException catch (e, st) {
      throw _apiClient.mapError(e, st);
    }
  }

  /// `PATCH /sessions/{sessionId}/events/{eventId}`
  ///
  /// [fields] is the partial update map per CONTRACT.md §1 — only the
  /// keys the nurse changed. The values land directly inside the request
  /// `fields` envelope.
  Future<void> edit({
    required String sessionId,
    required String eventId,
    required Map<String, Object?> fields,
  }) async {
    _log.info(
      'event edit',
      data: <String, Object?>{
        'session_id': sessionId,
        'event_id': eventId,
        // PHI safety: log only field KEYS, never values (values may echo
        // source utterance content for free-text fields).
        'field_keys': fields.keys.toList(growable: false),
      },
    );
    try {
      await _apiClient.dio.patch<Map<String, Object?>>(
        '/sessions/$sessionId/events/$eventId',
        data: <String, Object?>{'fields': fields},
      );
    } on DioException catch (e, st) {
      throw _apiClient.mapError(e, st);
    }
  }
}

@Riverpod(keepAlive: true)
EventsRepository eventsRepository(EventsRepositoryRef ref) =>
    EventsRepository(apiClient: ref.watch(apiClientProvider));
