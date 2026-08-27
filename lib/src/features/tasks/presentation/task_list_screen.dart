import 'package:flutter/material.dart';
import 'task_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import '../../../core/networking/pagination.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/task.dart';
import 'task_image_support.dart';
import 'tasks_controller.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;
    if (position.pixels > position.maxScrollExtent - 300) {
      ref.read(tasksListControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final isLoggedIn = auth.status == AuthStatus.authenticated;
    final isClient = user?.isClient == true;
    final canCreate = isClient;
    final l10n = context.l10n;

    if (auth.status == AuthStatus.unknown) {
      return Scaffold(
        appBar: _buildAppBar(context, l10n, allowLocation: false),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: const [
              _TaskListTopSkeleton(),
              SizedBox(height: 20),
              AppCardListSkeleton(itemCount: 4),
            ],
          ),
        ),
      );
    }

    if (!isLoggedIn) {
      return Scaffold(
        appBar: _buildAppBar(context, l10n, allowLocation: false),
        body: AppErrorState(
          title: l10n.unableToLoad,
          subtitle: l10n.login,
          retryLabel: l10n.login,
          onRetry: () => context.goNamed(AppRouteNames.login),
        ),
      );
    }

    final state = ref.watch(tasksListControllerProvider);

    return Scaffold(
      appBar: _buildAppBar(context, l10n, allowLocation: true),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.goNamed(AppRouteNames.taskCreate),
              tooltip: l10n.createTask,
              icon: const Icon(Icons.add),
              label: Text(l10n.createTask),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: state.when(
          loading: () => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: const [
              _TaskListTopSkeleton(),
              SizedBox(height: 20),
              AppCardListSkeleton(itemCount: 4),
            ],
          ),
          error: (e, _) => AppErrorState(
            title: l10n.unableToLoad,
            subtitle: _errorMessage(context, e),
            debugDetails: e.toString(),
            retryLabel: isLoggedIn ? l10n.retry : l10n.login,
            onRetry: () => isLoggedIn
                ? ref.read(tasksListControllerProvider.notifier).loadFirstPage()
                : context.goNamed(AppRouteNames.login),
          ),
          data: (page) => _TaskListView(
            page: page,
            scrollController: _scrollController,
            onRefresh: () =>
                ref.read(tasksListControllerProvider.notifier).loadFirstPage(),
            canCreate: canCreate,
            searchController: _searchController,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n, {
    required bool allowLocation,
  }) {
    final auth = ref.watch(authControllerProvider);
    final isLoggedIn = auth.status == AuthStatus.authenticated;
    final user = auth.user;
    final name = (user?.name ?? '').trim();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 400;

    return AppBar(
      titleSpacing: 16,
      toolbarHeight: 84,
      title: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoggedIn) ...[
              Text(
                context.l10n.greetingMorning,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                name.isEmpty ? (user?.email ?? l10n.dashboard) : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ] else
              Text(l10n.tasks,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      actions: [
        if (allowLocation)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: isCompact
                ? IconButton(
                    onPressed: () => showLanguagePicker(context),
                    icon: const Icon(Icons.place_outlined),
                    tooltip: '${l10n.nearby} · ${l10n.searchCity}',
                  )
                : AppLocationChip(
                    location: l10n.nearby,
                    subtitle: l10n.searchCity,
                    onTap: () => showLanguagePicker(context),
                  ),
          ),
        if (!isCompact) ...[
          IconButton(
            onPressed: () => showLanguagePicker(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.languageAction,
          ),
          const AppThemeModeButton(),
          if (!isLoggedIn)
            IconButton(
              onPressed: () => context.goNamed(AppRouteNames.login),
              icon: const Icon(Icons.login),
              tooltip: l10n.login,
            ),
          if (isLoggedIn)
            IconButton(
              onPressed: () => ref
                  .read(tasksListControllerProvider.notifier)
                  .loadFirstPage(),
              icon: const Icon(Icons.notifications_outlined),
              tooltip: l10n.refreshAction,
            ),
        ] else ...[
          IconButton(
            onPressed: () => showLanguagePicker(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.languageAction,
          ),
          const AppThemeModeButton(),
          PopupMenuButton<_MoreActions>(
            tooltip: l10n.more,
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              if (!isLoggedIn)
                PopupMenuItem<_MoreActions>(
                  value: _MoreActions.login,
                  child: _AppMenuRow(
                    icon: Icons.login,
                    title: l10n.login,
                  ),
                ),
              if (isLoggedIn)
                PopupMenuItem<_MoreActions>(
                  value: _MoreActions.refresh,
                  child: _AppMenuRow(
                    icon: Icons.refresh_outlined,
                    title: l10n.refreshAction,
                  ),
                ),
            ],
            onSelected: (action) async {
              switch (action) {
                case _MoreActions.login:
                  context.goNamed(AppRouteNames.login);
                  break;
                case _MoreActions.refresh:
                  ref
                      .read(tasksListControllerProvider.notifier)
                      .loadFirstPage();
                  break;
              }
            },
          ),
        ],
        const SizedBox(width: 4),
      ],
    );
  }
}

class _TaskListTopSkeleton extends StatelessWidget {
  const _TaskListTopSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSkeletonBox(height: 56, radius: 18),
        SizedBox(height: 16),
        AppSkeletonBox(height: 180, radius: 28),
        SizedBox(height: 18),
        AppSkeletonBox(height: 22, width: 180),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: AppSkeletonBox(height: 122, radius: 22)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBox(height: 122, radius: 22)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBox(height: 122, radius: 22)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBox(height: 122, radius: 22)),
          ],
        ),
      ],
    );
  }
}

class _TaskListView extends ConsumerWidget {
  const _TaskListView({
    required this.page,
    required this.scrollController,
    required this.onRefresh,
    required this.canCreate,
    required this.searchController,
  });

  final Paginated<Task> page;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final bool canCreate;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final recommended = page.items.take(4).toList(growable: false);
    final rest = page.items.skip(recommended.length).toList(growable: false);

    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      displacement: 20,
      edgeOffset: 8,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AppSearchBar(
                controller: searchController,
                hintText: l10n.searchTasksHint,
                onSubmitted: (_) {},
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppHeroPromoCard(
                title: l10n.promoTodayTitle,
                subtitle: l10n.promoTodaySubtitle,
                ctaLabel: l10n.bookNow,
                icon: Icons.handyman_outlined,
                onCtaTap: () => context.goNamed(AppRouteNames.taskCreate),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PopularCategories(
                scrollController: scrollController,
              ),
            ),
          ),
          if (page.items.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppSectionHeader(
                  title: l10n.recommendedForYou,
                  subtitle: selectedCategoryId == null
                      ? l10n.pickedForYourNeeds
                      : l10n.inCategory,
                  actionLabel: l10n.seeAll,
                  onActionTap: () async {
                    if (!scrollController.hasClients) return;
                    await scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 380,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final task = recommended[index];
                    return SizedBox(
                      width: 320,
                      child: _TaskCard(
                          task: task, variant: _TaskCardVariant.highlighted),
                    );
                  },
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSectionHeader(
                title: l10n.allTasks,
                subtitle: page.items.isEmpty
                    ? ''
                    : l10n.tasksAvailableCount(page.items.length),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (page.items.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: AppEmptyState(
                  title: l10n.emptyTasksTitle,
                  subtitle: l10n.emptyTasksSubtitle,
                  icon: Icons.inbox_outlined,
                  actionLabel: canCreate ? l10n.createTask : l10n.login,
                  onAction: () => context.goNamed(canCreate
                      ? AppRouteNames.taskCreate
                      : AppRouteNames.login),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: rest.length + (page.hasNextPage ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index >= rest.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _TaskCard(task: rest[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _PopularCategories extends ConsumerWidget {
  const _PopularCategories({
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryOptionsProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 122,
        child: Row(
          children: [
            Expanded(child: AppSkeletonBox(height: 122, radius: 22)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBox(height: 122, radius: 22)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBox(height: 122, radius: 22)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBox(height: 122, radius: 22)),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        final parents =
            categories.where((c) => c.parentId == null).toList(growable: false);
        final popular = parents.take(8).toList(growable: false);
        final iconPalette = [
          (Icons.bolt_outlined, context.appColors.primary),
          (Icons.plumbing_outlined, context.appColors.secondary),
          (Icons.cleaning_services_outlined, context.appTokens.success),
          (Icons.format_paint_outlined, context.appTokens.warning),
          (Icons.handyman_outlined, context.appTokens.accentPurple),
          (Icons.kitchen_outlined, context.appTokens.accentPurple),
          (Icons.local_shipping_outlined, context.appTokens.info),
          (Icons.yard_outlined, context.appTokens.success),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: l10n.popularCategories,
              actionLabel: l10n.more,
              onActionTap: () =>
                  context.goNamed(AppRouteNames.dashboardCategories),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 122,
              ),
              itemCount: popular.length,
              itemBuilder: (context, index) {
                final c = popular[index];
                final palette = iconPalette[index % iconPalette.length];
                final selected = selectedCategoryId == c.id;
                final accentColor =
                    selected ? context.appColors.primary : palette.$2;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppCategoryTile(
                      label: c.localizedName(languageCode),
                      icon: palette.$1,
                      iconColor:
                          selected ? context.appColors.onPrimary : accentColor,
                      iconBackgroundColor: selected
                          ? context.appColors.primary
                          : accentColor.withValues(alpha: 0.12),
                      onTap: () async {
                        if (selectedCategoryId == c.id) return;
                        ref.read(selectedCategoryIdProvider.notifier).set(c.id);
                        await ref
                            .read(tasksListControllerProvider.notifier)
                            .loadFirstPage();
                        if (scrollController.hasClients) {
                          await scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                    if (selected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          height: 22,
                          width: 22,
                          decoration: BoxDecoration(
                            color: context.appColors.onPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.6)),
                          ),
                          child: Icon(Icons.check_rounded,
                              size: 14, color: context.appColors.primary),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (popular.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.zero,
                  itemCount: 1 + popular.take(4).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return FilterChip(
                        selected: selectedCategoryId == null,
                        label: Text(l10n.all),
                        onSelected: (_) async {
                          if (selectedCategoryId == null) return;
                          ref
                              .read(selectedCategoryIdProvider.notifier)
                              .set(null);
                          await ref
                              .read(tasksListControllerProvider.notifier)
                              .loadFirstPage();
                          if (scrollController.hasClients) {
                            await scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        showCheckmark: false,
                        side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.75)),
                      );
                    }
                    final c =
                        popular.take(4).toList(growable: false)[index - 1];
                    return FilterChip(
                      selected: selectedCategoryId == c.id,
                      label: Text(c.localizedName(languageCode)),
                      onSelected: (_) async {
                        if (selectedCategoryId == c.id) return;
                        ref.read(selectedCategoryIdProvider.notifier).set(c.id);
                        await ref
                            .read(tasksListControllerProvider.notifier)
                            .loadFirstPage();
                        if (scrollController.hasClients) {
                          await scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      showCheckmark: false,
                      side: BorderSide(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.75)),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

enum _TaskCardVariant { standard, highlighted }

class _TaskCard extends StatelessWidget {
  const _TaskCard(
      {required this.task, this.variant = _TaskCardVariant.standard});

  final Task task;
  final _TaskCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final statusColor = taskStatusColor(context, task.status);
    final urgencyColor = taskUrgencyColor(context, task.urgency);
    final localizedCategoryName = task.localizedCategoryName(languageCode);
    final isHighlight = variant == _TaskCardVariant.highlighted;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.goNamed(
          AppRouteNames.taskDetail,
          pathParameters: {'id': task.id.toString()},
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: isHighlight ? 320 / 170 : 360 / 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _TaskCardImage(task: task),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Pill(
                      label: _statusLabel(l10n, task.status),
                      background: colorScheme.surfaceContainerLowest,
                      foreground: statusColor,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Hero(
                            tag: 'task-title-${task.id}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                task.title,
                                maxLines: isHighlight ? 2 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        height: 1.3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          fit: FlexFit.loose,
                          child: _Pill(
                            label: '${task.budgetMax.toStringAsFixed(0)} MAD',
                            background: context.appColors.primary
                                .withValues(alpha: 0.10),
                            foreground: context.appColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            task.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(Icons.schedule_outlined,
                            size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _urgencyLabel(l10n, task.urgency),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: urgencyColor,
                                    fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        clipBehavior: Clip.antiAlias,
                        children: [
                          if ((localizedCategoryName ?? '').isNotEmpty)
                            _Pill(
                              icon: Icons.category_outlined,
                              label: localizedCategoryName!,
                              background: colorScheme.surfaceContainerHigh,
                              foreground: colorScheme.onSurfaceVariant,
                            ),
                          if (task.deadline != null)
                            _Pill(
                              icon: Icons.event_outlined,
                              label: task.deadline!
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                              background: colorScheme.surfaceContainerHigh,
                              foreground: colorScheme.onSurfaceVariant,
                            ),
                          if (task.budgetType.isNotEmpty)
                            _Pill(
                              icon: Icons.account_balance_wallet_outlined,
                              label: task.budgetType,
                              background: colorScheme.surfaceContainerHigh,
                              foreground: colorScheme.onSurfaceVariant,
                            ),
                        ],
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

class _TaskCardImage extends StatelessWidget {
  const _TaskCardImage({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CachedTaskImage(
        source: task.primaryImageSource,
        placeholder: const _TaskImagePlaceholder(),
        fit: BoxFit.cover,
      ),
    );
  }
}

class _TaskImagePlaceholder extends StatelessWidget {
  const _TaskImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(child: TaskImagePlaceholder());
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppPill(
        label: label,
        background: background,
        foreground: foreground,
        icon: icon);
  }
}

String _errorMessage(BuildContext context, Object error) {
  if (error is ApiException) {
    return localizeApiException(context, error);
  }
  return context.l10n.errUnknown;
}

String _statusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'open':
      return l10n.statusOpen;
    case 'assigned':
      return l10n.statusAssigned;
    case 'in_progress':
      return l10n.statusInProgress;
    case 'completed':
      return l10n.statusCompleted;
    case 'cancelled':
      return l10n.statusCancelled;
    default:
      return status;
  }
}

String _urgencyLabel(AppLocalizations l10n, String urgency) {
  switch (urgency) {
    case 'urgent':
      return l10n.urgencyUrgent;
    case 'high':
      return l10n.urgencyHigh;
    case 'medium':
      return l10n.urgencyMedium;
    case 'low':
      return l10n.urgencyLow;
    default:
      return urgency;
  }
}

enum _MoreActions { login, refresh }

class _AppMenuRow extends StatelessWidget {
  const _AppMenuRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
