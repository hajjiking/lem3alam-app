import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/ui/app_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../application/earnings_controller.dart';
import '../data/cash_payments_repository.dart';
import '../domain/fee_calculator.dart';
import 'earnings_format.dart';

class CashPaymentsPanel extends ConsumerWidget {
  const CashPaymentsPanel({super.key, this.taskId});
  final int? taskId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isTasker != true) return const SizedBox.shrink();
    final l10n = context.l10n;
    return ref.watch(cashPaymentsProvider(taskId)).when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => AppSectionCard(
            title: l10n.cashPaymentsTitle,
            child: Column(children: [
              Text(l10n.cashPaymentsLoadError),
              TextButton(
                  onPressed: () => ref.invalidate(cashPaymentsProvider(taskId)),
                  child: Text(l10n.retry))
            ])),
        data: (payments) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final payment in payments)
                Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CashPaymentCard(
                        key: ValueKey('cash-${user!.id}-${payment.taskId}'),
                        payment: payment)),
            ]));
  }
}

class CashPaymentCard extends ConsumerStatefulWidget {
  const CashPaymentCard({super.key, required this.payment});
  final CashPayment payment;
  @override
  ConsumerState<CashPaymentCard> createState() => _CashPaymentCardState();
}

class _CashPaymentCardState extends ConsumerState<CashPaymentCard> {
  bool _busy = false;
  bool _sending = false;
  bool _resolved = false;
  void _refresh() {
    ref.invalidate(cashPaymentsProvider);
    ref.invalidate(earningsControllerProvider);
    ref.invalidate(dashboardControllerProvider);
    ref.invalidate(taskDetailProvider(widget.payment.taskId));
  }

  Future<void> _confirm() async {
    if (_busy || _resolved) return;
    final payment = widget.payment;
    final account = ref.read(authControllerProvider).user?.id;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.cashConfirm),
                  content: Text(l10n.cashConfirmBody(
                      earningsMoney(context,
                          FeeCalculator.minorUnits(payment.amount!), 'MAD'),
                      payment.title)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(l10n.cancel)),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(l10n.cashConfirm))
                  ]));
      if (!mounted ||
          confirmed != true ||
          ref.read(authControllerProvider).user?.id != account) {
        return;
      }
      setState(() => _sending = true);
      await ref.read(cashPaymentsRepositoryProvider).confirm(payment);
      if (!mounted || ref.read(authControllerProvider).user?.id != account) {
        return;
      }
      setState(() => _resolved = true);
      _refresh();
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.cashConfirmed)));
      }
    } catch (error) {
      if (!mounted || ref.read(authControllerProvider).user?.id != account) {
        return;
      }
      final stale = error is ApiException && error.statusCode == 409;
      if (stale) _refresh();
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(
            content: Text(stale
                ? l10n.cashPaymentChanged
                : error is ApiException
                    ? localizeApiException(context, error)
                    : l10n.errUnknown)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final payment = widget.payment;
    if (_resolved || user?.isTasker != true || user?.id != payment.taskerId) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return AppSectionCard(
        title: l10n.cashPaymentsTitle,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(payment.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(payment.canConfirm
              ? l10n.cashAwaitingReceipt
              : l10n.cashAmountReview),
          if (payment.amount != null)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: EarningsMoney(FeeCalculator.minorUnits(payment.amount!),
                    currency: 'MAD')),
          if (payment.canConfirm)
            FilledButton.icon(
                onPressed: _busy ? null : _confirm,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.payments_outlined),
                label: Text(l10n.cashConfirm)),
        ]));
  }
}
