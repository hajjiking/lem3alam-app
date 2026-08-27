import '../../../core/networking/api_client.dart';

enum DashboardAudience {
  automatic('dashboard'),
  tasker('tasker/dashboard'),
  client('client/dashboard');

  const DashboardAudience(this.path);

  final String path;
}

class DashboardApi {
  DashboardApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetch({
    DashboardAudience audience = DashboardAudience.automatic,
  }) =>
      _client.getJson<Map<String, dynamic>>(audience.path);
}
