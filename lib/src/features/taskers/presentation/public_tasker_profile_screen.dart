import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/public_profile_model.dart';
import 'areas_of_expertise_card.dart';
import 'my_work_card.dart';
import 'public_profile_app_bar.dart';
import 'public_profile_identity_block.dart';
import 'sticky_call_message_bar.dart';
import 'tasker_public_profile_controller.dart';
import 'verification_rows.dart';
import 'widgets/review_card.dart';
import 'widgets/statistic_card.dart';

class PublicTaskerProfileScreen extends ConsumerWidget {
  const PublicTaskerProfileScreen({super.key, required this.taskerId});
  final int taskerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(publicTaskerProfileProvider(taskerId));
    return profile.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.publicProfileTitle)),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsets.all(24),
                child: Text(error.toString(), textAlign: TextAlign.center)),
            FilledButton(
              onPressed: () =>
                  ref.invalidate(publicTaskerProfileProvider(taskerId)),
              child: Text(context.l10n.retry),
            ),
          ]),
        ),
      ),
      data: (data) => _LoadedProfile(profile: data),
    );
  }
}

class _LoadedProfile extends ConsumerWidget {
  const _LoadedProfile({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(publicTaskerProfileControllerProvider);
    final controller = ref.read(publicTaskerProfileControllerProvider.notifier);
    final saved = controller.isSaved(profile.id,
        initialValue: profile.isSavedByCurrentClient);

    void openConversation() {
      final peerId = controller.conversationPeerId(profile.id);
      final user = ref.read(authControllerProvider).user;
      if (user == null) {
        context.pushNamed(AppRouteNames.login);
      } else if (user.isClient) {
        context.pushNamed(AppRouteNames.messageThread,
            pathParameters: {'peerId': '$peerId'});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.messagesNoThread)));
      }
    }

    Future<void> call() async {
      final phone = profile.phone?.trim() ?? '';
      if (phone.isNotEmpty) {
        await launchUrl(Uri(scheme: 'tel', path: phone));
      }
    }

    final colors = Theme.of(context).colorScheme;
    final tokens = context.appTokens;
    final workImages = <String>{
      ...profile.portfolioImageUrls,
      ...profile.portfolio
          .map((item) => item.imagePath)
          .where((path) => path.startsWith('http')),
    }.toList(growable: false);
    return Scaffold(
      backgroundColor: colors.surface,
      // No app bottom navigation is rendered here: this pushed route lives in
      // the client's shell, whose persistent navigation remains underneath.
      bottomNavigationBar: StickyCallMessageBar(
        onCall: (profile.phone?.trim().isNotEmpty ?? false) ? call : null,
        // Header Message and sticky Send Message share this handler.
        onMessage: openConversation,
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [tokens.headerStart, tokens.headerEnd],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(children: [
                PublicProfileAppBar(
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(AppRouteNames.dashboard);
                    }
                  },
                  onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.profileShare))),
                ),
                _Constrained(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: PublicProfileIdentityBlock(
                      profile: profile,
                      saved: saved,
                      onMessage: openConversation,
                      onToggleSaved: () => controller.toggleSaved(profile.id,
                          initialValue: profile.isSavedByCurrentClient),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          sliver: SliverToBoxAdapter(
            child: _Constrained(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Stats(profile: profile),
                  const SizedBox(height: 14),
                  _About(profile: profile),
                  const SizedBox(height: 14),
                  _Skills(profile: profile),
                  if (profile.expertiseItems.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    AreasOfExpertiseCard(items: profile.expertiseItems),
                  ],
                  if (workImages.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    MyWorkCard(imageUrls: workImages),
                  ],
                  const SizedBox(height: 14),
                  _Reviews(profile: profile),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Constrained extends StatelessWidget {
  const _Constrained({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080), child: child),
      );
}

class _Stats extends StatelessWidget {
  const _Stats({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final number = NumberFormat.decimalPattern(l.localeName);
    final positive = Theme.of(context).colorScheme.tertiary;
    Color deltaColor(int value) =>
        value >= 0 ? positive : Theme.of(context).colorScheme.error;
    String delta(int value) => l.publicProfileThisMonth(
        '${value >= 0 ? '+' : ''}${number.format(value)}');
    return StatisticCard(
      centered: true,
      columns: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
      items: [
        StatisticItem(
            icon: Icons.calendar_month_outlined,
            value: number.format(profile.jobsCompleted ?? 0),
            label: l.profileJobsCompleted,
            caption: delta(profile.jobsCompletedThisMonth),
            captionColor: deltaColor(profile.jobsCompletedThisMonth)),
        StatisticItem(
            icon: Icons.schedule_outlined,
            value: number.format(profile.jobsInProgress),
            label: l.profileJobsInProgress,
            caption: delta(profile.jobsInProgressThisMonth),
            captionColor: deltaColor(profile.jobsInProgressThisMonth)),
        StatisticItem(
            icon: Icons.emoji_events_outlined,
            value: '${number.format(profile.successRate)}%',
            label: l.profileSuccessRate,
            caption: _tier(context, profile.successRate),
            captionColor: positive,
            accent: context.appTokens.accentPurple),
        StatisticItem(
            icon: Icons.star_border_rounded,
            value: profile.rating.toStringAsFixed(1),
            label: l.publicProfileAverageRating,
            caption:
                l.profileBadgeReviewCaption(number.format(profile.reviewCount)),
            captionColor: Theme.of(context).colorScheme.primary,
            accent: context.appTokens.accentPurple),
      ],
    );
  }

  String _tier(BuildContext context, int percentage) {
    final l = context.l10n;
    if (percentage >= 95) return l.publicProfileExcellent;
    if (percentage >= 85) return l.publicProfileGreat;
    if (percentage >= 70) return l.publicProfileGood;
    return l.publicProfileNeedsImprovement;
  }
}

class _About extends StatelessWidget {
  const _About({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    VerificationRowData row(IconData icon, String label, bool verified) =>
        VerificationRowData(
            icon: icon,
            label: label,
            value: verified ? l.publicProfileVerified : l.profileNotRecorded,
            verified: verified);
    final rows = [
      row(Icons.verified_user_outlined, l.profileIdVerified,
          profile.isVerified),
      row(Icons.mark_email_read_outlined, l.publicProfileEmailVerified,
          profile.emailVerified),
      row(Icons.phone_outlined, l.publicProfilePhoneVerified,
          profile.phoneVerified),
    ];
    final bio = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.profileAboutMe, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      Text((profile.bio ?? '').trim().isEmpty ? l.profileNoBio : profile.bio!),
    ]);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 620) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  bio,
                  const Divider(height: 34),
                  VerificationRows(rows: rows),
                ]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: bio),
            const SizedBox(width: 24),
            SizedBox(
                height: 170,
                child: VerticalDivider(
                    color: Theme.of(context).colorScheme.outlineVariant)),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: VerificationRows(rows: rows)),
          ]);
        }),
      ),
    );
  }
}

class _Skills extends StatelessWidget {
  const _Skills({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final accents = [
      Theme.of(context).colorScheme.primary,
      context.appTokens.warning,
      Theme.of(context).colorScheme.tertiary,
      context.appTokens.accentPurple,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: Text(l.profileSkillsExpertise,
                    style: Theme.of(context).textTheme.titleLarge)),
            TextButton(onPressed: () {}, child: Text(l.publicProfileViewAll)),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (var index = 0; index < profile.features.length; index++)
              Chip(
                avatar: Icon(_skillIcon(profile.features[index]),
                    size: 18, color: accents[index % accents.length]),
                label: Text(profile.features[index]),
                backgroundColor:
                    accents[index % accents.length].withValues(alpha: .08),
              ),
            if (profile.additionalSkillCount > 0)
              ActionChip(
                onPressed: () {},
                label: Text(l.profileMoreSkills(profile.additionalSkillCount)),
              ),
          ]),
        ]),
      ),
    );
  }

  IconData _skillIcon(String value) {
    final name = value.toLowerCase();
    if (name.contains('plumb')) return Icons.water_drop;
    if (name.contains('electric')) return Icons.bolt;
    if (name.contains('paint')) return Icons.format_paint;
    if (name.contains('carpent')) return Icons.carpenter;
    if (name.contains('tile')) return Icons.grid_view;
    if (name.contains('furniture')) return Icons.chair;
    return Icons.handyman_outlined;
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: Text(
                    l.profileReviewsTitle(profile.reviewCount.toString()),
                    style: Theme.of(context).textTheme.titleLarge)),
            TextButton(
              onPressed: () => context.pushNamed(AppRouteNames.taskerReviews,
                  pathParameters: {'id': '${profile.id}'}),
              child: Text(l.publicProfileViewAll),
            ),
          ]),
          if (profile.reviews.isEmpty)
            Text(l.noReviewsYet)
          else
            for (final review in profile.reviews.take(2)) ...[
              const SizedBox(height: 10),
              ReviewCard(
                  reviewerName: review.reviewerName,
                  reviewerAvatar: review.reviewerAvatar,
                  rating: review.rating,
                  comment: review.comment,
                  dateLabel: review.dateLabel,
                  verifiedCustomer: review.verifiedCustomer,
                  taskTitle: review.taskTitle),
            ],
        ]),
      ),
    );
  }
}
