import '../../../core/networking/api_client.dart';

class DashboardApi {
  DashboardApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetch() =>
      _client.getJson<Map<String, dynamic>>('dashboard');
}
