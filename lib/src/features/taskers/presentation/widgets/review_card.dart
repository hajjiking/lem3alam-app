import 'package:flutter/material.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';

import '../../../../core/config/app_config.dart';
import 'badge_chip.dart';
import 'rating_widget.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.dateLabel,
    this.reviewerAvatar,
    this.verifiedCustomer = false,
    this.taskTitle,
    this.isHelpful = false,
    this.onHelpfulToggle,
    this.helpfulLabel = 'Helpful',
    this.notHelpfulLabel = 'Not helpful',
  });

  final String reviewerName;
  final double rating;
  final String comment;
  final String dateLabel;
  final String? reviewerAvatar;
  final bool verifiedCustomer;
  final String? taskTitle;
  final bool isHelpful;
  final ValueChanged<bool>? onHelpfulToggle;
  final String helpfulLabel;
  final String notHelpfulLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = isHelpful ? scheme.primary : scheme.onSurfaceVariant;
    final avatar = _avatar();
    return Container(
      decoration: AppStyle.cardDecoration(context),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            reviewerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingWidget(rating: rating, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          rating.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: context.appTokens.warning,
                                  ),
                        ),
                        if (verifiedCustomer) ...[
                          const SizedBox(width: 10),
                          BadgeChip.verified(context, 'Verified'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((taskTitle ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline_rounded,
                      size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      taskTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            comment,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
          ),
          if (onHelpfulToggle != null) ...[
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onHelpfulToggle!.call(!isHelpful),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isHelpful
                            ? Icons.thumb_up_rounded
                            : Icons.thumb_up_outlined,
                        size: 16,
                        color: fg,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isHelpful ? helpfulLabel : notHelpfulLabel,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: fg,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatar() {
    final url = (reviewerAvatar ?? '').trim();
    final resolved = url.isEmpty
        ? null
        : url.startsWith('http')
            ? url
            : _resolveStorage(url);
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: resolved == null
              ? Icon(Icons.person_outline_rounded,
                  size: 22, color: scheme.primary)
              : Image.network(
                  resolved,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.person_outline_rounded,
                      size: 22,
                      color: scheme.primary),
                ),
        );
      },
    );
  }

  static String? _resolveStorage(String path) {
    final api = Uri.parse(AppConfig.apiBaseUrl);
    final publicBase = api
        .replace(path: api.path.replaceAll(RegExp(r'/api/v1/?$'), ''))
        .toString()
        .replaceAll(RegExp(r'/$'), '');
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$publicBase/storage/$normalized';
  }
}
