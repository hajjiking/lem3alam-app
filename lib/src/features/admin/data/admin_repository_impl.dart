import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/pagination.dart';
import '../domain/admin_dashboard_summary.dart';
import '../domain/admin_nearby_task_settings.dart';
import '../domain/admin_report_item.dart';
import '../domain/admin_repository.dart';
import '../domain/admin_user_item.dart';
import 'admin_api.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(AdminApi(ref.watch(apiClientProvider)));
});

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._api);

  final AdminApi _api;

  @override
  Future<AdminDashboardSummary> fetchDashboard() async {
    final json = await _api.dashboard();
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return AdminDashboardSummary.fromJson(data);
  }

  @override
  Future<Paginated<AdminUserItem>> fetchUsers({int page = 1, int perPage = 20}) async {
    final json = await _api.users(page: page, perPage: perPage);
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return Paginated.fromLaravel(
      data,
      itemFromJson: AdminUserItem.fromJson,
    );
  }

  @override
  Future<void> verifyUser(int userId) async {
    await _api.verifyUser(userId);
  }

  @override
  Future<void> banUser(int userId, {String? reason}) async {
    await _api.banUser(userId, reason: reason);
  }

  @override
  Future<void> unbanUser(int userId) async {
    await _api.unbanUser(userId);
  }

  @override
  Future<void> suspendUser(int userId, {int days = 7, String? reason}) async {
    await _api.suspendUser(userId, days: days, reason: reason);
  }

  @override
  Future<void> unsuspendUser(int userId) async {
    await _api.unsuspendUser(userId);
  }

  @override
  Future<Paginated<AdminReportItem>> fetchReports({int page = 1, int perPage = 20}) async {
    final json = await _api.reports(page: page, perPage: perPage);
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return Paginated.fromLaravel(
      data,
      itemFromJson: AdminReportItem.fromJson,
    );
  }

  @override
  Future<void> resolveReport(int reportId, {String? notes}) async {
    await _api.resolveReport(reportId, notes: notes);
  }

  @override
  Future<void> dismissReport(int reportId, {String? notes}) async {
    await _api.dismissReport(reportId, notes: notes);
  }

  @override
  Future<AdminNearbyTaskSettings> fetchNearbyTaskSettings() async {
    final json = await _api.nearbyTaskSettings();
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return AdminNearbyTaskSettings.fromJson(data);
  }

  @override
  Future<AdminNearbyTaskSettings> updateNearbyTaskSettings(AdminNearbyTaskSettings settings) async {
    final json = await _api.updateNearbyTaskSettings(settings.toJson());
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return AdminNearbyTaskSettings.fromJson(data);
  }
}
