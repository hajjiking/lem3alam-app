enum AdminColorKey { primary, success, purple, warning, info, error }

enum AdminDashboardRange { week, month }

class TaskSeriesPoint {
  const TaskSeriesPoint(
      {required this.date,
      required this.posted,
      required this.started,
      required this.completed});

  final DateTime date;
  final double posted;
  final double started;
  final double completed;

  factory TaskSeriesPoint.fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date']?.toString() ?? '');
    if (date == null) throw const FormatException('Invalid analytics date');
    return TaskSeriesPoint(
        date: date,
        posted: analyticsCount(json['posted']).toDouble(),
        started: analyticsCount(json['started']).toDouble(),
        completed: analyticsCount(json['completed']).toDouble());
  }
}

class AdminStatusCount {
  const AdminStatusCount({required this.status, required this.count});
  final String status;
  final int count;
}

class AdminCategoryStat {
  const AdminCategoryStat(
      {required this.id,
      required this.name,
      required this.count,
      required this.percent});
  final int? id;
  final String? name;
  final int count;
  final double percent;
}

class AdminRecentTask {
  const AdminRecentTask(
      {required this.id,
      required this.title,
      required this.customerName,
      required this.status,
      required this.createdAt,
      required this.thumbnailUrl});
  final int id;
  final String title;
  final String? customerName;
  final String status;
  final DateTime? createdAt;
  final String? thumbnailUrl;
}

class AdminDashboardAnalytics {
  const AdminDashboardAnalytics(
      {required this.weeklySeries,
      required this.monthlySeries,
      required this.statusCounts,
      required this.categories,
      required this.recentTasks,
      required this.timezone});

  final List<TaskSeriesPoint> weeklySeries;
  final List<TaskSeriesPoint> monthlySeries;
  final List<AdminStatusCount> statusCounts;
  final List<AdminCategoryStat> categories;
  final List<AdminRecentTask> recentTasks;
  final String timezone;

  int get totalTasks => statusCounts.fold(0, (sum, item) => sum + item.count);

  factory AdminDashboardAnalytics.fromJson(Map<String, dynamic> json) =>
      AdminDashboardAnalytics(
        timezone: json['timezone']?.toString() ?? '',
        weeklySeries:
            _rows(json, 'weekly_series').map(TaskSeriesPoint.fromJson).toList(),
        monthlySeries: _rows(json, 'monthly_series')
            .map(TaskSeriesPoint.fromJson)
            .toList(),
        statusCounts: _rows(json, 'status_counts')
            .map((row) => AdminStatusCount(
                status: row['status'].toString(),
                count: analyticsCount(row['count'])))
            .toList(),
        categories: _rows(json, 'top_categories').map((row) {
          final percent = double.tryParse(row['percent']?.toString() ?? '');
          if (percent == null ||
              !percent.isFinite ||
              percent < 0 ||
              percent > 100) {
            throw const FormatException('Invalid category percentage');
          }
          return AdminCategoryStat(
              id: row['id'] == null ? null : analyticsCount(row['id']),
              name: row['name']?.toString(),
              count: analyticsCount(row['count']),
              percent: percent);
        }).toList(),
        recentTasks: _rows(json, 'recent_tasks')
            .map((row) => AdminRecentTask(
                  id: analyticsCount(row['id']),
                  title: row['title']?.toString() ?? '',
                  customerName: row['customer_name']?.toString(),
                  status: row['status'].toString(),
                  createdAt:
                      DateTime.tryParse(row['created_at']?.toString() ?? ''),
                  thumbnailUrl: row['primary_image_url']?.toString(),
                ))
            .toList(),
      );
}

List<Map<String, dynamic>> _rows(Map<String, dynamic> json, String key) {
  final rows = json[key];
  if (rows is! List || rows.any((row) => row is! Map)) {
    throw FormatException('Invalid analytics list: $key');
  }
  return rows.map((row) => Map<String, dynamic>.from(row as Map)).toList();
}

int analyticsCount(dynamic value) {
  final count = num.tryParse(value?.toString() ?? '');
  if (count == null || !count.isFinite || count < 0 || count % 1 != 0) {
    throw const FormatException('Invalid analytics count');
  }
  return count.toInt();
}
