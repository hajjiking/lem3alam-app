import '../../../core/networking/api_client.dart';

class TasksApi {
  TasksApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> list({
    required int page,
    required int perPage,
    int? categoryId,
  }) {
    return _client.getJson<Map<String, dynamic>>(
      'tasks',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
  }

  Future<Map<String, dynamic>> show(int id) {
    return _client.getJson<Map<String, dynamic>>('tasks/$id');
  }

  Future<Map<String, dynamic>> myTasks({
    required int page,
    required int perPage,
    int? categoryId,
  }) {
    return _client.getJson<Map<String, dynamic>>(
      'my-tasks',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
  }

  Future<Map<String, dynamic>> create(Object payload) {
    return _client.postJson<Map<String, dynamic>>('tasks', data: payload);
  }

  Future<Map<String, dynamic>> update(int id, Object payload) {
    return _client.putJson<Map<String, dynamic>>('tasks/$id', data: payload);
  }

  Future<Map<String, dynamic>> updateViaPost(int id, Object payload) {
    return _client.postJson<Map<String, dynamic>>('tasks/$id', data: payload);
  }

  Future<Map<String, dynamic>> delete(int id) {
    return _client.deleteJson<Map<String, dynamic>>('tasks/$id');
  }

  Future<Map<String, dynamic>> apply(int id, Object payload) {
    return _client.postJson<Map<String, dynamic>>('tasks/$id/apply', data: payload);
  }

  Future<Map<String, dynamic>> nearby({
    required int page,
    required int perPage,
    required int radiusKm,
    bool savedOnly = false,
  }) {
    return _client.getJson<Map<String, dynamic>>(
      'nearby-tasks',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'radius': radiusKm,
        if (savedOnly) 'saved_only': 1,
      },
    );
  }

  Future<Map<String, dynamic>> saveNearby(int id) {
    return _client.postJson<Map<String, dynamic>>('tasks/$id/save-nearby');
  }

  Future<Map<String, dynamic>> unsaveNearby(int id) {
    return _client.deleteJson<Map<String, dynamic>>('tasks/$id/save-nearby');
  }

  Future<Map<String, dynamic>> dismissNearby(int id) {
    return _client.postJson<Map<String, dynamic>>('tasks/$id/dismiss-nearby');
  }

  Future<Map<String, dynamic>> categories({required int perPage}) {
    return _client.getJson<Map<String, dynamic>>(
      'categories',
      queryParameters: {
        'per_page': perPage,
        'active_only': true,
      },
    );
  }
}
