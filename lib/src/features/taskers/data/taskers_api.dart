import '../../../core/networking/api_client.dart';

class TaskersApi {
  TaskersApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> show(int id) {
    return _client.getJson<Map<String, dynamic>>('taskers/$id');
  }

  Future<Map<String, dynamic>> reviews({
    required int id,
    required int page,
    required int perPage,
    required Map<String, dynamic> queryParameters,
  }) {
    return _client.getJson<Map<String, dynamic>>(
      'taskers/$id/reviews',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        ...queryParameters,
      },
    );
  }
}
