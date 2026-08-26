import 'admin_dashboard_models.dart';

abstract interface class AdminDashboardContentRepository {
  AdminDashboardSnapshot loadDashboard();
}
