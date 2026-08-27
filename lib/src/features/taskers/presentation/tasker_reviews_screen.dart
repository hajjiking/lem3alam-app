import 'package:flutter/material.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/app_analytics.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/pagination.dart';
import '../../../core/ui/app_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/client_reviews_panel.dart';
import '../../tasks/presentation/client_review_sheet.dart';
import '../data/taskers_repository_impl.dart';
import '../domain/tasker_profile.dart';
import '../domain/tasker_review.dart';
import '../domain/taskers_repository.dart';

class TaskerReviewsScreen extends ConsumerStatefulWidget {
  const TaskerReviewsScreen({super.key, required this.taskerId});

  final int taskerId;

  @override
  ConsumerState<TaskerReviewsScreen> createState() =>
      _TaskerReviewsScreenState();
}

class _TaskerReviewsScreenState extends ConsumerState<TaskerReviewsScreen> {
  static const _perPage = 10;

  final _controller = ScrollController();
  var _ratingFilter = 0;
  var _sort = 'newest';
  String? _from;
  String? _to;

  var _loading = true;
  Object? _error;
  TaskerProfile? _profile;

  Paginated<TaskerReview>? _page;
  final _items = <TaskerReview>[];
  var _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    Future.microtask(_loadFirst);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;
    if (position.pixels > position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  TaskerReviewsQuery get _query => TaskerReviewsQuery(
        rating: _ratingFilter == 0 ? null : _ratingFilter,
        sort: _sort,
        from: _from,
        to: _to,
      );

  Future<void> _loadProfile() async {
    try {
      final repo = ref.read(taskersRepositoryProvider);
      final profile = await repo.getProfile(widget.taskerId);
      if (mounted) setState(() => _profile = profile);
    } catch (_) {}
  }

  Future<void> _loadFirst() async {
    if (_profile == null) {
      // ignore: unawaited_futures
      _loadProfile();
    }
    setState(() {
      _loading = true;
      _error = null;
      _items.clear();
      _page = null;
    });

    try {
      final repo = ref.read(taskersRepositoryProvider);
      final page = await repo.reviews(
        taskerId: widget.taskerId,
        page: 1,
        perPage: _perPage,
        query: _query,
      );
      if (mounted) {
        setState(() {
          _page = page;
          _items.addAll(page.items);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!mounted) return;
    if (_loading || _loadingMore) return;
    final page = _page;
    if (page == null || !page.hasNextPage) return;

    setState(() => _loadingMore = true);
    try {
      final repo = ref.read(taskersRepositoryProvider);
      final next = await repo.reviews(
        taskerId: widget.taskerId,
        page: page.currentPage + 1,
        perPage: _perPage,
        query: _query,
      );
      if (mounted) {
        setState(() {
          _page = next;
          _items.addAll(next.items);
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Map<int, int> get _effectiveDistribution {
    final profile = _profile;
    if (profile != null && profile.ratingDistribution.isNotEmpty) {
      return profile.ratingDistribution;
    }
    final d = <int, int>{};
    for (final r in _items) {
      final k = r.rating.clamp(1, 5);
      d[k] = (d[k] ?? 0) + 1;
    }
    return d;
  }

  double get _effectiveAverage {
    final profile = _profile;
    if (profile != null && profile.totalReviews > 0) {
      return profile.averageRating;
    }
    if (_items.isEmpty) return 0;
    final sum = _items.fold<int>(0, (a, b) => a + b.rating);
    return sum / _items.length;
  }

  int get _effectiveTotal {
    final profile = _profile;
    if (profile != null) return profile.totalReviews;
    return _page?.total ?? _items.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviews),
        actions: [
          const AppThemeModeButton(),
          IconButton(
            onPressed: () {
              ref.read(analyticsProvider).track(
                'tasker_reviews_refresh',
                properties: {'tasker_id': widget.taskerId},
              );
              _loadFirst();
            },
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshAction,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const AppCardListSkeleton()
            : _error != null
                ? AppErrorState(
                    title: context.l10n.unableToLoad,
                    subtitle: context.l10n.errUnknown,
                    debugDetails: _error.toString(),
                    retryLabel: context.l10n.retry,
                    onRetry: _loadFirst,
                  )
                : AppResponsiveCenter(
                    maxWidth: 900,
                    child: Stack(
                      children: [
                        CustomScrollView(
                          controller: _controller,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: AppReviewSummaryCard(
                                  averageRating: _effectiveAverage,
                                  totalReviews: _effectiveTotal,
                                  distribution: _effectiveDistribution,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                child: _Filters(
                                  rating: _ratingFilter,
                                  sort: _sort,
                                  from: _from,
                                  to: _to,
                                  onChanged: (rating, sort, from, to) {
                                    setState(() {
                                      _ratingFilter = rating;
                                      _sort = sort;
                                      _from = from;
                                      _to = to;
                                    });
                                    ref.read(analyticsProvider).track(
                                      'tasker_reviews_filter',
                                      properties: {
                                        'tasker_id': widget.taskerId,
                                        'rating': rating,
                                        'sort': sort,
                                        'from': from,
                                        'to': to,
                                      },
                                    );
                                    _loadFirst();
                                  },
                                ),
                              ),
                            ),
                            if (_items.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 20, 16, 120),
                                  child: AppEmptyState(
                                    title: context.l10n.noReviews,
                                    subtitle:
                                        context.l10n.noReviewsMatchFilters,
                                    icon: Icons.rate_review_outlined,
                                  ),
                                ),
                              )
                            else ...[
                              SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 140),
                                sliver: SliverList.separated(
                                  itemCount:
                                      _items.length + (_loadingMore ? 1 : 0),
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.4),
                                  ),
                                  itemBuilder: (context, index) {
                                    if (index >= _items.length) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 14),
                                        child: Center(
                                          child: SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        ),
                                      );
                                    }
                                    final review = _items[index];
                                    return _ReviewTile(review: review);
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _WriteReviewBar(
                            taskerId: widget.taskerId,
                            profile: _profile,
                            onSubmitted: () {
                              ref.read(analyticsProvider).track(
                                'tasker_review_written',
                                properties: {'tasker_id': widget.taskerId},
                              );
                              _profile = null;
                              _loadFirst();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.rating,
    required this.sort,
    required this.from,
    required this.to,
    required this.onChanged,
  });

  final int rating;
  final String sort;
  final String? from;
  final String? to;
  final void Function(int rating, String sort, String? from, String? to)
      onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final ratings = [0, 5, 4, 3, 2, 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ratings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final r = ratings[i];
              final selected = rating == r;
              final starRow = r == 0
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var j = 0; j < r; j++)
                          Padding(
                            padding: EdgeInsets.only(right: j == r - 1 ? 0 : 1),
                            child: Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: selected
                                  ? context.appColors.onPrimary
                                  : context.appTokens.warning,
                            ),
                          ),
                      ],
                    );
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onChanged(r, sort, from, to),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (starRow != null) ...[
                          starRow,
                          const SizedBox(width: 6),
                        ],
                        Text(
                          r == 0 ? l10n.all : r.toString(),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SortChip(
                value: sort,
                onChanged: (v) => onChanged(rating, v, from, to),
              ),
            ),
            const SizedBox(width: 10),
            _DateRangeButton(
              from: from,
              to: to,
              onClear: (from == null && to == null)
                  ? null
                  : () => onChanged(rating, sort, null, null),
              onPickFrom: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked == null) return;
                onChanged(rating, sort, _formatYmd(picked), to);
              },
              onPickTo: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked == null) return;
                onChanged(rating, sort, from, _formatYmd(picked));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final options = [
      _Opt('newest', l10n.sortByNewest, Icons.schedule_rounded),
      _Opt('rating_high', l10n.sortByTopRated, Icons.star_rounded),
    ];
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      tooltip: l10n.sort,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) => [
        for (final o in options)
          PopupMenuItem<String>(
            value: o.value,
            child: Row(
              children: [
                Icon(o.icon, size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Text(o.label),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list_rounded,
                size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                options
                    .firstWhere((o) => o.value == value,
                        orElse: () => options.first)
                    .label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.expand_more_rounded,
                size: 18, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Opt {
  _Opt(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onClear,
  });
  final String? from;
  final String? to;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final active = from != null || to != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPickFrom,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: active
                    ? colorScheme.primary.withValues(alpha: 0.10)
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active
                      ? colorScheme.primary.withValues(alpha: 0.35)
                      : colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.date_range_rounded,
                      size: 18,
                      color: active
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    from == null ? l10n.fromDate : from!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: active
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPickTo,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: active
                    ? colorScheme.primary.withValues(alpha: 0.10)
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active
                      ? colorScheme.primary.withValues(alpha: 0.35)
                      : colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_rounded,
                      size: 18,
                      color: active
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    to == null ? l10n.toDate : to!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: active
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onClear != null) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.clear_rounded),
            tooltip: l10n.clearDates,
            color: colorScheme.onSurfaceVariant,
            splashRadius: 18,
          ),
        ],
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final TaskerReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = review.reviewerAvatar;
    final avatarUrl = avatar == null || avatar.trim().isEmpty
        ? null
        : _resolvePublicStorageUrl(avatar);
    final comment = review.comment.trim().isEmpty
        ? l10n.noCommentProvided
        : review.comment.trim();

    return AppSectionCard(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppReviewTile(
            reviewerName: review.reviewerName.isEmpty
                ? l10n.anonymous
                : review.reviewerName,
            reviewerAvatarUrl: avatarUrl,
            rating: review.rating.toDouble(),
            text: comment,
            relativeDate: appRelativeDateFromIso(review.createdAtIso, l10n),
          ),
          if ((review.taskTitle ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 58, right: 4, bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.work_outline,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      review.taskTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 58, right: 4, bottom: 8),
            child: Row(
              children: [
                _HelpfulButton(
                  reviewId: review.id,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpfulButton extends StatefulWidget {
  const _HelpfulButton({required this.reviewId});
  final int reviewId;

  @override
  State<_HelpfulButton> createState() => _HelpfulButtonState();
}

class _HelpfulButtonState extends State<_HelpfulButton> {
  var _helpful = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final fg = _helpful ? colorScheme.primary : colorScheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          setState(() => _helpful = !_helpful);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _helpful ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                size: 16,
                color: fg,
              ),
              const SizedBox(width: 6),
              Text(
                _helpful ? l10n.helpful : l10n.notHelpful,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WriteReviewBar extends ConsumerWidget {
  const _WriteReviewBar(
      {required this.taskerId,
      required this.profile,
      required this.onSubmitted});
  final int taskerId;
  final TaskerProfile? profile;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authControllerProvider).user?.isClient != true) {
      return const SizedBox.shrink();
    }
    return Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () async {
                  final task = await showModalBottomSheet<Task>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (pickerContext) => SafeArea(
                          top: false,
                          child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: ClientReviewsPanel(
                                  taskerId: taskerId,
                                  onSelect: (task) =>
                                      Navigator.of(pickerContext).pop(task)))));
                  if (task == null || !context.mounted) return;
                  final saved = await showClientReviewSheet(context, ref, task);
                  if (saved && context.mounted) onSubmitted();
                },
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(context.l10n.leaveReview),
              ),
            )));
  }
}

String? _resolvePublicStorageUrl(String? path) {
  final p = (path ?? '').trim();
  if (p.isEmpty) return null;
  if (p.startsWith('http://') || p.startsWith('https://')) return p;

  final api = Uri.parse(AppConfig.apiBaseUrl);
  final publicBase = api
      .replace(path: api.path.replaceAll(RegExp(r'/api/v1/?$'), ''))
      .toString()
      .replaceAll(RegExp(r'/$'), '');
  final normalized = p.startsWith('/') ? p.substring(1) : p;
  return '$publicBase/storage/$normalized';
}

String _formatYmd(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
