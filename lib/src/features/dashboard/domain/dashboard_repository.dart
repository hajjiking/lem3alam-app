import 'dashboard_models.dart';

abstract interface class DashboardRepository {
  DashboardSnapshot loadDashboard();
}
