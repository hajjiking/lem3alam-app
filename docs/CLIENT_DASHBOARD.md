# Client dashboard

Clients at `/dashboard` see `ClientDashboardScreen`; taskers retain their existing dashboard and administrators retain their existing redirect. The client screen reuses the shared header, filters, task cards, theme, promo layout, menu and bottom navigation.

## Data contract

- Authenticated `GET client/dashboard` supplies `data.stats` and `data.recent_tasks`. Taskers use `GET tasker/dashboard` and administrators use `GET admin/dashboard`. The shared API retains `GET dashboard` for automatic server-side role selection. All paths are relative to the configured `/api/v1/` base (including `/public/` where required by the deployment).
- The Laravel controller scopes client tasks by the signed-in user's `client_id`. Role-specific endpoints enforce the corresponding role; the app does not fall back to another endpoint on authorization errors.
- `active_tasks`, `completed_tasks`, `pending_tasks` and `accepted_tasks` must be nonnegative integer counts. Missing or malformed dashboard data produces a retry state, not fabricated zero statistics.
- A valid empty response shows zero counts and a first-task invitation.
- `success_rate` is an optional API percentage from 0 to 100, displayed with up to two decimal places. The backend calculates completed / (completed + cancelled) × 100 and returns null when no tasks have finished. Display `—` for null; never derive the percentage from the limited recent-task list.
- Recent-task filters apply to the API's latest ten tasks. Aggregate counts describe all tasks, so a filter may have no recent matches despite a nonzero count. The empty state explains this and View All opens the full task list.
- Cancelled tasks are excluded from the three recent-task filters. Decimal budgets are preserved. Missing creation dates are labelled unavailable.
- Account/language changes reload the provider. Returning Home, pull-to-refresh, and successful task creation/editing/deletion refresh client data.
- No synthetic availability or notification badge is shown. Messages, Payments and client Profile retain explicit feature-unavailable notices because those destinations are not implemented.

## Verification

`flutter test test/client_dashboard_test.dart` covers API parsing, malformed responses, account changes, retry/loading/empty states, filters, role selection, destinations, navigation and English/French/Arabic layouts in both themes at compact and wide sizes.

Add `--dart-define=CLIENT_SNAPSHOTS=true` to render visual QA images under `build/client_dashboard_preview/`. These images use test fixtures, not live account data. Production has no fixture fallback.
