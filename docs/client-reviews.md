# Client reviews in the app

Clients can leave one 1–5 star review with 20–500 characters of feedback for each
completed task assigned to a tasker. Entry points are the client dashboard,
completed task details, and the tasker's reviews page (which first asks the client
to select an eligible task). All lists and submitted reviews use API data.

## Backend deployment

Deploy these Laravel files together from the sibling backend project:

- `app/Http/Controllers/Api/ClientReviewController.php`
- `routes/api.php`

The existing review schema is reused; no new migration is required for this
feature. The existing application's migrations must already have been applied.
Clear/rebuild Laravel's route cache using the deployment's normal procedure.
Rebuild and install the Flutter app after deploying the backend changes.

Authenticated client endpoints, relative to `/api/v1`:

- `GET /client/reviewable-tasks?page=1&per_page=50`: paginated own completed,
  assigned, unreviewed tasks.
- `GET /tasks/{task}/my-review`: task, existing review, and eligibility.
- `POST /reviews`: `{ "task_id": 19, "rating": 5, "comment": "Excellent work, very professional.", "locale": "en" }`.

The server derives the author and tasker from the authenticated client and task;
it rejects foreign/unfinished/unassigned tasks and duplicate submissions.
Successful reviews are published immediately, matching the existing website's
policy, and update the tasker's rating. Review submission does not approve task
completion or release a payment. Failed submissions retain the form's feedback.

Verification: `flutter test test/client_reviews_test.dart` and backend
`php artisan test --filter=ClientReviewApiTest`. Tests use fixtures, not production
accounts or real reviews.
