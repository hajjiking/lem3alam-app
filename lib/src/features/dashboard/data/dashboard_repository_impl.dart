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
    if (response['success'] == false ||
        data is! Map ||
        data['stats'] is! Map ||
        data['recent_tasks'] is! List) {
      throw const FormatException('Invalid dashboard response');
    }
    final stats = data['stats'] as Map;
    for (final key in [
      'active_tasks',
      'completed_tasks',
      'pending_tasks',
      'accepted_tasks'
    ]) {
      final count = num.tryParse(stats[key]?.toString() ?? '');
      if (count == null || !count.isFinite || count < 0 || count % 1 != 0) {
        throw FormatException('Invalid dashboard statistic: $key');
      }
    }
    return DashboardSnapshot.fromJson(Map<String, dynamic>.from(data));
  }
}
