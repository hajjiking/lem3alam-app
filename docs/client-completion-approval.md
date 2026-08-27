# Client completion approval

Clients can review pending completion requests from their dashboard or task
details, then confirm **Approve completion** or **Return for changes**.
Only the task's owner can decide. Approving completes the task; returning it
clears the request and leaves it in progress so the tasker can resubmit.
Neither action creates or releases a payment.

## Deploy backend first

Deploy these Laravel files from the sibling project:

- `app/Http/Controllers/Api/ClientCompletionController.php`
- `routes/api.php`

Then clear the route cache (`php artisan route:clear`) and rebuild it if used
by your deployment process. Rebuild and reinstall the Flutter app afterwards.
No new migration is required; the existing `completion_requested_at` column
is used.

Client-only authenticated endpoints:

- `GET /api/v1/client/completion-requests?page=1&per_page=50`
- `POST /api/v1/tasks/{task}/approve-completion`
- `POST /api/v1/tasks/{task}/decline-completion`

Both POST requests send the reviewed `completion_requested_at` timestamp. The
server locks the task and checks ownership, pending status and timestamp before
applying a decision. Resolved or changed requests return 409 and the app refreshes
the task instead of claiming success. Pending counts use every API page.

## Tests

- `php artisan test --filter=ClientCompletionApiTest` (Laravel project)
- `flutter test test/client_completion_test.dart`
- `dart analyze lib test`
