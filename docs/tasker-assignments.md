# Tasker active assignments

The tasker dashboard now shows all assignments owned by the signed-in tasker in
`assigned` or `in_progress` status, including requests awaiting client approval.
The same completion action is available in task details. Counts come from the
paginated private API, not the limited recent-tasks feed or pending applications.

## Backend deployment required

Deploy these files from the sibling Laravel project before installing the app:

- `app/Http/Controllers/Api/TaskerAssignmentController.php`
- `routes/api.php`

Routes (authenticated, `role:tasker`):

- `GET /api/v1/tasker/assignments?page=1&per_page=50`
- `POST /api/v1/tasks/{task}/submit-completion`

Clear Laravel's route cache after deployment (`php artisan route:clear`), then
rebuild the route cache if that is part of the normal deployment process.
The existing `completion_requested_at` migration must already be applied; no
new database migration is introduced here.

Completion requests are idempotent and require current assignment ownership.
They set `completion_requested_at` and `in_progress`, never `completed`, and do
not create or release payments. Approval remains in the existing client
completion workflow. This change does not add client approval controls to the app.

## Verification

- Laravel: `php artisan test --filter=TaskerAssignmentsApiTest`
- Flutter: `flutter test test/tasker_assignments_test.dart`
- Flutter: `dart analyze lib test`
