# User reporting

Authenticated clients and taskers can report another user from a public tasker
profile or from an active conversation. Both entry points use the same form and
send `POST /api/v1/reports`.

The payload includes `reported_user_id`, a normalized reason, optional details,
and the conversation's `task_id` when available. The app rejects self-reporting,
checks that the response refers to the requested target, and expires only the
matching session after a `401` response.

Supported reasons are harassment or threats, spam or misleading activity,
fraud or attempted scams, inappropriate content, and other. Free-form details
are limited to the backend maximum of 5,000 characters. The reported user is
not told who submitted the report.

Blocking remains unavailable because the backend currently has no persistent
block model or enforcement across profiles, search, tasks, and conversations.

## Verification

```bash
flutter test test/user_reports_test.dart test/messages_test.dart test/public_tasker_profile_test.dart
```
