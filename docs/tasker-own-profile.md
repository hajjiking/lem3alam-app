# Tasker own profile

The tasker Profile navigation now opens a private, dashboard-style profile when the signed-in tasker's id matches the profile id. Clients and public visitors keep the existing service-booking profile.

## Data sources

- Identity, biography, verification, location, skills and membership date: `GET /api/v1/taskers/{id}`.
- Reviews: `GET /api/v1/taskers/{id}/reviews`.
- Completed/active job totals, completion rate basis, recent jobs and earnings: authenticated `GET /api/v1/tasker/earnings`.
- The mini earnings card watches the same `earningsPeriodProvider` and `earningsControllerProvider` as the full Earnings screen.

No fixture or sample profile data is present in production. The completion rate is completed assignments divided by terminal assignments; active assignments are excluded from the denominator. Achievement badges are derived only from recorded metrics. The Punctual badge is not displayed because the backend has no punctuality metric. Response time is labeled “Not recorded” for the same reason.

Profile editing, sharing, settings and notifications retain explicit unavailable notices where the app has no implemented flow. The menu's Log Out action uses the existing authenticated logout controller.

## Backend release

Publish the updated `routes/api.php` (profile `created_at`) and `TaskerEarningsController.php` (`completed_jobs_all_time`). There is no database migration. Refresh the server's route/config cache using the normal deployment process, then rebuild and distribute the Flutter app. Deployment and distribution are not performed by these changes.

## Verification

- Backend: `php artisan test --compact --filter='ApiTaskerProfileTest|TaskerEarningsApiTest'`
- Flutter: `flutter test test/tasker_own_profile_test.dart test/earnings_test.dart`
- Preview images: add `--dart-define=PROFILE_SCREENSHOTS=true`; output is under `build/profile-previews/`.

Tests cover authenticated ownership, API-derived statistics, shared earnings, interaction states, English/French/Arabic, RTL, dark mode, wide/phone layouts and large text.
