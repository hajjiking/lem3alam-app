import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/application/client_dashboard_controller.dart';
import '../data/client_offers_repository.dart';
import '../domain/task.dart';
import 'tasks_controller.dart';

class ClientOffersPanel extends ConsumerWidget {
  const ClientOffersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isClient != true) return const SizedBox.shrink();
    final l10n = context.l10n;
    return ref.watch(clientOffersProvider).when(
          skipLoadingOnReload: false,
          skipLoadingOnRefresh: false,
          loading: () => AppSectionCard(
              title: l10n.clientOffersTitle,
              child: const Center(child: CircularProgressIndicator())),
          error: (_, __) => AppSectionCard(
              title: l10n.clientOffersTitle,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.clientOffersLoadError),
                    TextButton.icon(
                        onPressed: () => ref.invalidate(clientOffersProvider),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry)),
                  ])),
          data: (offers) => ClientOffersList(
              key: ValueKey('offers-${user!.id}'),
              offers: offers,
              dashboard: true),
        );
  }
}

class TaskOffersSection extends ConsumerWidget {
  const TaskOffersSection({super.key, required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isClient != true || user?.id != task.clientId) {
      return const SizedBox.shrink();
    }
    return ClientOffersList(
        key: ValueKey('task-offers-${user!.id}-${task.id}'),
        offers: task.offers.map((offer) => ClientOffer(task, offer)).toList());
  }
}

class ClientOffersList extends ConsumerStatefulWidget {
  const ClientOffersList(
      {super.key, required this.offers, this.dashboard = false});
  final List<ClientOffer> offers;
  final bool dashboard;

  @override
  ConsumerState<ClientOffersList> createState() => _ClientOffersListState();
}

class _ClientOffersListState extends ConsumerState<ClientOffersList> {
  bool _busy = false;
  bool _sending = false;

  Future<void> _decide(ClientOffer entry, bool accept) async {
    if (_busy) return;
    final userId = ref.read(authControllerProvider).user?.id;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                title: Text(accept ? l10n.accept : l10n.rejectOffer),
                content: Text(accept
                    ? l10n.confirmAcceptOffer(
                        entry.offer.taskerName, entry.task.title)
                    : l10n.confirmRejectOffer(entry.offer.taskerName)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(l10n.cancel)),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(accept ? l10n.accept : l10n.rejectOffer)),
                ],
              ));
      if (!mounted || confirmed != true) return;
      final current = ref.read(authControllerProvider).user;
      if (current?.id != userId || current?.isClient != true) return;
      setState(() => _sending = true);
      await ref
          .read(clientOffersRepositoryProvider)
          .decide(entry, accept: accept);
      if (!mounted) return;
      final after = ref.read(authControllerProvider).user;
      if (after?.id != userId || after?.isClient != true) return;
      ref.invalidate(clientOffersProvider);
      ref.invalidate(taskDetailProvider(entry.task.id));
      ref.invalidate(tasksListControllerProvider);
      ref.invalidate(clientDashboardProvider);
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(
            content: Text(accept ? l10n.offerAccepted : l10n.offerRejected)));
      }
    } catch (error) {
      if (!mounted || ref.read(authControllerProvider).user?.id != userId) {
        return;
      }
      final message = error is ApiException
          ? error.statusCode == 409
              ? l10n.offerNoLongerAvailable
              : localizeApiException(context, error)
          : l10n.errUnknown;
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
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
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).user;
    if (user?.isClient != true) return const SizedBox.shrink();
    final offers = widget.offers
        .where((entry) => entry.task.clientId == user!.id)
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
          widget.dashboard
              ? l10n.clientOffersWaiting(offers.length)
              : l10n.taskOffers,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(l10n.clientOffersSubtitle),
      const SizedBox(height: 12),
      if (offers.isEmpty) AppSectionCard(child: Text(l10n.clientOffersEmpty)),
      for (final entry in offers)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppSectionCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Row(children: [
                  const CircleAvatar(child: Icon(Icons.person_outline)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          entry.offer.taskerName.isEmpty
                              ? l10n.tasker
                              : entry.offer.taskerName,
                          style: Theme.of(context).textTheme.titleMedium)),
                  if (entry.offer.verified)
                    Tooltip(
                        message: l10n.verified,
                        child: Icon(Icons.verified,
                            color: Theme.of(context).colorScheme.primary)),
                ]),
                const SizedBox(height: 12),
                if (widget.dashboard)
                  Text(entry.task.title,
                      style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(entry.offer.proposal),
                const SizedBox(height: 12),
                Wrap(spacing: 16, runSpacing: 8, children: [
                  if (entry.offer.budget != null)
                    Text(l10n.dashboardPrice(
                        NumberFormat.decimalPattern(l10n.localeName)
                            .format(entry.offer.budget))),
                  if (entry.offer.duration.isNotEmpty)
                    Text('${l10n.estimatedDuration}: ${entry.offer.duration}'),
                  Text(switch (entry.offer.status) {
                    'pending' => l10n.dashboardStatusPending,
                    'accepted' => l10n.offerAccepted,
                    'rejected' => l10n.offerRejected,
                    _ => entry.offer.status,
                  }),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  if (entry.task.status == 'open' &&
                      entry.offer.status == 'pending') ...[
                    FilledButton(
                        onPressed: _busy ? null : () => _decide(entry, true),
                        child: Text(l10n.accept)),
                    OutlinedButton(
                        onPressed: _busy ? null : () => _decide(entry, false),
                        child: Text(l10n.rejectOffer)),
                  ],
                  if (widget.dashboard)
                    TextButton(
                        onPressed: _busy
                            ? null
                            : () => context.goNamed(AppRouteNames.taskDetail,
                                pathParameters: {'id': '${entry.task.id}'}),
                        child: Text(l10n.taskDetails)),
                  if (entry.offer.taskerId > 0)
                    TextButton(
                        onPressed: _busy
                            ? null
                            : () => context.goNamed(AppRouteNames.taskerProfile,
                                    pathParameters: {
                                      'id': '${entry.offer.taskerId}'
                                    }),
                        child: Text(l10n.viewProfile)),
                ]),
              ])),
        ),
      if (_sending) const LinearProgressIndicator(),
    ]);
  }
}
