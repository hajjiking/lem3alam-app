# Individual tasker analytics

`GET /api/v1/tasker/dashboard` and `GET /api/v1/dashboard` (when signed in as a tasker) return that authenticated tasker's analytics. Authentication and existing role restrictions remain required. Request parameters cannot select another tasker.

## Data contract

- `performance`: current calendar week, starting Monday.
- `monthly_performance`: current calendar month. The app never substitutes weekly values for a missing monthly period.
- `earnings`: sum of completed payments' `net_amount`, filtered by `payee_id = authenticated user ID` and `paid_at` within the period through now. Pending, failed and refunded payments are excluded. Decimal amounts are preserved.
- `tasks_completed`: completed tasks assigned to the authenticated tasker, with `completed_at` within the period through now.
- `earnings_change_percent` and `tasks_change_percent`: signed changes against the same elapsed interval in the previous week/month. A shorter previous month is capped at its end. A zero previous baseline returns `null`, not a fabricated percentage.
- `points`: dated daily earnings (`value`) and completed-task counts. The server retains a full calendar period for compatibility; the app excludes points marked `is_future`. Missing legacy daily completion counts are shown as unavailable, not zero.
- `timezone`, `start_date`, `as_of_date`, `previous_start_date`, and `previous_end_date` describe the reporting window. Dates use the application's configured database timestamp convention/timezone.

All payment and task queries in `TaskerDashboardAnalytics` apply ownership filters before aggregation. No platform totals, other taskers' data, or sample analytics are used. Header totals remain all-time totals for the signed-in tasker; charts and performance metrics use the selected period.

The Flutter repository verifies `data.user.id` against the signed-in user. Account changes/logout clear the dashboard; late responses from the previous account are ignored. Loading, valid zero activity, missing server analytics, and API failure are distinct states. Retry, pull-to-refresh, and returning Home reload API data.

## Deployment

1. Deploy `app/Services/TaskerDashboardAnalytics.php` and the updated `app/Http/Controllers/Api/DashboardController.php` from the sibling Laravel project. No migration is required.
2. Rebuild and install the Flutter app; its configured API base is unchanged.
3. Sign in as a tasker and refresh. Both `data.performance` and `data.monthly_performance` should be present. An older server may show the missing-period notice until deployed.

## Verification

From the Laravel root:

```sh
php vendor/phpunit/phpunit/phpunit tests/Feature/TaskerAnalyticsApiTest.php tests/Feature/ApiDashboardTest.php tests/Feature/AdminAnalyticsApiTest.php --do-not-cache-result
```

From the Flutter root:

```sh
flutter test test/tasker_analytics_test.dart test/dashboard_screen_test.dart test/dashboard_models_test.dart test/dashboard_endpoints_test.dart
```

Tests cover two-tasker isolation, ignored forged identity parameters, account-switch races, logout, period boundaries, payment statuses, decimal amounts, negative/missing growth, weekly/monthly switching, retry/refresh, and compact English/French/Arabic layouts in light/dark themes. Add `--dart-define=TASKER_ANALYTICS_SNAPSHOTS=true` to generate fixture-based previews in `build/tasker_analytics_preview`; fixtures are never used in production.
