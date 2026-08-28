import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:go_router/go_router.dart';
import '../../../routing/app_router.dart';
import '../../tasks/presentation/task_image_support.dart';
import '../domain/conversation_model.dart';

class TaskContextCard extends StatelessWidget {
  const TaskContextCard({super.key, required this.task});
  final ConversationTaskContext task;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final format =
        NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final url = resolveTaskImageUrl(task.thumbnailUrl);
    return Card(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: InkWell(
            onTap: () => context.pushNamed(AppRouteNames.taskDetail,
                pathParameters: {'id': '${task.id}'}),
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  SizedBox(
                      width: 64,
                      height: 72,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: url == null
                              ? const Icon(Icons.image_not_supported_outlined)
                              : Image.network(url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported_outlined)))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall),
                        if (task.location?.isNotEmpty == true)
                          Row(children: [
                            Icon(Icons.location_on_outlined,
                                size: 16, color: scheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(task.location!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis))
                          ]),
                        if (task.budgetMin != null)
                          Text(
                              '${format.format(task.budgetMin)}${task.budgetMax != null && task.budgetMax != task.budgetMin ? ' – ${format.format(task.budgetMax)}' : ''} MAD',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w800)),
                      ])),
                ]))));
  }
}
