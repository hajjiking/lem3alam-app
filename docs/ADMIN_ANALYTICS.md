# Live admin analytics

`GET /api/v1/admin/dashboard` now returns an `analytics` object alongside its existing totals. The generic `/api/v1/dashboard` returns the same admin response for an authenticated administrator. Existing Sanctum and role restrictions are unchanged.

## Contract and definitions

- `weekly_series`: seven daily points ending today; `monthly_series`: thirty daily points ending today.
- Each point has `date` (`YYYY-MM-DD`), `posted`, `started`, and `completed` counts, using `created_at`, `started_at`, and `completed_at` respectively. These are recorded events, not reconstructed historical status snapshots. Tasks with missing event timestamps do not contribute to that event series. The database's configured application timezone is returned as `timezone`; future events are excluded.
- `status_counts`: current platform-wide counts for open, assigned, in-progress, completed and cancelled tasks. Unrecognized stored statuses are also retained rather than silently dropped.
- `top_categories`: the five largest categories, with IDs, localized names, counts and percentages of **all** tasks, not just the top five. Unavailable category names are displayed explicitly.
- `recent_tasks`: the six newest tasks, ordered by creation timestamp then ID, with actual IDs, localized titles, customer display names, statuses, creation timestamps and optional image URLs. Private user fields are not included.
- `locale=ar|en|fr` selects names; `Accept-Language` is also supported. The Flutter repository sends the current app locale and reloads when it changes.
- The UI uses `completed_payments_amount` for **Paid volume**, not legacy `revenue`, which includes all payment statuses. Existing legacy responses remain supported.

SQL aggregation keeps date/status/category queries bounded in returned rows; the API does not load every task into memory. There is no demo-data fallback. Valid zero activity shows zero charts; a server missing `analytics` shows the compatibility notice; malformed analytics produces a retry state.

## Deployment

Both sides must be updated to see this on a phone:

1. Deploy `app/Services/AdminDashboardAnalytics.php` and the updated `app/Http/Controllers/Api/AdminController.php` from the Laravel project. No database migration is needed: the implementation uses existing columns.
2. Rebuild and install the Flutter app. The configured API base remains unchanged, including `/public/` on deployments that require it.
3. Sign in as an admin and pull to refresh. Verify the authenticated response includes `data.analytics` if the compatibility notice remains.

## Verification

Backend (Laravel root):

```sh
php vendor/phpunit/phpunit/phpunit tests/Feature/AdminAnalyticsApiTest.php tests/Feature/ApiDashboardTest.php --do-not-cache-result
```

Flutter:

```sh
flutter test test/admin_analytics_test.dart test/admin_dashboard_screen_test.dart test/dashboard_endpoints_test.dart
```

Add `--dart-define=ADMIN_ANALYTICS_SNAPSHOTS=true` to produce local layout previews under `build/admin_analytics_preview`. Preview images use test fixtures only; production analytics always comes from the API.
