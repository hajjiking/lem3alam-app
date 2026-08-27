# Client-owned task lists

The mobile client Tasks tab is **My tasks**, not a public marketplace. The attached browse-screen document's all-task/mock-data requirements do not apply to this ownership requirement.

- Clients use authenticated `GET /api/v1/my-tasks`. All rows and pagination totals are scoped by the server to `client_id = authenticated user ID`, including category filtering. The app sends no client/user ID to choose the owner.
- The existing `GET /api/v1/tasks` API also scopes clients to their own tasks through `Task::scopeVisibleTo`. Taskers continue browsing open tasks from different clients.
- Direct task details enforce `Task::canBeViewedBy` server-side. Flutter also rejects missing or foreign `client_id` values in client list/detail responses. It does not silently replace malformed responses with empty results or fall back to the public feed.
- List, detail and category state reset when the authenticated identity changes. Late first-page or pagination responses cannot populate a new account's list. A previous account's 401 cannot log out a different current account.
- The client view uses the server pagination total, localized own-task labels, and one list of owned tasks instead of recommendations. No mock tasks or counts are added.

## Deployment

Rebuild/install the Flutter app. Server ownership behavior already exists locally and was not changed for this task. If production differs, deploy the corresponding ownership code in `app/Models/Task.php`, `app/Services/TaskService.php`, `app/Http/Controllers/Api/TaskController.php`, and the authenticated task routes in `routes/api.php`; merge with production changes rather than replacing unrelated code. Clear the Laravel route cache after route changes.

Verify `/api/v1/my-tasks` with two different client accounts: each should receive only its own `client_id`, with its own total. Attempting the other client's task detail must return 403. No database migration is required.

## Regression checks

```sh
flutter test test/client_task_ownership_test.dart test/tasks_repository_access_test.dart
```

From the Laravel root:

```sh
php vendor/phpunit/phpunit/phpunit tests/Feature/ClientTaskOwnershipApiTest.php tests/Feature/TaskVisibilityTest.php --filter 'ClientTaskOwnershipApiTest|TaskVisibilityTest::api_' --do-not-cache-result
```

The separate server-rendered website currently uses a public open-task marketplace. Its existing guest-redirect and client-list-isolation tests fail; this mobile/API change does not alter that website behavior.

The broader Flutter navigation suites (`widget_test.dart` and `tasker_pages_test.dart`) also fail with startup routing expectations and `pumpAndSettle` timeouts. They are not counted as passing ownership checks.
