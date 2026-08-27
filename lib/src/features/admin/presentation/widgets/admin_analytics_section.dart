import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/app_widgets.dart';
import '../../../../routing/app_router.dart';
import '../../../tasks/presentation/task_image_support.dart';
import '../../../tasks/presentation/task_style.dart';
import '../../../tasks/presentation/tasks_controller.dart';
import '../../domain/admin_dashboard_models.dart';
import '../admin_dashboard_controller.dart';
import 'recent_tasks_card.dart';
import 'tasks_overview_chart.dart';
import 'tasks_status_donut.dart';
import 'top_categories_card.dart';

class AdminAnalyticsSection extends ConsumerWidget {
  const AdminAnalyticsSection(
      {super.key, required this.data, required this.onTasksTap});
  final AdminDashboardAnalytics data;
  final VoidCallback onTasksTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final numbers = NumberFormat.decimalPattern(l10n.localeName);
    final percent = NumberFormat.percentPattern(l10n.localeName)
      ..maximumFractionDigits = 1;
    final range = ref.watch(adminDashboardRangeProvider);
    final points = range == AdminDashboardRange.week
        ? data.weeklySeries
        : data.monthlySeries;
    final colors = [
      context.appColors.primary,
      context.appTokens.success,
      context.appTokens.warning,
      context.appTokens.info,
      context.appTokens.accentPurple
    ];
    final labels = points.length <= 7
        ? points
            .map((point) => DateFormat.Md(l10n.localeName).format(point.date))
            .toList()
        : List.generate(
            6,
            (index) => DateFormat.Md(l10n.localeName).format(
                points[(index * (points.length - 1) / 5).round()].date));

    String statusLabel(String status) => switch (status) {
          'open' => l10n.statusOpen,
          'assigned' => l10n.statusAssigned,
          'in_progress' => l10n.statusInProgress,
          'completed' => l10n.statusCompleted,
          'cancelled' => l10n.statusCancelled,
          _ => status,
        };

    void openTasks([int? categoryId]) {
      ref.read(selectedCategoryIdProvider.notifier).set(categoryId);
      ref.invalidate(tasksListControllerProvider);
      onTasksTap();
    }

    final statusCard = TasksStatusDonut(
      title: l10n.adminTasksByStatus,
      totalLabel: l10n.adminTotal,
      totalValue: numbers.format(data.totalTasks),
      items: data.statusCounts
          .map((item) => AdminStatusLegendData(
                label: statusLabel(item.status),
                value: numbers.format(item.count),
                percentLabel: percent.format(
                    data.totalTasks == 0 ? 0 : item.count / data.totalTasks),
                chartValue: item.count.toDouble(),
                color: item.status == 'assigned'
                    ? context.appTokens.info
                    : taskStatusColor(context, item.status),
              ))
          .toList(),
    );
    final categoryCard = data.categories.isEmpty
        ? AppSectionCard(
            title: l10n.adminTopCategories,
            child: Text(l10n.adminNoCategoryActivity))
        : AdminTopCategoriesCard(
            title: l10n.adminTopCategories,
            viewAllLabel: l10n.dashboardViewAll,
            items: [
              for (var index = 0; index < data.categories.length; index++)
                AdminCategoryViewData(
                    label:
                        data.categories[index].name ?? l10n.adminUnknownValue,
                    count: numbers.format(data.categories[index].count),
                    percent:
                        percent.format(data.categories[index].percent / 100),
                    icon: Icons.home_repair_service_outlined,
                    accent: colors[index % colors.length])
            ],
            onViewAll: () => openTasks(),
            onCategoryTap: (index) => openTasks(data.categories[index].id),
          );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TasksOverviewChart(
        title: l10n.adminTasksOverview,
        rangeLabel: range == AdminDashboardRange.week
            ? l10n.adminLast7Days
            : l10n.adminLast30Days,
        points: points,
        dayLabels: labels,
        legendItems: [
          AdminChartLegendItem(label: l10n.adminPosted, color: colors[0]),
          AdminChartLegendItem(label: l10n.adminStarted, color: colors[2]),
          AdminChartLegendItem(label: l10n.statusCompleted, color: colors[1]),
        ],
        onRangeTap: () async {
          final selected = await showModalBottomSheet<AdminDashboardRange>(
              context: context,
              showDragHandle: true,
              useSafeArea: true,
              builder: (context) =>
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final value in AdminDashboardRange.values)
                      ListTile(
                          title: Text(value == AdminDashboardRange.week
                              ? l10n.adminLast7Days
                              : l10n.adminLast30Days),
                          selected: value == range,
                          onTap: () => Navigator.of(context).pop(value)),
                  ]));
          if (selected != null && context.mounted) {
            ref.read(adminDashboardRangeProvider.notifier).select(selected);
          }
        },
      ),
      Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 0),
          child: Text(l10n.adminAnalyticsDates(data.timezone),
              style: Theme.of(context).textTheme.bodySmall)),
      if (points.every(
          (point) => point.posted + point.started + point.completed == 0))
        Padding(
            padding: const EdgeInsets.all(12),
            child: Text(l10n.adminNoPeriodActivity)),
      ExpansionTile(
          key: const PageStorageKey('admin-analytics-chart-data'),
          title: Text(l10n.adminChartData),
          children: [
            for (final point in points)
              ListTile(
                  title: Text(
                      DateFormat.yMMMd(l10n.localeName).format(point.date)),
                  subtitle: Text(
                      '${l10n.adminPosted}: ${numbers.format(point.posted)} · ${l10n.adminStarted}: ${numbers.format(point.started)} · ${l10n.statusCompleted}: ${numbers.format(point.completed)}')),
          ]),
      const SizedBox(height: 20),
      LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 800
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: statusCard),
                  const SizedBox(width: 16),
                  Expanded(child: categoryCard)
                ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      statusCard,
                      const SizedBox(height: 20),
                      categoryCard
                    ])),
      const SizedBox(height: 20),
      if (data.recentTasks.isEmpty)
        AppSectionCard(
            title: l10n.dashboardRecentTasks,
            child: Text(l10n.adminNoRecentActivity))
      else
        AdminRecentTasksCard(
          title: l10n.dashboardRecentTasks,
          viewAllLabel: l10n.dashboardViewAll,
          viewAllTasksLabel: l10n.adminViewAllTasks,
          items: data.recentTasks
              .map((task) => AdminRecentTaskViewData(
                    title: task.title,
                    customerLabel: l10n.adminTaskBy(
                        task.customerName ?? l10n.adminUnknownValue),
                    statusLabel: statusLabel(task.status),
                    statusColor: taskStatusColor(context, task.status),
                    timeLabel: task.createdAt == null
                        ? l10n.clientDashboardUnknownTime
                        : DateFormat.MMMd(l10n.localeName)
                            .format(task.createdAt!.toLocal()),
                    thumbnailUrl: resolveTaskImageUrl(task.thumbnailUrl) ?? '',
                    fallbackIcon: Icons.handyman_outlined,
                  ))
              .toList(),
          onViewAll: () => openTasks(),
          onTaskTap: (index) => context.goNamed(AppRouteNames.taskDetail,
              pathParameters: {'id': data.recentTasks[index].id.toString()}),
        ),
    ]);
  }
}
