import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../taskers/presentation/tasker_public_profile_controller.dart';
import '../data/client_reviews_repository.dart';
import '../domain/task.dart';

Future<bool> showClientReviewSheet(
    BuildContext context, WidgetRef ref, Task task) async {
  final user = ref.read(authControllerProvider).user;
  final messenger = ScaffoldMessenger.of(context);
  final message = context.l10n.reviewSaved;
  final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ReviewSheet(task: task));
  if (!context.mounted) return false;
  final current = ref.read(authControllerProvider).user;
  if (current?.id != user?.id || current?.isClient != true) return false;
  // Also refresh after cancellation: an in-flight request may have completed
  // after dismissal, or another device may already have posted a review.
  ref.invalidate(clientReviewableTasksProvider);
  ref.invalidate(clientTaskReviewProvider(task.id));
  if (submitted == true) {
    ref.invalidate(publicTaskerProfileProvider(task.assignedTaskerId!));
    if (messenger.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
  return submitted == true;
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.task});
  final Task task;
  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  final _formKey = GlobalKey<FormState>();
  final _comment = TextEditingController();
  int _rating = 0;
  bool _busy = false;
  bool _ratingError = false;
  bool _unavailable = false;
  String? _error;
  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _unavailable) return;
    setState(() => _ratingError = _rating == 0);
    if (!_formKey.currentState!.validate() || _rating == 0) return;
    final route = ModalRoute.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(clientReviewsRepositoryProvider).submit(widget.task,
          rating: _rating, comment: _comment.text, locale: locale);
      if (!mounted || route?.isCurrent != true) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted || route?.isCurrent != true) return;
      setState(() {
        _busy = false;
        _unavailable = error is ApiException && error.statusCode == 409;
        _error = _unavailable
            ? context.l10n.reviewUnavailable
            : error is ApiException
                ? localizeApiException(context, error)
                : context.l10n.errUnknown;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
          child: Form(
              key: _formKey,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.leaveReview,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(widget.task.title),
                    if (widget.task.assignedTaskerName?.isNotEmpty == true)
                      Text(widget.task.assignedTaskerName!),
                    const SizedBox(height: 12),
                    Text(l10n.reviewPublicNotice),
                    const SizedBox(height: 12),
                    Wrap(alignment: WrapAlignment.center, children: [
                      for (var star = 1; star <= 5; star++)
                        IconButton(
                          key: ValueKey('review-star-$star'),
                          tooltip: l10n.reviewStars(star),
                          isSelected: star <= _rating,
                          onPressed: _busy || _unavailable
                              ? null
                              : () => setState(() {
                                    _rating = star;
                                    _ratingError = false;
                                  }),
                          icon: Icon(
                              star <= _rating ? Icons.star : Icons.star_border,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                    ]),
                    if (_ratingError)
                      Text(l10n.selectRatingFirst,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    TextFormField(
                        controller: _comment,
                        enabled: !_busy && !_unavailable,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 500,
                        decoration: InputDecoration(
                            labelText: l10n.shareYourExperience),
                        validator: (value) {
                          final length = (value ?? '').trim().runes.length;
                          return length < 20 || length > 500
                              ? l10n.reviewCommentLength
                              : null;
                        }),
                    if (_error != null)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_error!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                    FilledButton(
                        onPressed: _busy || _unavailable ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Text(l10n.submitReview)),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.close)),
                  ])),
        ));
  }
}
