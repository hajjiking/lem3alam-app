import '../../../core/domain/money_chart_point.dart';
import '../../earnings/domain/fee_calculator.dart';
import '../../earnings/domain/earnings_models.dart' show EarningsPeriod;

class ClientPayment {
  ClientPayment.fromJson(Map<String, dynamic> json)
      : id = (json['id'] as num).toInt(),
        payerId = (json['payer_id'] as num).toInt(),
        taskId = (json['task_id'] as num).toInt(),
        title = json['task_title'] as String,
        categoryId = (json['category_id'] as num?)?.toInt(),
        categoryName = json['category_name'] as String?,
        amount = FeeCalculator.minorUnits(json['amount'] as Object),
        status = json['status'] as String,
        method = json['method'] as String,
        date = DateTime.parse(json['date'] as String),
        dateType = json['date_type'] as String {
    if (json['currency'] != 'MAD' ||
        !['completed', 'pending', 'failed', 'refunded', 'disputed']
            .contains(status) ||
        dateType != (status == 'completed' ? 'paid' : 'created') ||
        amount < 0) {
      throw const FormatException('Invalid payment');
    }
  }
  final int id, payerId, taskId, amount;
  final int? categoryId;
  final String title, status, method, dateType;
  final String? categoryName;
  final DateTime date;
  bool get isPaid => status == 'completed';
}

class SpendingCategory {
  SpendingCategory(this.name, this.amount, this.percent);
  final String? name;
  final int amount;
  int percent;
}

class ClientPaymentsView {
  ClientPaymentsView(Map<String, dynamic> data, this.records)
      : clientId = (data['client_id'] as num).toInt(),
        currency = data['currency'] as String,
        period = EarningsPeriod.values
            .firstWhere((p) => p.apiValue == data['period']),
        start = DateTime.parse(data['start_date'] as String),
        end = DateTime.parse(data['end_date'] as String),
        posted = (data['stats']['tasks_posted'] as num).toInt(),
        completed = (data['stats']['completed_tasks'] as num).toInt(),
        previousCompleted =
            (data['stats']['previous_completed_tasks'] as num).toInt(),
        active = (data['stats']['in_progress'] as num).toInt(),
        undated = (data['stats']['undated_completed_count'] as num).toInt(),
        allTimeSpent = FeeCalculator.minorUnits(
            data['stats']['total_spent_all_time'] as Object) {
    final grouped = <int?, (String?, int)>{};
    final daily = <String, int>{};
    for (final record in records) {
      if (record.payerId != clientId ||
          record.date.isBefore(start) ||
          record.date.isAfter(end)) {
        throw const FormatException('Payment outside client/period scope');
      }
      if (!record.isPaid) continue;
      totalSpent += record.amount;
      final old = grouped[record.categoryId];
      grouped[record.categoryId] =
          (record.categoryName, (old?.$2 ?? 0) + record.amount);
      final key =
          '${record.date.year}-${record.date.month}-${period == EarningsPeriod.thisYear ? 1 : record.date.day}';
      daily[key] = (daily[key] ?? 0) + record.amount;
    }
    final groups = grouped.values.toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    categories = [
      for (final g in groups)
        SpendingCategory(
            g.$1, g.$2, totalSpent == 0 ? 0 : g.$2 * 100 ~/ totalSpent)
    ];
    if (totalSpent > 0) {
      final order = List.generate(categories.length, (i) => i)
        ..sort((a, b) => (categories[b].amount * 100 % totalSpent)
            .compareTo(categories[a].amount * 100 % totalSpent));
      final missing = 100 - categories.fold(0, (n, c) => n + c.percent);
      for (var i = 0; i < missing; i++) {
        categories[order[i]].percent++;
      }
    }
    var running = 0;
    for (var date = start;
        !date.isAfter(end);
        date = period == EarningsPeriod.thisYear
            ? DateTime(date.year, date.month + 1)
            : DateTime(date.year, date.month, date.day + 1)) {
      running += daily['${date.year}-${date.month}-${date.day}'] ?? 0;
      points.add(MoneyChartPoint(date, running));
    }
    records.sort((a, b) => b.date.compareTo(a.date));
  }
  final int clientId,
      posted,
      completed,
      previousCompleted,
      active,
      undated,
      allTimeSpent;
  final String currency;
  final EarningsPeriod period;
  final DateTime start, end;
  final List<ClientPayment> records;
  int totalSpent = 0;
  late final List<SpendingCategory> categories;
  final points = <MoneyChartPoint>[];
}
