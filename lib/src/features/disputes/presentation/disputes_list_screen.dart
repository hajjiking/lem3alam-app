import 'dispute_actions.dart';
import '../../auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/networking/api_exception.dart';
import '../data/disputes_repository.dart';

class DisputesListScreen extends ConsumerStatefulWidget {
  const DisputesListScreen({super.key});
  @override
  ConsumerState<DisputesListScreen> createState() => _DisputesListScreenState();
}

class _DisputesListScreenState extends ConsumerState<DisputesListScreen> {
  int page = 1;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final disputes = ref.watch(disputesPageProvider(page));
    return Scaffold(
      appBar: AppBar(
          title: Text(l.disputeView),
          leading: BackButton(
              onPressed: () => context.go(
                  ref.read(authControllerProvider).user?.isAdmin == true
                      ? '/admin'
                      : '/dashboard'))),
      body: disputes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(error is ApiException
                      ? localizeApiException(context, error)
                      : l.unableToLoad),
                  TextButton(
                      onPressed: () =>
                          ref.invalidate(disputesPageProvider(page)),
                      child: Text(l.retry)),
                ]))),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(disputesPageProvider(page));
            await ref.read(disputesPageProvider(page).future);
          },
          child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (data.items.isEmpty)
                  Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l.disputeEmpty, textAlign: TextAlign.center)),
                for (final dispute in data.items)
                  Card(
                      child: ExpansionTile(
                    title: Text(dispute.subject),
                    subtitle: Text(switch (dispute.status) {
                      'open' => l.disputeOpen,
                      'in_review' => l.disputeInReview,
                      'resolved' => l.disputeResolved,
                      'closed' => l.disputeClosed,
                      _ => dispute.status
                    }),
                    childrenPadding: const EdgeInsets.all(16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dispute.description),
                      DisputeActions(
                          dispute: dispute,
                          onUpdated: () =>
                              ref.invalidate(disputesPageProvider(page))),
                      if (dispute.additionalInfo.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(l.disputeNotes),
                        Text(dispute.additionalInfo)
                      ]
                    ],
                  )),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed:
                              page > 1 ? () => setState(() => page--) : null,
                          child: Text(l.disputePreviousPage)),
                      TextButton(
                          onPressed: page < data.lastPage
                              ? () => setState(() => page++)
                              : null,
                          child: Text(l.disputeNextPage)),
                    ]),
              ]),
        ),
      ),
    );
  }
}
