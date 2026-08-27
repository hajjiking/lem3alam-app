# Tasker browsing

The tasker's Tasks tab uses authenticated `GET /api/v1/tasks`. Available means `status = open`. The default request sends pagination only: no client ID, tasker ID, location, distance, saved-only, or skill restriction. A category filter applies only when selected. Nearby tasks remain a separate optional screen.

The shared Tasks screen displays one paginated feed and the API's total count. It no longer splits the first four tasks into recommendations. Taskers see a browse/apply notice instead of the client-only posting promotion. Each open task has a **View and apply** action leading to the real detail screen and its existing application form. No application is submitted merely by opening a task.

Clients still use `/api/v1/my-tasks` and can only see their own tasks. The existing API also scopes client access to `/api/v1/tasks` and denies foreign task details. Tasker details for assigned/applied work retain their existing access rules; those closed tasks are not advertised in the open feed.

The reference's sample tasks and counts are not used. Production displays real API data only. In-progress and completed tasks are not advertised as available work.

## Deployment and verification

Rebuild/install the Flutter app. No new API route or migration is required for this change; the backend's role-based visibility already exists locally. If production differs, deploy the corresponding ownership/open-task behavior in `app/Models/Task.php`, `app/Services/TaskService.php`, `app/Http/Controllers/Api/TaskController.php`, and authenticated task routes in `routes/api.php`.

```sh
flutter test test/tasker_available_tasks_test.dart test/client_task_ownership_test.dart test/tasks_repository_access_test.dart
```

From the Laravel root:

```sh
php vendor/phpunit/phpunit/phpunit tests/Feature/TaskerAvailableTasksApiTest.php tests/Feature/ClientTaskOwnershipApiTest.php --do-not-cache-result
```

Coverage includes multiple clients/cities, pagination, open-only API results, client isolation, the real `/tasks` route, no tasker posting CTA, application entry-point navigation, and English/French/Arabic layouts.
