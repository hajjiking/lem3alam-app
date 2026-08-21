import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/tasks_controller.dart';

class TaskerCategoriesScreen extends ConsumerWidget {
  const TaskerCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryOptionsProvider);
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        actions: [
          IconButton(
            onPressed: () => showLanguagePicker(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.languageAction,
          ),
          const AppThemeModeButton(),
          IconButton(
            onPressed: () => ref.invalidate(categoryOptionsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshAction,
          ),
        ],
      ),
      body: SafeArea(
        child: AppResponsiveCenter(
          maxWidth: 920,
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorState(
              title: l10n.unableToLoad,
              subtitle: l10n.errNetwork,
              debugDetails: e.toString(),
              onRetry: () => ref.invalidate(categoryOptionsProvider),
            ),
            data: (categories) {
              if (categories.isEmpty) {
                return AppEmptyState(
                  title: l10n.noCategories,
                  subtitle: l10n.tryAgainLater,
                  icon: Icons.category_outlined,
                );
              }

              final sorted = categories.toList(growable: false);
              sorted.sort((a, b) {
                final ap = a.parentId == null ? -1 : a.parentId!;
                final bp = b.parentId == null ? -1 : b.parentId!;
                final byParent = ap.compareTo(bp);
                if (byParent != 0) return byParent;
                return a.localizedName(languageCode).toLowerCase().compareTo(
                  b.localizedName(languageCode).toLowerCase(),
                );
              });

              return LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final crossAxisCount = w < 520 ? 2 : (w < 860 ? 3 : 4);

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: sorted.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 168,
                    ),
                    itemBuilder: (context, index) => _CategoryTile(category: sorted[index]),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});

  final CategoryOption category;

  void _openTasks(BuildContext context, WidgetRef ref) {
    ref.read(selectedCategoryIdProvider.notifier).set(category.id);
    ref.read(tasksListControllerProvider.notifier).loadFirstPage();
    context.goNamed(AppRouteNames.tasks);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = (category.imageUrl ?? '').trim();
    final localizedName = category.localizedName(Localizations.localeOf(context).languageCode);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openTasks(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: imageUrl.isEmpty
                      ? Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant, size: 34)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image_outlined, color: colorScheme.onSurfaceVariant, size: 34);
                          },
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: progress.expectedTotalBytes == null
                                      ? null
                                      : progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              localizedName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
