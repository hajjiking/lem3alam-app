import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_models.dart';

void main() {
  test('parses dashboard endpoint data', () {
    final snapshot = DashboardSnapshot.fromJson({
      'stats': {
        'active_tasks': 2,
        'completed_tasks': 4,
        'total_earnings': '450.00',
        'rating': '4.75',
        'pending_tasks': 1,
        'accepted_tasks': 1,
      },
      'recent_tasks': [
        {
          'id': 12,
          'title': 'Fix sink',
          'category': {'id': 3, 'name': 'Plumbing'},
          'city': 'Rabat',
          'dashboard_status': 'accepted',
          'budget': '300.00',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
      ],
      'performance': {
        'earnings': 450,
        'tasks_completed': 1,
        'earnings_change_percent': 10,
        'tasks_change_percent': 5,
        'points': [
          {'day_index': 0, 'value': '450.00'},
        ],
      },
    });

    expect(snapshot.stats.totalEarnings, 450);
    expect(snapshot.stats.rating, 4.75);
    expect(snapshot.tasks.single.title, 'Fix sink');
    expect(snapshot.tasks.single.category, 'Plumbing');
    expect(snapshot.tasks.single.status, DashboardTaskStatus.accepted);
    expect(snapshot.performance.points.single.value, 450);
  });
}
