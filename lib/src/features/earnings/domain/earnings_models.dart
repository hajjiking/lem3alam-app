import 'fee_calculator.dart';

enum EarningsPeriod {
  thisMonth('this_month'),
  lastMonth('last_month'),
  thisYear('this_year');

  const EarningsPeriod(this.apiValue);
  final String apiValue;
}

enum TransactionStatus { completed, inProgress }

class TransactionRecord {
  TransactionRecord.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        taskId = (json['task_id'] as num).toInt(),
        taskTitle = (json['task_title'] ?? '').toString(),
        categoryId = (json['category_id'] as num?)?.toInt(),
        categoryName = json['category_name']?.toString(),
        bucket = json['bucket'] as String,
        date = DateTime.parse(json['date'] as String),
        gross = FeeCalculator.minorUnits(json['gross_amount'] as Object),
        recordedFee = json['platform_fee'] == null
            ? null
            : FeeCalculator.minorUnits(json['platform_fee'] as Object),
        recordedNet = json['net_amount'] == null
            ? null
            : FeeCalculator.minorUnits(json['net_amount'] as Object),
        status = json['status'] == 'completed'
            ? TransactionStatus.completed
            : TransactionStatus.inProgress {
    if (!['completed', 'in_progress'].contains(json['status']) ||
        !['current', 'previous', 'estimate'].contains(bucket) ||
        (status == TransactionStatus.completed &&
            (recordedFee == null ||
                recordedNet == null ||
                bucket == 'estimate')) ||
        (status == TransactionStatus.inProgress && bucket != 'estimate')) {
      throw const FormatException('Invalid ledger record');
    }
  }
  final String id, taskTitle, bucket;
  final int taskId, gross;
  final int? categoryId, recordedFee, recordedNet;
  final String? categoryName;
  final DateTime date;
  final TransactionStatus status;
  FeeAmounts amounts(FeeCalculator calculator) => calculator.calculate(gross,
      recordedFeeMinor: recordedFee, recordedNetMinor: recordedNet);
}

class EarningsStat {
  EarningsStat.fromJson(Map<String, dynamic> json)
      : completedTasks = (json['completed_tasks'] as num).toInt(),
        previousCompletedTasks =
            (json['previous_completed_tasks'] as num).toInt(),
        inProgressCount = (json['in_progress_count'] as num).toInt(),
        totalJobsAllTime = (json['total_jobs_all_time'] as num).toInt(),
        completedJobsAllTime =
            (json['completed_jobs_all_time'] as num?)?.toInt() ??
                (json['total_jobs_all_time'] as num).toInt() -
                    (json['in_progress_count'] as num).toInt(),
        averageRating = num.tryParse('${json['average_rating']}')?.toDouble(),
        reviewCount = (json['review_count'] as num).toInt();
  final int completedTasks,
      previousCompletedTasks,
      inProgressCount,
      totalJobsAllTime,
      completedJobsAllTime,
      reviewCount;
  final double? averageRating;
}

class EarningsLedger {
  EarningsLedger.fromJson(Map<String, dynamic> json, this.records)
      : taskerId = (json['tasker_id'] as num).toInt(),
        currency = json['currency'] as String,
        period = EarningsPeriod.values
            .firstWhere((p) => p.apiValue == json['period']),
        start = DateTime.parse(json['start_date'] as String),
        end = DateTime.parse(json['end_date'] as String),
        asOf = DateTime.parse(json['as_of'] as String),
        estimateRate = double.parse('${json['estimate_fee_rate']}'),
        availableBalance = json['available_balance'] == null
            ? null
            : FeeCalculator.minorUnits(json['available_balance'] as Object),
        stats = EarningsStat.fromJson(json['stats'] as Map<String, dynamic>);
  final int taskerId;
  final String currency;
  final EarningsPeriod period;
  final DateTime start, end, asOf;
  final double estimateRate;
  final int? availableBalance;
  final EarningsStat stats;
  final List<TransactionRecord> records;
}

class EarningsChartPoint {
  const EarningsChartPoint(this.date, this.net);
  final DateTime date;
  final int net;
}

class CategoryEarning {
  const CategoryEarning(this.name, this.amounts, this.percent);
  final String? name;
  final FeeAmounts amounts;
  final int percent;
}

class EarningsView {
  EarningsView(this.ledger, this.calculator) {
    calculator.calculate(0); // Validate the rate even when the ledger is empty.
    final categories = <int?, (String?, FeeAmounts)>{};
    final daily = <String, int>{};
    var previous = const FeeAmounts(0, 0, 0);
    var current = const FeeAmounts(0, 0, 0);
    for (final record in ledger.records) {
      final amounts = record.amounts(calculator);
      if (record.bucket == 'previous') {
        previous += amounts;
        continue;
      }
      if (record.bucket == 'estimate') {
        transactions.add(record);
        continue;
      }
      if (record.date.isBefore(ledger.start) ||
          record.date.isAfter(ledger.end)) {
        throw const FormatException(
            'Payment falls outside its selected period');
      }
      current += amounts;
      transactions.add(record);
      final old = categories[record.categoryId];
      categories[record.categoryId] = (
        record.categoryName,
        (old?.$2 ?? const FeeAmounts(0, 0, 0)) + amounts
      );
      final key =
          '${record.date.year}-${record.date.month}-${ledger.period == EarningsPeriod.thisYear ? 1 : record.date.day}';
      daily[key] = (daily[key] ?? 0) + amounts.net;
    }
    summary = current;
    deltaPercent = previous.net == 0
        ? null
        : (current.net - previous.net) / previous.net * 100;
    transactions.sort((a, b) => b.date.compareTo(a.date));
    final groups = categories.values.toList()
      ..sort((a, b) => b.$2.net.compareTo(a.$2.net));
    final percentages = [
      for (final g in groups)
        current.net == 0 ? 0 : g.$2.net * 100 ~/ current.net
    ];
    // Largest remainder keeps percentages nonnegative and summing to 100.
    if (current.net > 0) {
      final order = List.generate(groups.length, (i) => i)
        ..sort((a, b) => (groups[b].$2.net * 100 % current.net)
            .compareTo(groups[a].$2.net * 100 % current.net));
      final missing = 100 - percentages.fold(0, (a, b) => a + b);
      for (var i = 0; i < missing; i++) {
        percentages[order[i]]++;
      }
    }
    categoryEarnings = [
      for (var i = 0; i < groups.length; i++)
        CategoryEarning(groups[i].$1, groups[i].$2, percentages[i])
    ];
    var cumulative = 0;
    for (var date = ledger.start;
        !date.isAfter(ledger.end);
        date = ledger.period == EarningsPeriod.thisYear
            ? DateTime(date.year, date.month + 1)
            : DateTime(date.year, date.month, date.day + 1)) {
      cumulative += daily['${date.year}-${date.month}-${date.day}'] ?? 0;
      points.add(EarningsChartPoint(date, cumulative));
    }
  }
  final EarningsLedger ledger;
  final FeeCalculator calculator;
  late final FeeAmounts summary;
  late final double? deltaPercent;
  late final List<CategoryEarning> categoryEarnings;
  final transactions = <TransactionRecord>[];
  final points = <EarningsChartPoint>[];
}
