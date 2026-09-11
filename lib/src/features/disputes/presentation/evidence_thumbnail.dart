import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/dispute_draft.dart';

class EvidenceThumbnail extends StatelessWidget {
  const EvidenceThumbnail({super.key, required this.file, this.onRemove});
  final EvidenceFile file;
  final VoidCallback? onRemove;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 96,
      height: 108,
      child: Stack(children: [
        Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: file.fileType == EvidenceFileType.image
                        ? Image.memory(file.bytes,
                            fit: BoxFit.cover,
                            semanticLabel: file.fileName,
                            errorBuilder: (_, __, ___) => _document())
                        : _document()))),
        if (onRemove != null)
          PositionedDirectional(
              top: 0,
              end: 0,
              child: IconButton.filled(
                  onPressed: onRemove,
                  tooltip: context.l10n.disputeRemove(file.fileName),
                  iconSize: 16,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(Icons.close)))
      ]));
  Widget _document() => Padding(
      padding: const EdgeInsets.all(8),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.description_outlined),
        Text(file.fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11))
      ]));
}
