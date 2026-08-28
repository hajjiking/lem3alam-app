# Messages

The shared client/tasker Messages tab now uses the authenticated Laravel API.
There is no seeded contact list or simulated message submission in the app.
Clients can start a direct conversation using **Message** on a tasker's profile.
Existing conversations retain their optional task context.

- Below 900 logical pixels, tapping a conversation pushes a full thread route;
  Back returns to the inbox. Wide screens use the same list/thread widgets side
  by side. Resizing preserves the selected contact through the route.
- Search covers contact names, latest-message previews, and task titles. All,
  Unread, and Archived tabs show counts from the loaded conversation data.
- Archive/unarchive is an account-scoped **device-local preference**, not server
  deletion. Unread badges include archived conversations.
- Messages refresh every 15 seconds while the Messages screen is visible and the
  app is foregrounded. Pull-to-refresh reloads the inbox. Earlier history can be
  loaded in the thread. This release does not subscribe to WebSockets.
- The input preserves unsuccessful drafts and prevents concurrent sends. A
  timeout can be ambiguous: check the conversation before manually retrying.
- Read acknowledgements are sent only for the visible thread when scrolled to
  the latest messages. The server limits them to incoming messages through the
  acknowledged message ID. Sent/read indicators use server state.
- English, French, Arabic/RTL, and the existing light/dark themes are supported.
  Message text is never translated or replaced by locale-specific alternatives.
- No live presence service is available: the UI says presence is unavailable,
  rather than interpreting a tasker's work availability as an online status.
- Calls, attachment upload, blocking, and reporting remain explicit unavailable
  actions. The tasker's public profile and archive actions are functional.

## Deploy

Deploy the backend `app/Http/Controllers/Api/MobileMessageController.php` and
updated `routes/api.php` together. The route import switches the old REST
messaging handlers to the corrected controller; existing website handlers remain
unchanged. Existing `messages` columns are reused, with no new migration.
Use the normal Laravel route/cache refresh procedure, then rebuild/install the
Flutter app. These changes have not been deployed by this task.

API paths relative to `/api/v1` (authentication required):

- `GET /conversations?page=1&per_page=50`: only the user's visible conversations,
  grouped by contact AND task, with latest preview, task context, and unread count.
- `GET /conversations/{contactId}/details?task_id=19`: metadata for an existing or
  eligible new conversation. Omit `task_id` for a direct conversation.
- `GET /conversations/{contactId}?task_id=19&page=1&per_page=30`: newest messages
  first; omit `task_id` (or use 0) for a direct conversation, not all tasks.
  `before_id` provides a stable cursor for earlier history while new messages arrive.
- `POST /messages`: `{ "receiver_id": 20, "task_id": 19, "content": "Hello" }`.
  `task_id` may be null. Sender identity is derived on the server. Task-linked
  sends require the task's client and an assigned/applicant tasker; direct sends
  require a client/tasker pair. Content is 1–5000 characters and encrypted at rest.
- `PUT /conversations/{contactId}/read`: `{ "task_id": 19, "through_id": 123 }`.
- The legacy `GET /messages` and `PUT /messages/{id}/read` now also enforce
  participant isolation and per-user deletion flags.

## Verify

`flutter test test/messages_test.dart` covers data mapping, pagination, account
switching, drafts/retries, lifecycle, phone navigation, wide layouts, and RTL.
`php artisan test --filter=MobileMessagingApiTest` covers private conversations,
task isolation, original text/encryption, authorization, and read watermarks.

Optional fixture-only visual previews:
`flutter test test/messages_test.dart --dart-define=MESSAGES_SCREENSHOTS=true`.
PNG files are generated under `build/messages-previews`; test contacts are never
used by the production provider.
