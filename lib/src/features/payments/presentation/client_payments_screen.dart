import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/money_overview_chart.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_actions.dart';
import '../../dashboard/presentation/widgets/dashboard_header.dart';
import '../../admin/presentation/widgets/tasks_status_donut.dart';
import '../../earnings/domain/earnings_models.dart';
import '../../earnings/presentation/earnings_format.dart';
import '../application/client_payments_controller.dart';
import '../domain/client_payments.dart';

class ClientPaymentsScreen extends ConsumerWidget {
  const ClientPaymentsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isClient != true) return const SizedBox.shrink();
    final l = context.l10n;
    Future<void> refresh() async {
      ref.invalidate(clientPaymentsControllerProvider);
      try {
        await ref.read(clientPaymentsControllerProvider.future);
      } catch (_) {}
    }

    return RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: DashboardHeader(
                      appName: l.appName,
                      greeting: l.paymentsTitle,
                      subtitle: l.paymentsSubtitle,
                      availabilityLabel: '',
                      isOnline: false,
                      showAvailability: false,
                      compact: true,
                      avatarAsset: null,
                      titleActions: const PaymentsPeriodSelector(),
                      menuLabel: l.dashboardMenu,
                      notificationsLabel: l.dashboardNotifications,
                      profileLabel: l.dashboardProfile,
                      onMenuTap: () => showDashboardMenu(context, ref),
                      onNotificationsTap: () => showDashboardFeatureNotice(
                          context, l.dashboardNotifications),
                      onProfileTap: () =>
                          openDashboardProfile(context, user?.id, false),
                      onAvailabilityTap: () {})),
              SliverToBoxAdapter(
                  child: ref.watch(clientPaymentsControllerProvider).when(
                      skipLoadingOnRefresh: false,
                      skipLoadingOnReload: false,
                      loading: () => const Padding(
                          padding: EdgeInsets.all(60),
                          child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(children: [
                            Text(l.paymentsLoadError),
                            TextButton(onPressed: refresh, child: Text(l.retry))
                          ])),
                      data: (view) => Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1160),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 24),
                                  child: PaymentsContent(view: view))))))
            ]));
  }
}

class PaymentsPeriodSelector extends ConsumerWidget {
  const PaymentsPeriodSelector({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      DropdownButtonFormField<EarningsPeriod>(
          key: ValueKey(ref.watch(clientPaymentsPeriodProvider)),
          value: ref.watch(clientPaymentsPeriodProvider),
          isExpanded: true,
          decoration: InputDecoration(
              labelText: context.l10n.paymentsPeriod,
              prefixIcon: const Icon(Icons.calendar_month_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface),
          items: [
            for (final p in EarningsPeriod.values)
              DropdownMenuItem(
                  value: p,
                  child: Text(
                      switch (p) {
                        EarningsPeriod.thisMonth =>
                          context.l10n.dashboardThisMonth,
                        EarningsPeriod.lastMonth =>
                          context.l10n.earningsLastMonth,
                        EarningsPeriod.thisYear =>
                          context.l10n.earningsThisYear,
                      },
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis))
          ],
          onChanged: (p) {
            if (p != null) {
              ref.read(clientPaymentsPeriodProvider.notifier).select(p);
            }
          });
}

void _unavailable(BuildContext context) {
  showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
              scrollable: true,
              title: Text(c.l10n.paymentsUnavailable),
              content: Text(c.l10n.paymentsUnsupported),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(c.l10n.close))
              ]));
}

class PaymentsContent extends StatelessWidget {
  const PaymentsContent({super.key, required this.view});
  final ClientPaymentsView view;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final colors = [
      theme.colorScheme.primary,
      tokens.success,
      tokens.accentPurple,
      tokens.warning
    ];
    String count(int n) => NumberFormat.decimalPattern(l.localeName).format(n);
    String money(int n) => earningsMoney(context, n, view.currency);
    Widget metric(String label, String value, IconData icon, Color color,
            {String? note, Widget? action}) =>
        Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                  backgroundColor: color.withValues(alpha: .1),
                  child: Icon(icon, color: color)),
              const SizedBox(height: 12),
              Text(label),
              const SizedBox(height: 8),
              Text(value,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              if (note != null)
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(note, style: theme.textTheme.bodySmall)),
              if (action != null)
                Padding(padding: const EdgeInsets.only(top: 10), child: action),
            ]));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Card(
          child: _ResponsiveMetrics(children: [
        metric(l.paymentsWallet, '—', Icons.account_balance_wallet_outlined,
            colors[0],
            note: l.paymentsUnavailable,
            action: FilledButton.icon(
                onPressed: () => _unavailable(context),
                icon: const Icon(Icons.add),
                label: Text(l.paymentsAddFunds))),
        metric(l.paymentsSpent, money(view.totalSpent), Icons.payments_outlined,
            theme.colorScheme.error),
        metric(l.paymentsRefunds, '—', Icons.undo, tokens.success,
            note: l.paymentsUnavailable),
        metric(l.paymentsBudget, '—', Icons.savings_outlined, colors[0],
            note: l.paymentsUnavailable),
      ])),
      const SizedBox(height: 12),
      _ResponsiveMetrics(children: [
        Card(
            child: metric(l.paymentsPosted, count(view.posted),
                Icons.event_note, colors[0],
                note: l.earningsAllTime)),
        Card(
            child: metric(l.paymentsCompleted, count(view.completed),
                Icons.check, tokens.success,
                note: l.earningsCompletedChange(
                    '${view.completed >= view.previousCompleted ? '+' : ''}${count(view.completed - view.previousCompleted)}'))),
        Card(
            child: metric(l.paymentsActive, count(view.active), Icons.schedule,
                tokens.warning,
                note: l.earningsActiveNow)),
        Card(
            child: metric(l.paymentsSpent, money(view.allTimeSpent),
                Icons.receipt_long, tokens.accentPurple,
                note: l.earningsAllTime)),
      ]),
      const SizedBox(height: 12),
      MoneyOverviewChart(
          points: view.points,
          total: view.totalSpent,
          currency: view.currency,
          title: l.paymentsOverview,
          subtitle: l.paymentsCumulative,
          emptyLabel: l.earningsEmpty,
          periodSelector: const PaymentsPeriodSelector(),
          monthly: view.period == EarningsPeriod.thisYear),
      const SizedBox(height: 12),
      TasksStatusDonut(
          title: l.paymentsCategory,
          totalLabel: l.paymentsSpent,
          totalValue: money(view.totalSpent),
          items: [
            for (var i = 0; i < view.categories.length; i++)
              AdminStatusLegendData(
                  label: view.categories[i].name ?? l.earningsUncategorized,
                  value: money(view.categories[i].amount),
                  percentLabel: '${count(view.categories[i].percent)}%',
                  color: colors[i % colors.length],
                  chartValue: view.categories[i].amount.toDouble()),
          ]),
      Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(height: 8),
                    Text(l.paymentsFundTitle,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(l.paymentsUnsupported),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                        onPressed: () => _unavailable(context),
                        icon: const Icon(Icons.add),
                        label: Text(l.paymentsAddFunds)),
                  ]))),
      _PaymentsHistory(view: view),
      Card(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.paymentsMethods, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(l.paymentsNoCards),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: () => _unavailable(context),
                        icon: const Icon(Icons.add_card_outlined),
                        label: Text(l.paymentsAddCard)),
                  ]))),
      if (view.undated > 0)
        Padding(
            padding: const EdgeInsets.all(12), child: Text(l.paymentsUndated)),
      Padding(
          padding: const EdgeInsets.all(12),
          child:
              Text(l.paymentsRefundNotice, style: theme.textTheme.bodySmall)),
      Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l.paymentsPrivate, style: theme.textTheme.bodySmall)),
    ]);
  }
}

class _ResponsiveMetrics extends StatelessWidget {
  const _ResponsiveMetrics({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns = c.maxWidth >= 900 * scale
            ? 4
            : c.maxWidth >= 320 * scale
                ? 2
                : 1;
        return Wrap(children: [
          for (final child in children)
            SizedBox(width: c.maxWidth / columns, child: child)
        ]);
      });
}

class _PaymentsHistory extends StatelessWidget {
  const _PaymentsHistory({required this.view});
  final ClientPaymentsView view;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(context.l10n.paymentsRecent,
                      style: Theme.of(context).textTheme.titleLarge),
                  if (view.records.length > 5)
                    TextButton(
                        onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (c) => SizedBox(
                                height: MediaQuery.sizeOf(c).height * .8,
                                child: Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(children: [
                                        Expanded(
                                            child: Text(c.l10n.paymentsAll,
                                                style: Theme.of(c)
                                                    .textTheme
                                                    .titleLarge)),
                                        IconButton(
                                            onPressed: () => Navigator.pop(c),
                                            tooltip: c.l10n.close,
                                            icon: const Icon(Icons.close)),
                                      ])),
                                  Expanded(
                                      child: ListView.builder(
                                          itemCount: view.records.length,
                                          itemBuilder: (_, i) => PaymentRow(
                                              payment: view.records[i])))
                                ]))),
                        child: Text(context.l10n.dashboardViewAll)),
                ]),
            if (view.records.isEmpty)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(context.l10n.paymentsEmpty)),
            for (final p in view.records.take(5)) PaymentRow(payment: p),
          ])));
}

class PaymentRow extends StatelessWidget {
  const PaymentRow({super.key, required this.payment});
  final ClientPayment payment;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = payment;
    final theme = Theme.of(context);
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final color = switch (p.status) {
      'completed' => tokens.success,
      'failed' => theme.colorScheme.error,
      _ => tokens.warning
    };
    final status = switch (p.status) {
      'completed' => l.paymentsPaid,
      'pending' => l.paymentsPending,
      'failed' => l.paymentsFailed,
      'refunded' => l.paymentsRefunded,
      _ => l.paymentsDisputed
    };
    final date =
        '${p.isPaid ? l.paymentsPaidDate : l.paymentsCreatedDate} ${DateFormat.yMMMd(l.localeName).format(p.date)}';
    return InkWell(
        onTap: () => showDialog<void>(
            context: context,
            builder: (c) => AlertDialog(
                    scrollable: true,
                    title: Text(p.title),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status),
                          const SizedBox(height: 8),
                          Text(date),
                          const SizedBox(height: 8),
                          Text(p.status == 'refunded'
                              ? l.paymentsOriginal
                              : l.paymentsAmount),
                          EarningsMoney(p.amount, currency: 'MAD'),
                        ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: Text(l.close))
                    ])),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: .12),
                  child: Icon(
                      switch (p.status) {
                        'completed' => Icons.check,
                        'failed' => Icons.error_outline,
                        'refunded' => Icons.undo,
                        'disputed' => Icons.report_outlined,
                        _ => Icons.schedule,
                      },
                      size: 20,
                      color: color)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(p.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(date, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(status, style: TextStyle(color: color)),
                          EarningsMoney(p.isPaid ? -p.amount : p.amount,
                              currency: 'MAD',
                              style: TextStyle(
                                  color: p.isPaid
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurface)),
                        ]),
                    if (p.status == 'refunded')
                      Text(l.paymentsOriginal,
                          style: theme.textTheme.bodySmall),
                  ])),
              const Icon(Icons.chevron_right, size: 20),
            ])));
  }
}
