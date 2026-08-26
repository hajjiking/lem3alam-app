import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';
import 'dashboard_api.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(DashboardApi(ref.watch(apiClientProvider)));
});

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._api);

  final DashboardApi _api;

  @override
  Future<DashboardSnapshot> fetchDashboard() async {
    final response = await _api.fetch();
    final data = response['data'];
    if (data is! Map) return DashboardSnapshot.empty;
    return DashboardSnapshot.fromJson(Map<String, dynamic>.from(data));
  }
}
