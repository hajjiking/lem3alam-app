import '../../../core/networking/api_client.dart';

class AdminApi {
  AdminApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> dashboard({String? locale}) {
    return _client.getJson<Map<String, dynamic>>('admin/dashboard',
        queryParameters: locale == null ? null : {'locale': locale});
  }

  Future<Map<String, dynamic>> users({
    required int page,
    required int perPage,
  }) {
    return _client.getJson<Map<String, dynamic>>(
      'admin/users',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
  }

  Future<Map<String, dynamic>> verifyUser(int userId) {
    return _client.putJson<Map<String, dynamic>>('admin/users/$userId/verify');
  }

  Future<Map<String, dynamic>> banUser(int userId, {String? reason}) {
    return _client.putJson<Map<String, dynamic>>(
      'admin/users/$userId/ban',
      data: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> unbanUser(int userId) {
    return _client.putJson<Map<String, dynamic>>('admin/users/$userId/unban');
  }

  Future<Map<String, dynamic>> suspendUser(int userId,
      {int days = 7, String? reason}) {
    return _client.putJson<Map<String, dynamic>>(
      'admin/users/$userId/suspend',
      data: {
        'days': days,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> unsuspendUser(int userId) {
    return _client
        .putJson<Map<String, dynamic>>('admin/users/$userId/unsuspend');
  }

  Future<Map<String, dynamic>> reports({
    required int page,
    required int perPage,
  }) {
    return _client.getJson<Map<String, dynamic>>(
      'admin/reports',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
  }

  Future<Map<String, dynamic>> resolveReport(int reportId, {String? notes}) {
    return _client.putJson<Map<String, dynamic>>(
      'admin/reports/$reportId/resolve',
      data: {
        if (notes != null && notes.trim().isNotEmpty)
          'resolution_notes': notes.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> dismissReport(int reportId, {String? notes}) {
    return _client.putJson<Map<String, dynamic>>(
      'admin/reports/$reportId/dismiss',
      data: {
        if (notes != null && notes.trim().isNotEmpty)
          'resolution_notes': notes.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> nearbyTaskSettings() {
    return _client.getJson<Map<String, dynamic>>('admin/nearby-task-settings');
  }

  Future<Map<String, dynamic>> updateNearbyTaskSettings(
      Map<String, dynamic> payload) {
    return _client.putJson<Map<String, dynamic>>('admin/nearby-task-settings',
        data: payload);
  }
}
