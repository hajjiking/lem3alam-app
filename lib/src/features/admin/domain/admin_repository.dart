import 'admin_nearby_task_settings.dart';
import '../../../core/networking/pagination.dart';
import 'admin_dashboard_summary.dart';
import 'admin_report_item.dart';
import 'admin_user_item.dart';

abstract class AdminRepository {
  Future<AdminDashboardSummary> fetchDashboard();
  Future<Paginated<AdminUserItem>> fetchUsers({int page = 1, int perPage = 20});
  Future<void> verifyUser(int userId);
  Future<void> banUser(int userId, {String? reason});
  Future<void> unbanUser(int userId);
  Future<void> suspendUser(int userId, {int days = 7, String? reason});
  Future<void> unsuspendUser(int userId);
  Future<Paginated<AdminReportItem>> fetchReports({int page = 1, int perPage = 20});
  Future<void> resolveReport(int reportId, {String? notes});
  Future<void> dismissReport(int reportId, {String? notes});
  Future<AdminNearbyTaskSettings> fetchNearbyTaskSettings();
  Future<AdminNearbyTaskSettings> updateNearbyTaskSettings(AdminNearbyTaskSettings settings);
}
