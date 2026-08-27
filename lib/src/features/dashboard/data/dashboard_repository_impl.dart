import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';
import 'dashboard_api.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final user = ref.watch(authControllerProvider
      .select((state) => (state.user?.id, state.user?.role)));
  return DashboardRepositoryImpl(
    DashboardApi(ref.watch(apiClientProvider)),
    expectedUserId: user.$1,
    audience: switch (user.$2) {
      'client' => DashboardAudience.client,
      'tasker' => DashboardAudience.tasker,
      _ => DashboardAudience.automatic,
    },
  );
});

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(
    this._api, {
    this.audience = DashboardAudience.automatic,
    this.expectedUserId,
  });

  final DashboardApi _api;
  final DashboardAudience audience;
  final int? expectedUserId;

  @override
  Future<DashboardSnapshot> fetchDashboard() async {
    final response = await _api.fetch(audience: audience);
    final data = response['data'];
    if (response['success'] == false ||
        data is! Map ||
        data['stats'] is! Map ||
        data['recent_tasks'] is! List) {
      throw const FormatException('Invalid dashboard response');
    }
    final stats = data['stats'] as Map;
    if (expectedUserId != null) {
      final owner = data['user'];
      if (owner is! Map ||
          owner['id'].toString() != expectedUserId.toString()) {
        throw const FormatException(
            'Dashboard response belongs to a different account');
      }
    }
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
