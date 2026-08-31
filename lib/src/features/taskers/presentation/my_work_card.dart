import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';

class MyWorkCard extends StatelessWidget {
  const MyWorkCard({
    super.key,
    required this.imageUrls,
    this.onViewAll,
  });

  final List<String> imageUrls;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.publicProfileMyWork,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                TextButton(
                    onPressed: onViewAll ?? () {},
                    child: Text(l10n.publicProfileViewAll)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 142,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _Thumbnail(
                  url: imageUrls[index],
                  onTap: () => _showGallery(context, index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGallery(BuildContext context, int initialPage) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialPage),
              itemCount: imageUrls.length,
              itemBuilder: (_, index) => InteractiveViewer(
                child: Center(
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 64),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: IconButton(
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.onTap});
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 156,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dark
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: dark
              ? const [
                  BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 3))
                ]
              : null,
        ),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: const Center(child: Icon(Icons.image_outlined)),
          ),
        ),
      ),
    );
  }
}
