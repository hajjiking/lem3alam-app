import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_config.dart';

class PortfolioGrid extends StatefulWidget {
  const PortfolioGrid({
    super.key,
    required this.items,
    this.maxCrossAxisExtent = 220,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
  });

  final List<PortfolioItem> items;
  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  State<PortfolioGrid> createState() => _PortfolioGridState();
}

class _PortfolioGridState extends State<PortfolioGrid> {
  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No portfolio yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: widget.maxCrossAxisExtent,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisExtent: null,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final it = widget.items[index];
        final tag = it.tag ?? Object();
        return _Tile(
          item: it,
          heroTag: tag,
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              DialogRoute<void>(
                context: context,
                builder: (ctx) => _GalleryPreview(
                  items: widget.items,
                  initialIndex: index,
                  heroTagPrefix: tag,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.item,
    required this.heroTag,
    required this.onTap,
  });
  final PortfolioItem item;
  final Object heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final img = _resolveUrl(item.imagePath);
    final tile = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          img == null
              ? Container(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  child: Icon(Icons.image_outlined, size: 42, color: scheme.onSurfaceVariant),
                )
              : Image.network(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                    child: Icon(Icons.broken_image_outlined, size: 42, color: scheme.onSurfaceVariant),
                  ),
                ),
          if ((item.category ?? item.tags.join(', ')).trim().isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  (item.category ?? item.tags.firstOrNull) ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          if (item.isFeatured)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if ((item.description ?? '').trim().isNotEmpty)
                    Text(
                      item.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Hero(
          tag: heroTag,
          flightShuttleBuilder: (_, anim, direction, fromContext, toContext) {
            return RotationTransition(
              turns: Tween<double>(begin: 0, end: direction == HeroFlightDirection.push ? 0.01 : 0).animate(anim),
              child: (direction == HeroFlightDirection.push ? fromContext.widget : toContext.widget),
            );
          },
          child: tile,
        ),
      ),
    );
  }

  static String? _resolveUrl(String path) {
    final p = path.trim();
    if (p.isEmpty) return null;
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final api = Uri.parse(AppConfig.apiBaseUrl);
    final publicBase = api.replace(path: api.path.replaceAll(RegExp(r'/api/v1/?$'), '')).toString().replaceAll(RegExp(r'/$'), '');
    final normalized = p.startsWith('/') ? p.substring(1) : p;
    return '$publicBase/storage/$normalized';
  }
}

class _GalleryPreview extends StatefulWidget {
  const _GalleryPreview({
    required this.items,
    required this.initialIndex,
    required this.heroTagPrefix,
  });
  final List<PortfolioItem> items;
  final int initialIndex;
  final Object heroTagPrefix;

  @override
  State<_GalleryPreview> createState() => _GalleryPreviewState();
}

class _GalleryPreviewState extends State<_GalleryPreview> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      backgroundColor: Colors.transparent,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton.filled(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (v) => setState(() => _current = v),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final img = _resolve(item.imagePath);
                final tag = index == _current ? widget.heroTagPrefix : Object();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      color: scheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: tag,
                              child: img == null
                                  ? Container(
                                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                                      child: Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 80,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      img,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          size: 80,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              border: Border(
                                top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                              ),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    textStyle: Theme.of(context).textTheme.titleMedium,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if ((item.description ?? '').trim().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    item.description!,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (item.tags.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final t in item.tags)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: scheme.primary.withValues(alpha: 0.10),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            '#$t',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: scheme.primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
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
          if (widget.items.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: i == _current ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _current ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String? _resolve(String path) {
    final p = path.trim();
    if (p.isEmpty) return null;
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final api = Uri.parse(AppConfig.apiBaseUrl);
    final publicBase = api.replace(path: api.path.replaceAll(RegExp(r'/api/v1/?$'), '')).toString().replaceAll(RegExp(r'/$'), '');
    final normalized = p.startsWith('/') ? p.substring(1) : p;
    return '$publicBase/storage/$normalized';
  }
}

class PortfolioItem {
  const PortfolioItem({
    required this.title,
    required this.imagePath,
    this.description,
    this.category,
    this.tags = const [],
    this.isFeatured = false,
    this.tag,
  });

  final String title;
  final String imagePath;
  final String? description;
  final String? category;
  final List<String> tags;
  final bool isFeatured;
  final Object? tag;
}
