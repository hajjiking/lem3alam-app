import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_actions.dart';
import '../../earnings/application/earnings_controller.dart';
import '../../earnings/domain/earnings_models.dart';
import '../../earnings/presentation/earnings_format.dart';
import '../../earnings/presentation/period_selector.dart';
import '../application/tasker_own_profile_controller.dart';
import '../domain/tasker_own_profile.dart';
import '../domain/tasker_profile.dart';
import '../domain/tasker_review.dart';

class TaskerOwnProfileScreen extends ConsumerWidget {
  const TaskerOwnProfileScreen({super.key, required this.taskerId});
  final int taskerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(taskerOwnProfileProvider(taskerId));
    final earnings = ref.watch(earningsControllerProvider);
    Future<void> refresh() async {
      ref.invalidate(taskerOwnProfileProvider(taskerId));
      ref.invalidate(earningsControllerProvider);
      try {
        await Future.wait([
          ref.read(taskerOwnProfileProvider(taskerId).future),
          ref.read(earningsControllerProvider.future),
        ]);
      } catch (_) {}
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _ProfileHeader(taskerId: taskerId)),
            SliverToBoxAdapter(
              child: profile.when(
                skipLoadingOnRefresh: false,
                skipLoadingOnReload: false,
                loading: () => const Padding(
                  padding: EdgeInsets.all(64),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => _LoadError(onRetry: refresh),
                data: (data) => earnings.when(
                  skipLoadingOnRefresh: false,
                  skipLoadingOnReload: false,
                  loading: () => const Padding(
                    padding: EdgeInsets.all(64),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => _LoadError(onRetry: refresh),
                  data: (view) => _ProfileContent(data: data, view: view),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Text(context.l10n.unableToLoad),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ]),
      );
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.taskerId});
  final int taskerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final foreground = theme.colorScheme.onPrimary;
    final data = ref.watch(taskerOwnProfileProvider(taskerId)).asData?.value;
    final p = data?.profile;
    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(AppRouteNames.dashboard);
      }
    }

    Future<void> menu() async {
      await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheet) => SafeArea(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: Text(l.profileShare),
                    onTap: () {
                      Navigator.pop(sheet);
                      showDashboardFeatureNotice(context, l.profileShare);
                    }),
                ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l.settings),
                    onTap: () {
                      Navigator.pop(sheet);
                      showDashboardFeatureNotice(context, l.settings);
                    }),
                ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(l.logout),
                    onTap: () async {
                      Navigator.pop(sheet);
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.goNamed(AppRouteNames.login);
                    }),
              ])));
    }

    return DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [tokens.headerStart, tokens.headerEnd])),
        child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                20, MediaQuery.paddingOf(context).top + 12, 20, 38),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            IconButton(
                                onPressed: back,
                                tooltip: MaterialLocalizations.of(context)
                                    .backButtonTooltip,
                                color: foreground,
                                icon: const Icon(Icons.arrow_back_rounded,
                                    size: 30)),
                            const SizedBox(width: 8),
                            Icon(Icons.home_work_rounded,
                                color: foreground, size: 38),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(l.appName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                            color: foreground,
                                            fontWeight: FontWeight.w900))),
                            IconButton(
                                onPressed: () => showDashboardFeatureNotice(
                                    context, l.profileNotification),
                                tooltip: l.profileNotification,
                                color: foreground,
                                icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    size: 30)),
                            IconButton(
                                onPressed: menu,
                                tooltip: MaterialLocalizations.of(context)
                                    .showMenuTooltip,
                                color: foreground,
                                icon: const Icon(Icons.more_vert_rounded)),
                          ]),
                          if (p != null) ...[
                            const SizedBox(height: 24),
                            LayoutBuilder(builder: (context, c) {
                              final identity =
                                  _Identity(profile: p, foreground: foreground);
                              final edit = OutlinedButton.icon(
                                  onPressed: () => _explainEdit(context),
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: foreground,
                                      side: BorderSide(
                                          color: foreground.withValues(
                                              alpha: .8))),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: Text(l.profileEdit));
                              if (c.maxWidth < 650) {
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      identity,
                                      const SizedBox(height: 18),
                                      Align(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: edit)
                                    ]);
                              }
                              return Row(children: [
                                Expanded(child: identity),
                                const SizedBox(width: 24),
                                edit
                              ]);
                            }),
                          ],
                        ])))));
  }
}

void _explainEdit(BuildContext context) => showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
            scrollable: true,
            title: Text(c.l10n.profileEdit),
            content: Text(c.l10n.profileEditUnavailable),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c), child: Text(c.l10n.close))
            ]));

class _Identity extends StatelessWidget {
  const _Identity({required this.profile, required this.foreground});
  final TaskerProfile profile;
  final Color foreground;
  @override
  Widget build(BuildContext context) {
    final title = profile.displayTitle(context.l10n.publicTaskerProfile);
    final location = [profile.city, profile.address]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
    return Wrap(
        spacing: 22,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _Avatar(path: profile.profileImage, online: profile.available),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(profile.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      color: foreground,
                                      fontWeight: FontWeight.w900)),
                          if (profile.isVerified)
                            Icon(Icons.verified_rounded, color: foreground),
                        ]),
                    const SizedBox(height: 5),
                    Text(title,
                        style: TextStyle(color: foreground, fontSize: 17)),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.location_on_outlined,
                            color: foreground, size: 20),
                        const SizedBox(width: 5),
                        Flexible(
                            child: Text(location,
                                style: TextStyle(color: foreground))),
                      ])
                    ],
                    const SizedBox(height: 8),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      for (var i = 1; i <= 5; i++)
                        Icon(
                            profile.averageRating >= i
                                ? Icons.star
                                : Icons.star_border,
                            color: Theme.of(context)
                                .extension<Lem3alamThemeTokens>()!
                                .warning,
                            size: 19),
                      const SizedBox(width: 8),
                      Text(
                          '${profile.averageRating.toStringAsFixed(1)} (${profile.totalReviews})',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: foreground, fontWeight: FontWeight.w700)),
                    ]),
                  ])),
        ]);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.path, required this.online});
  final String? path;
  final bool online;
  @override
  Widget build(BuildContext context) {
    final url = _imageUrl(path);
    return Stack(alignment: AlignmentDirectional.bottomEnd, children: [
      Container(
          width: 128,
          height: 128,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface),
          child: ClipOval(
              child: url == null
                  ? _avatarFallback(context)
                  : Image.network(url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(context)))),
      if (online)
        Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Theme.of(context).extension<Lem3alamThemeTokens>()!.success,
                border: Border.all(
                    color: Theme.of(context).colorScheme.surface, width: 3))),
    ]);
  }

  Widget _avatarFallback(BuildContext context) => ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person,
          size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant));
}

String? _imageUrl(String? path) {
  final p = path?.trim() ?? '';
  if (p.isEmpty) return null;
  if (p.startsWith('http://') || p.startsWith('https://')) return p;
  final api = Uri.parse(AppConfig.apiBaseUrl);
  final base = api
      .replace(path: api.path.replaceAll(RegExp(r'/api/v1/?$'), ''))
      .toString()
      .replaceAll(RegExp(r'/$'), '');
  return '$base/storage/${p.startsWith('/') ? p.substring(1) : p}';
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.data, required this.view});
  final TaskerOwnProfileData data;
  final EarningsView view;
  @override
  Widget build(BuildContext context) {
    final p = data.profile;
    final s = view.ledger.stats;
    final terminal = s.totalJobsAllTime - s.inProgressCount;
    final success = terminal <= 0
        ? null
        : (s.completedJobsAllTime * 100 / terminal).round().clamp(0, 100);
    return Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Transform.translate(
                          offset: const Offset(0, -20),
                          child: _Stats(view: view, success: success)),
                      _About(profile: p),
                      const SizedBox(height: 12),
                      _Skills(profile: p),
                      const SizedBox(height: 12),
                      _ProfileEarnings(view: view),
                      const SizedBox(height: 12),
                      _Reviews(profile: p, reviews: data.reviews),
                      const SizedBox(height: 12),
                      _RecentJobs(view: view),
                      const SizedBox(height: 12),
                      _Badges(stats: s, success: success),
                      Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(context.l10n.profilePrivate,
                              style: Theme.of(context).textTheme.bodySmall)),
                    ]))));
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.view, required this.success});
  final EarningsView view;
  final int? success;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        t = Theme.of(context),
        tokens = t.extension<Lem3alamThemeTokens>()!;
    final f = NumberFormat.decimalPattern(l.localeName), s = view.ledger.stats;
    final items = [
      (
        l.profileJobsCompleted,
        f.format(s.completedJobsAllTime),
        l.earningsCompletedChange('+${f.format(s.completedTasks)}'),
        Icons.work_outline,
        tokens.success
      ),
      (
        l.profileJobsInProgress,
        f.format(s.inProgressCount),
        l.earningsActiveNow,
        Icons.schedule,
        t.colorScheme.primary
      ),
      (
        l.earningsRating,
        s.averageRating?.toStringAsFixed(1) ?? '—',
        l.earningsReviewCount(f.format(s.reviewCount)),
        Icons.star,
        tokens.warning
      ),
      (
        l.profileSuccessRate,
        success == null ? '—' : '$success%',
        l.profileCompletionBasis,
        Icons.emoji_events_outlined,
        tokens.accentPurple
      ),
    ];
    return Card(child: LayoutBuilder(builder: (context, c) {
      final columns = c.maxWidth >= 800
          ? 4
          : c.maxWidth >= 320
              ? 2
              : 1;
      return Wrap(children: [
        for (final item in items)
          SizedBox(
              width: c.maxWidth / columns,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                            backgroundColor: item.$5.withValues(alpha: .12),
                            child: Icon(item.$4, color: item.$5)),
                        const SizedBox(height: 10),
                        Text(item.$2,
                            style: t.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        Text(item.$1),
                        const SizedBox(height: 5),
                        Text(item.$3,
                            style: t.textTheme.bodySmall
                                ?.copyWith(color: item.$5)),
                      ])))
      ]);
    }));
  }
}

class _About extends StatelessWidget {
  const _About({required this.profile});
  final TaskerProfile profile;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        tokens = Theme.of(context).extension<Lem3alamThemeTokens>()!;
    final member = profile.createdAt == null
        ? l.profileNotRecorded
        : DateFormat.yMMM(l.localeName).format(profile.createdAt!);
    final rows = [
      (
        Icons.verified_user_outlined,
        l.profileIdVerified,
        profile.isVerified ? l.verified : l.unverified,
        profile.isVerified
            ? tokens.success
            : Theme.of(context).colorScheme.onSurfaceVariant
      ),
      (
        Icons.badge_outlined,
        l.profileMemberSince,
        member,
        Theme.of(context).colorScheme.primary
      ),
      (
        Icons.schedule,
        l.profileResponseTime,
        l.profileNotRecorded,
        Theme.of(context).colorScheme.onSurfaceVariant
      ),
    ];
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(builder: (context, c) {
              final bio = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.profileAboutMe,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text((profile.bio ?? '').trim().isEmpty
                        ? l.profileNoBio
                        : profile.bio!),
                  ]);
              final info = Column(children: [
                for (final row in rows)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(children: [
                        Icon(row.$1, color: row.$4),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(row.$2,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(row.$3, style: TextStyle(color: row.$4))
                            ])),
                      ]))
              ]);
              if (c.maxWidth < 650) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [bio, const Divider(height: 30), info]);
              }
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: bio),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: info)
                  ]);
            })));
  }
}

class _Skills extends StatelessWidget {
  const _Skills({required this.profile});
  final TaskerProfile profile;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        skills = profile.skills,
        visible = skills.take(5).toList();
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).extension<Lem3alamThemeTokens>()!.accentPurple,
      Theme.of(context).extension<Lem3alamThemeTokens>()!.success,
      Theme.of(context).extension<Lem3alamThemeTokens>()!.warning
    ];
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.profileSkillsExpertise,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (skills.isEmpty)
                Text(l.noSkillsListed)
              else
                Wrap(spacing: 10, runSpacing: 10, children: [
                  for (var i = 0; i < visible.length; i++)
                    Chip(
                        avatar: Icon(Icons.handyman_outlined,
                            size: 18, color: colors[i % colors.length]),
                        backgroundColor:
                            colors[i % colors.length].withValues(alpha: .1),
                        label: Text(visible[i].name)),
                  if (skills.length > visible.length)
                    ActionChip(
                        label: Text(l
                            .profileMoreSkills(skills.length - visible.length)),
                        onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (c) => SafeArea(
                                    child: ListView(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.all(16),
                                        children: [
                                      Text(l.profileSkillsExpertise,
                                          style:
                                              Theme.of(c).textTheme.titleLarge),
                                      const SizedBox(height: 12),
                                      for (final skill in skills)
                                        ListTile(
                                            leading: Icon(
                                                Icons.handyman_outlined,
                                                color: Theme.of(c)
                                                    .colorScheme
                                                    .primary),
                                            title: Text(skill.name))
                                    ])))),
                ]),
            ])));
  }
}

class _ProfileEarnings extends StatelessWidget {
  const _ProfileEarnings({required this.view});
  final EarningsView view;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        t = Theme.of(context),
        success = t.extension<Lem3alamThemeTokens>()!.success;
    final delta = view.deltaPercent;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                      builder: (context, c) => c.maxWidth < 500
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                  Text(l.earningsTotal,
                                      style: t.textTheme.titleLarge),
                                  const SizedBox(height: 10),
                                  const PeriodSelector()
                                ])
                          : Row(children: [
                              Expanded(
                                  child: Text(l.earningsTotal,
                                      style: t.textTheme.titleLarge)),
                              const SizedBox(width: 12),
                              const SizedBox(
                                  width: 250, child: PeriodSelector())
                            ])),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, c) {
                    final amount = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EarningsMoney(view.summary.net,
                              currency: view.ledger.currency,
                              style: t.textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 7),
                          Text(
                              delta == null
                                  ? l.earningsNoComparison
                                  : l.earningsComparison(
                                      '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}'),
                              style: TextStyle(
                                  color: delta == null
                                      ? t.colorScheme.onSurfaceVariant
                                      : delta >= 0
                                          ? success
                                          : t.colorScheme.error)),
                        ]);
                    final chart = SizedBox(
                        height: 105,
                        child: CustomPaint(
                            painter: _Sparkline(view.points, success),
                            child: Align(
                                alignment: AlignmentDirectional.bottomEnd,
                                child: EarningsMoney(view.summary.net,
                                    currency: view.ledger.currency,
                                    style: TextStyle(
                                        color: success,
                                        fontWeight: FontWeight.w800)))));
                    if (c.maxWidth < 650) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            amount,
                            const SizedBox(height: 16),
                            chart
                          ]);
                    }
                    return Row(children: [
                      Expanded(child: amount),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: chart)
                    ]);
                  }),
                ])));
  }
}

class _Sparkline extends CustomPainter {
  _Sparkline(this.points, this.color);
  final List<EarningsChartPoint> points;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.isEmpty) return;
    final values = points.map((p) => p.net.toDouble()).toList();
    final minV = values.reduce(math.min),
        maxV = values.reduce(math.max),
        range = math.max(1, maxV - minV);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final p = Offset(
          values.length == 1
              ? size.width / 2
              : i * size.width / (values.length - 1),
          size.height - 24 - (values[i] - minV) / range * (size.height - 30));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _Sparkline old) =>
      old.points != points || old.color != color;
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.profile, required this.reviews});
  final TaskerProfile profile;
  final List<TaskerReview> reviews;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(
                            l.profileReviewsTitle(
                                NumberFormat.decimalPattern(l.localeName)
                                    .format(profile.totalReviews)),
                            style: Theme.of(context).textTheme.titleLarge)),
                    TextButton(
                        onPressed: () => context.pushNamed(
                            AppRouteNames.taskerReviews,
                            pathParameters: {'id': '${profile.id}'}),
                        child: Text(l.dashboardViewAll))
                  ]),
                  if (reviews.isEmpty) Text(l.noReviewsYet),
                  for (final review in reviews.take(3))
                    _ReviewRow(review: review, taskerId: profile.id),
                ])));
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.review, required this.taskerId});
  final TaskerReview review;
  final int taskerId;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<Lem3alamThemeTokens>()!,
        hash = review.reviewerName.codeUnits.fold(0, (a, b) => a + b);
    final colors = [
      Theme.of(context).colorScheme.primary,
      tokens.success,
      tokens.accentPurple,
      tokens.warning
    ];
    return InkWell(
        onTap: () => context.pushNamed(AppRouteNames.taskerReviews,
            pathParameters: {'id': '$taskerId'}),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                  backgroundColor:
                      colors[hash % colors.length].withValues(alpha: .12),
                  child: Text(review.reviewerName.trim().isEmpty
                      ? '?'
                      : review.reviewerName.trim()[0].toUpperCase())),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(review.reviewerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            for (var i = 1; i <= 5; i++)
                              Icon(
                                  i <= review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: tokens.warning)
                          ])
                        ]),
                    if (review.comment.trim().isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(review.comment)),
                    const SizedBox(height: 4),
                    Text(_relative(context, review.createdAtIso),
                        style: Theme.of(context).textTheme.bodySmall),
                  ])),
              const Icon(Icons.chevron_right),
            ])));
  }
}

String _relative(BuildContext context, String iso) {
  final l = context.l10n, date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return '';
  final d = DateTime.now().difference(date),
      f = NumberFormat.decimalPattern(l.localeName);
  if (d.inHours < 1) {
    return l.profileMinutesAgo(f.format(math.max(0, d.inMinutes)));
  }
  if (d.inDays < 1) return l.profileHoursAgo(f.format(d.inHours));
  if (d.inDays < 7) return l.profileDaysAgo(f.format(d.inDays));
  if (d.inDays < 35) return l.profileWeeksAgo(f.format(d.inDays ~/ 7));
  return DateFormat.yMMMd(l.localeName).format(date);
}

class _RecentJobs extends StatelessWidget {
  const _RecentJobs({required this.view});
  final EarningsView view;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        success = Theme.of(context).extension<Lem3alamThemeTokens>()!.success;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(l.profileRecentJobs,
                            style: Theme.of(context).textTheme.titleLarge)),
                    TextButton(
                        onPressed: () =>
                            context.goNamed(AppRouteNames.earnings),
                        child: Text(l.dashboardViewAll))
                  ]),
                  if (view.transactions.isEmpty) Text(l.profileNoRecentJobs),
                  for (final job in view.transactions.take(3))
                    InkWell(
                        onTap: () => context.pushNamed(AppRouteNames.taskDetail,
                            pathParameters: {'id': '${job.taskId}'}),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            child: Row(children: [
                              Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHigh),
                                  child: const Icon(Icons.handyman_outlined)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(job.taskTitle,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Wrap(spacing: 8, children: [
                                      Text(
                                          job.status ==
                                                  TransactionStatus.completed
                                              ? l.statusCompleted
                                              : l.statusInProgress,
                                          style: TextStyle(
                                              color: job.status ==
                                                      TransactionStatus
                                                          .completed
                                                  ? success
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary)),
                                      Text(
                                          DateFormat.yMMMd(l.localeName)
                                              .format(job.date),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall)
                                    ]),
                                  ])),
                              const SizedBox(width: 8),
                              if (MediaQuery.sizeOf(context).width < 500)
                                SizedBox(
                                    width: 88,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: EarningsMoney(
                                            job.amounts(view.calculator).net,
                                            currency: view.ledger.currency,
                                            style: TextStyle(
                                                color: success,
                                                fontWeight: FontWeight.w800))))
                              else
                                EarningsMoney(job.amounts(view.calculator).net,
                                    currency: view.ledger.currency,
                                    style: TextStyle(
                                        color: success,
                                        fontWeight: FontWeight.w800)),
                              const Icon(Icons.chevron_right),
                            ]))),
                ])));
  }
}

class _Badges extends StatelessWidget {
  const _Badges({required this.stats, required this.success});
  final EarningsStat stats;
  final int? success;
  @override
  Widget build(BuildContext context) {
    final badges = <ProfileBadgeKind>[
      if ((success ?? 0) >= 90) ProfileBadgeKind.topPerformer,
      if (stats.completedJobsAllTime >= 20) ProfileBadgeKind.trustedTasker,
      if ((stats.averageRating ?? 0) >= 4.5 && stats.reviewCount > 0)
        ProfileBadgeKind.fiveStarRated,
    ];
    final l = context.l10n,
        t = Theme.of(context),
        tokens = t.extension<Lem3alamThemeTokens>()!;
    (String, String, IconData, Color) item(ProfileBadgeKind b) => switch (b) {
          ProfileBadgeKind.topPerformer => (
              l.profileTopPerformer,
              l.profileBadgeHighSuccess,
              Icons.emoji_events,
              tokens.warning
            ),
          ProfileBadgeKind.trustedTasker => (
              l.profileBadgeTrusted,
              l.profileBadgeTrustedCaption,
              Icons.verified_user,
              tokens.accentPurple
            ),
          ProfileBadgeKind.fiveStarRated => (
              l.profileBadgeFiveStar,
              l.profileBadgeReviewCaption(
                  NumberFormat.decimalPattern(l.localeName)
                      .format(stats.reviewCount)),
              Icons.thumb_up,
              t.colorScheme.primary
            ),
        };
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.profileBadges, style: t.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (badges.isEmpty)
                    Text(l.profileNotRecorded)
                  else
                    LayoutBuilder(builder: (context, c) {
                      final columns = c.maxWidth >= 800
                          ? math.min(4, badges.length)
                          : math.min(2, badges.length);
                      return Wrap(spacing: 10, runSpacing: 10, children: [
                        for (final b in badges)
                          Builder(builder: (_) {
                            final v = item(b);
                            return Container(
                                width:
                                    (c.maxWidth - (columns - 1) * 10) / columns,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: t.colorScheme.outlineVariant)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                          backgroundColor:
                                              v.$4.withValues(alpha: .12),
                                          child: Icon(v.$3, color: v.$4)),
                                      const SizedBox(height: 9),
                                      Text(v.$1,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800)),
                                      Text(v.$2, style: t.textTheme.bodySmall),
                                    ]));
                          })
                      ]);
                    }),
                ])));
  }
}
