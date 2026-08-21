import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/admin/domain/admin_dashboard_summary.dart';
import 'package:lem3alam_mobile/src/features/admin/domain/admin_report_item.dart';
import 'package:lem3alam_mobile/src/features/admin/domain/admin_user_item.dart';

void main() {
  test('parses admin dashboard summary payload', () {
    final model = AdminDashboardSummary.fromJson({
      'users_count': 12,
      'tasks_count': '8',
      'disputes_count': 3.0,
      'revenue': '4500.75',
    });

    expect(model.usersCount, 12);
    expect(model.tasksCount, 8);
    expect(model.disputesCount, 3);
    expect(model.revenue, 4500.75);
  });

  test('parses admin user and report payloads', () {
    final user = AdminUserItem.fromJson({
      'id': 7,
      'name': 'Admin User',
      'email': 'admin@example.com',
      'role': 'tasker',
      'status': 'suspended',
      'is_verified': true,
      'city': 'Casablanca',
      'ban_reason': 'spam',
    });
    final report = AdminReportItem.fromJson({
      'id': 3,
      'reason': 'Abuse',
      'status': 'open',
      'description': 'Reported by a client',
      'created_at': '2026-06-26 09:00:00',
    });

    expect(user.isVerified, isTrue);
    expect(user.isSuspended, isTrue);
    expect(user.isBanned, isTrue);
    expect(report.reason, 'Abuse');
    expect(report.status, 'open');
  });
}

