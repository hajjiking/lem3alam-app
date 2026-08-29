import 'package:flutter/material.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import '../../../core/analytics/app_analytics.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/public_profile_model.dart';
import 'tasker_public_profile_controller.dart';
import 'widgets/widgets.dart';
import 'tasker_own_profile_screen.dart';

class TaskerProfileScreen extends ConsumerStatefulWidget {
  const TaskerProfileScreen({super.key, required this.taskerId});

  final int taskerId;

  @override
  ConsumerState<TaskerProfileScreen> createState() =>
      _TaskerProfileScreenState();
}

class _TaskerProfileScreenState extends ConsumerState<TaskerProfileScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = _ProfileTab.values;

  late final TabController _tab;
  var _isFav = false;
  List<bool> _helpfulToggles = const [];
  int? _lastKnownModelId;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(publicTaskerProfileProvider(widget.taskerId));
  }

  void _toggleFav() {
    setState(() => _isFav = !_isFav);
    ref.read(analyticsProvider).track(
      'public_profile_favorite',
      properties: {
        'tasker_id': widget.taskerId,
        'is_favorite': _isFav,
      },
    );
  }

  void _onBack() {
    ref.read(analyticsProvider).track(
      'public_profile_back',
      properties: {'tasker_id': widget.taskerId},
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRouteNames.dashboard);
    }
  }

  void _onShare() {
    ref.read(analyticsProvider).track(
      'public_profile_share',
      properties: {'tasker_id': widget.taskerId},
    );
  }

  void _onCall() {
    ref.read(analyticsProvider).track(
      'public_profile_call',
      properties: {'tasker_id': widget.taskerId},
    );
  }

  void _onMessage() {
    ref.read(analyticsProvider).track(
      'public_profile_message',
      properties: {'tasker_id': widget.taskerId},
    );
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      context.pushNamed(AppRouteNames.login);
    } else if (user.isClient) {
      context.pushNamed(AppRouteNames.messageThread,
          pathParameters: {'peerId': '${widget.taskerId}'});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n
              .dashboardFeatureUnavailable(context.l10n.dashboardMessages))));
    }
  }

  void _onBookNow(PublicProfileModel? model) {
    ref.read(analyticsProvider).track(
      'public_profile_book_now',
      properties: {'tasker_id': widget.taskerId},
    );
    final m = model;
    context.goNamed(
      AppRouteNames.taskCreate,
      queryParameters: {
        if (m != null)
          'prefill_title': context.l10n.serviceRequestForName(m.name),
        if (m != null)
          'prefill_description': context.l10n.bookServiceDescription(m.name),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(authControllerProvider).user;
    if (signedIn?.isTasker == true && signedIn?.id == widget.taskerId) {
      return TaskerOwnProfileScreen(taskerId: widget.taskerId);
    }
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final bg = scheme.surface;
    final systemBarIcon =
        brightness == Brightness.light ? Brightness.dark : Brightness.light;

    final async = ref.watch(publicTaskerProfileProvider(widget.taskerId));
    final PublicProfileModel? model = async.asData?.value;
    if (model != null && _lastKnownModelId != model.id) {
      _lastKnownModelId = model.id;
      _helpfulToggles = List<bool>.filled(model.reviews.length, false);
    }

    final hasData = model != null;

    Widget body;
    if (hasData) {
      body = _Body(
        key: const ValueKey('body'),
        tab: _tab,
        helpfulToggles: _helpfulToggles,
        onHelpfulToggle: (i, v) {
          if (i < 0 || i >= _helpfulToggles.length) return;
          setState(() => _helpfulToggles[i] = v);
        },
        onMessage: _onMessage,
        onBookNow: () => _onBookNow(model),
        onBookService: () => _onBookNow(model),
        model: model,
      );
    } else if (async.isLoading) {
      body = const _SkeletonBody(key: ValueKey('skeleton'));
    } else {
      body = _ErrorBody(
        key: const ValueKey('error'),
        error: '${async.asError?.error ?? context.l10n.errUnknown}',
        stackTrace: '${async.asError?.stackTrace ?? ''}',
        onRetry: _refresh,
      );
    }

    final bookNowFromServices = model == null
        ? null
        : (model.services.isNotEmpty &&
                model.services.first.startingPrice != null
            ? 'From ${model.services.first.startingPrice} ${model.services.first.currency}'
            : null);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: systemBarIcon,
        statusBarBrightness: brightness,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: systemBarIcon,
        systemNavigationBarContrastEnforced: true,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: _buildAppBar(model),
        body: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            SafeArea(top: false, bottom: false, child: body),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomBookingBar(
                onCall: _onCall,
                onBookNow: () => _onBookNow(model),
                enabled: hasData,
                priceHint: bookNowFromServices,
                phoneHint: model?.phone,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(PublicProfileModel? model) {
    final scheme = Theme.of(context).colorScheme;
    final pageBg = scheme.surface;
    final btnBg = scheme.surfaceContainerLowest;
    return AppBar(
      backgroundColor: pageBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: scheme.onSurface,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _onBack,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        style: IconButton.styleFrom(
          backgroundColor: btnBg,
          elevation: 0,
          side: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.45), width: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(40, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      titleSpacing: 0,
      title: _AppBarTitle(
        name: model?.name,
        profession: model?.profession,
        isOnline: model?.isOnline ?? false,
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: _onShare,
          tooltip: 'Share',
          icon: const Icon(Icons.share_outlined),
          style: IconButton.styleFrom(
            backgroundColor: btnBg,
            elevation: 0,
            side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.45), width: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: _toggleFav,
          tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (ch, a) => ScaleTransition(scale: a, child: ch),
            child: _isFav
                ? Icon(Icons.favorite_rounded,
                    color: context.appColors.error, key: ValueKey('fav_on'))
                : const Icon(Icons.favorite_border_rounded,
                    key: ValueKey('fav_off')),
          ),
          style: IconButton.styleFrom(
            backgroundColor: btnBg,
            elevation: 0,
            side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.45), width: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({this.name, this.profession, required this.isOnline});
  final String? name;
  final String? profession;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (name == null) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  if (isOnline) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.appTokens.success,
                      ),
                    ),
                  ],
                ],
              ),
              if ((profession ?? '').trim().isNotEmpty)
                Text(
                  profession!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _ProfileTab { about, services, portfolio, reviews, availability }

class _Body extends StatelessWidget {
  const _Body({
    super.key,
    required this.model,
    required this.tab,
    required this.helpfulToggles,
    required this.onHelpfulToggle,
    required this.onMessage,
    required this.onBookNow,
    required this.onBookService,
  });

  final PublicProfileModel model;
  final TabController tab;
  final List<bool> helpfulToggles;
  final void Function(int index, bool value) onHelpfulToggle;
  final VoidCallback onMessage;
  final VoidCallback onBookNow;
  final VoidCallback onBookService;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    const tabs = _ProfileTab.values;
    final media = MediaQuery.of(context);
    final bookingBarReserve = 120.0 + media.padding.bottom;
    final pageBg = scheme.surface;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Container(
              color: pageBg,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: AppResponsiveCenter(
                  maxWidth: 900,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(
                        profileImageUrl: model.profileImageUrl,
                        name: model.name,
                        profession: model.profession,
                        rating: model.rating,
                        reviewCount: model.reviewCount,
                        city: model.city,
                        country: model.country,
                        distanceKm: model.distanceKm,
                        isVerified: model.isVerified,
                        isOnline: model.isOnline,
                        isTopRated: model.isTopRated,
                        yearsExperience: model.yearsExperience,
                        availableToday: model.availableToday,
                        onMessage: onMessage,
                        onBookNow: onBookNow,
                        heroTag: 'profile-avatar-${model.id}',
                      ),
                      const SizedBox(height: 20),
                      StatisticCard(
                        items: [
                          StatisticItem(
                            icon: Icons.check_circle_outline_rounded,
                            label: l10n.statJobsCompleted,
                            value: model.jobsCompleted == null
                                ? '-'
                                : _fmtInt(model.jobsCompleted!),
                            accent: context.appColors.primary,
                          ),
                          StatisticItem(
                            icon: Icons.star_rounded,
                            label: l10n.rating,
                            value: model.rating.toStringAsFixed(1),
                            accent: context.appTokens.warning,
                          ),
                          StatisticItem(
                            icon: Icons.schedule_rounded,
                            label: l10n.statResponseTime,
                            value: model.responseMinutes == null
                                ? '-'
                                : '${model.responseMinutes} min',
                            accent: context.appTokens.success,
                          ),
                          StatisticItem(
                            icon: Icons.flag_rounded,
                            label: l10n.statCompletionRate,
                            value: model.completionRate == null
                                ? '-'
                                : '${(model.completionRate! * 100).toStringAsFixed(0)}%',
                            accent: context.appTokens.accentPurple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: _TabsDelegate(
              controller: tab,
              tabs: [
                (label: l10n.about, icon: Icons.person_outline_rounded),
                (label: l10n.services, icon: Icons.handyman_outlined),
                (label: l10n.portfolio, icon: Icons.photo_library_outlined),
                (label: l10n.reviews, icon: Icons.rate_review_outlined),
                (
                  label: l10n.availability,
                  icon: Icons.event_available_outlined
                ),
              ],
            ),
          ),
        ];
      },
      body: Container(
        color: pageBg,
        child: Padding(
          padding: EdgeInsets.only(bottom: bookingBarReserve),
          child: TabBarView(
            controller: tab,
            physics: const ClampingScrollPhysics(),
            children: [
              for (final t in tabs) _tabContent(t, context, scheme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtInt(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}k';
    return '$v';
  }

  Widget _tabContent(
    _ProfileTab tab,
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    switch (tab) {
      case _ProfileTab.about:
        return _AboutTab(model: model, l10n: l10n, scheme: scheme);
      case _ProfileTab.services:
        return _ServicesTab(model: model, onBook: onBookService, l10n: l10n);
      case _ProfileTab.portfolio:
        return _PortfolioTab(
          items: model.portfolio
              .map(
                (p) => PortfolioItem(
                  title: p.title,
                  imagePath: p.imagePath,
                  description: p.description,
                  category: p.category,
                  tags: p.tags,
                  isFeatured: p.isFeatured,
                ),
              )
              .toList(growable: false),
          l10n: l10n,
          scheme: scheme,
        );
      case _ProfileTab.reviews:
        return _ReviewsTab(
          model: model,
          helpfulToggles: helpfulToggles,
          onHelpfulToggle: onHelpfulToggle,
          scheme: scheme,
          l10n: l10n,
        );
      case _ProfileTab.availability:
        return _AvailabilityTab(
          model: model,
          scheme: scheme,
          l10n: l10n,
        );
    }
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  const _TabsDelegate({
    required this.controller,
    required this.tabs,
  });
  final TabController controller;
  final List<({String label, IconData icon})> tabs;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: AppResponsiveCenter(
        maxWidth: 900,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.35), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            controller: controller,
            isScrollable: true,
            labelPadding: EdgeInsets.zero,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            labelColor: scheme.onPrimary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            unselectedLabelStyle:
                Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
            splashBorderRadius: BorderRadius.circular(16),
            tabs: [
              for (final t in tabs)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  child: Tab(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.icon, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              t.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              semanticsLabel: t.label,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 80;
  @override
  bool shouldRebuild(covariant _TabsDelegate oldDelegate) =>
      oldDelegate.controller != controller;
}

class _AboutTab extends StatelessWidget {
  const _AboutTab(
      {required this.model, required this.l10n, required this.scheme});
  final PublicProfileModel model;
  final AppLocalizations l10n;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      primary: false,
      child: AppResponsiveCenter(
        maxWidth: 900,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(title: l10n.about),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: AppStyle.cardDecoration(context),
                        child: Text(
                          (model.bio ?? '').trim().isEmpty
                              ? l10n.noBioProvided
                              : model.bio!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 1.55,
                                    color: scheme.onSurfaceVariant
                                        .withValues(alpha: 0.95),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SectionTitle(title: l10n.features),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final f in model.features)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: context.appTokens.success
                                      .withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      size: 14,
                                      color: context.appTokens.success),
                                  const SizedBox(width: 6),
                                  Text(
                                    f,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: scheme.onSurface,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (wide) ...[
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child:
                        _IllustrationCard(color: context.appTokens.headerStart),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.85),
              color.withValues(alpha: 0.75),
              context.appTokens.headerEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -40,
              top: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -30,
              bottom: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.appTokens.success.withValues(alpha: 0.25),
                      context.appTokens.success.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1),
                      ),
                      child: const Icon(Icons.electric_bolt_rounded,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Clean. Safe. Certified.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Licensed & insured electrician',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({
    required this.model,
    required this.onBook,
    required this.l10n,
  });
  final PublicProfileModel model;
  final VoidCallback onBook;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: AppResponsiveCenter(
              maxWidth: 900,
              child: SectionTitle(
                title: l10n.services,
                subtitle:
                    'Choose a service below to book ${model.name.split(' ').first}.',
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280 +
                (MediaQuery.textScalerOf(context).scale(16) - 16)
                        .clamp(0, double.infinity) *
                    5,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 6, 0),
              scrollDirection: Axis.horizontal,
              itemCount: model.services.length,
              separatorBuilder: (_, __) => const SizedBox.shrink(),
              itemBuilder: (context, i) {
                final s = model.services[i];
                return ServiceCard(
                  icon: s.icon,
                  name: s.name,
                  startingPrice: s.startingPrice,
                  currency: s.currency,
                  estimatedDuration: s.estimatedDuration,
                  color: s.color,
                  onBook: onBook,
                  heroTag: 'svc-${model.id}-$i',
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab({
    required this.items,
    required this.l10n,
    required this.scheme,
  });
  final List<PortfolioItem> items;
  final AppLocalizations l10n;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      primary: false,
      child: AppResponsiveCenter(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: l10n.portfolio,
              subtitle: l10n.portfolioSubtitle(items.length),
            ),
            PortfolioGrid(items: items),
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({
    required this.model,
    required this.helpfulToggles,
    required this.onHelpfulToggle,
    required this.scheme,
    required this.l10n,
  });
  final PublicProfileModel model;
  final List<bool> helpfulToggles;
  final void Function(int index, bool value) onHelpfulToggle;
  final ColorScheme scheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      primary: false,
      child: AppResponsiveCenter(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AverageRating(
              average: model.rating,
              total: model.reviewCount,
              distribution: _dist(model.reviews),
              scheme: scheme,
            ),
            const SizedBox(height: 18),
            SectionTitle(
              title: 'Recent reviews',
              subtitle: 'From ${model.reviewCount.toString()} happy customers',
            ),
            if (model.reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: AppEmptyState(
                  title: l10n.noReviews,
                  subtitle: l10n.noReviewsYet,
                  icon: Icons.rate_review_outlined,
                ),
              )
            else
              for (var i = 0; i < model.reviews.length; i++) ...[
                ReviewCard(
                  reviewerName: model.reviews[i].reviewerName,
                  rating: model.reviews[i].rating,
                  comment: model.reviews[i].comment.isEmpty
                      ? l10n.noCommentProvided
                      : model.reviews[i].comment,
                  dateLabel: model.reviews[i].dateLabel,
                  reviewerAvatar: model.reviews[i].reviewerAvatar,
                  verifiedCustomer: model.reviews[i].verifiedCustomer,
                  taskTitle: model.reviews[i].taskTitle,
                  isHelpful:
                      helpfulToggles.length > i ? helpfulToggles[i] : false,
                  onHelpfulToggle: (v) => onHelpfulToggle(i, v),
                ),
                if (i != model.reviews.length - 1) const SizedBox(height: 14),
              ],
          ],
        ),
      ),
    );
  }

  static Map<int, int> _dist(List<PublicReviewItem> r) {
    final m = <int, int>{};
    for (final x in r) {
      final k = x.rating.clamp(1, 5).round();
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }
}

class _AverageRating extends StatelessWidget {
  const _AverageRating({
    required this.average,
    required this.total,
    required this.distribution,
    required this.scheme,
  });
  final double average;
  final int total;
  final Map<int, int> distribution;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppReviewSummaryCard(
      averageRating: average,
      totalReviews: total,
      distribution: distribution,
    );
  }
}

class _AvailabilityTab extends StatelessWidget {
  const _AvailabilityTab({
    required this.model,
    required this.scheme,
    required this.l10n,
  });
  final PublicProfileModel model;
  final ColorScheme scheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      primary: false,
      child: AppResponsiveCenter(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: l10n.availability,
              subtitle: model.availableToday
                  ? l10n.acceptingNewBookings
                  : l10n.currentlyBusy,
            ),
            AvailabilityCalendar(
              availableDates: model.availabilityDates,
              unavailableDates: model.unavailableDates,
              morningLabel: l10n.slotMorning,
              afternoonLabel: l10n.slotAfternoon,
              eveningLabel: l10n.slotEvening,
              initialMonth: DateTime.now(),
              onSlotSelected: (s) {
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: const AppCardListSkeleton(),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    super.key,
    required this.error,
    required this.onRetry,
    this.stackTrace,
  });
  final String error;
  final String? stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final debug = StringBuffer(error);
    final stk = stackTrace?.trim() ?? '';
    if (stk.isNotEmpty && stk != 'null') {
      debug.write('\n\n$stk');
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppErrorState(
                title: context.l10n.unableToLoad,
                subtitle: context.l10n.errUnknown,
                debugDetails: debug.toString(),
                retryLabel: context.l10n.retry,
                onRetry: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
