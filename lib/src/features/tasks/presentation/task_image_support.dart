import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';

String? resolveTaskImageUrl(String? source) {
  if (source == null || source.trim().isEmpty) {
    return null;
  }

  final value = source.trim();
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  final api = Uri.parse(AppConfig.apiBaseUrl);
  final publicBase = api
      .replace(path: api.path.replaceAll(RegExp(r'/api/v1/?$'), ''))
      .toString()
      .replaceAll(RegExp(r'/$'), '');

  final normalized = value.startsWith('/') ? value.substring(1) : value;
  if (normalized.startsWith('storage/')) {
    return '$publicBase/$normalized';
  }

  return '$publicBase/storage/$normalized';
}

class TaskImagePlaceholder extends StatelessWidget {
  const TaskImagePlaceholder({
    super.key,
    this.iconSize = 34,
    this.padding = const EdgeInsets.all(16),
  });

  final double iconSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surfaceContainerHigh,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: iconSize,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class CachedTaskImage extends StatelessWidget {
  const CachedTaskImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  final String? source;
  final BoxFit fit;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveTaskImageUrl(source);
    final fallback = placeholder ?? const TaskImagePlaceholder();

    if (resolved == null) {
      return fallback;
    }

    return CachedNetworkImage(
      imageUrl: resolved,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}
