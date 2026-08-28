# Client Payments

The client-only `/payments` screen follows the supplied My Payments reference using authenticated API data. Tasker Earnings remains separate.

## Backend contract

Deploy `app/Http/Controllers/Api/ClientPaymentsController.php` and the updated `routes/api.php` from the Laravel repository. The new authenticated, client-role-only endpoint is `GET /api/v1/client/payments`.

Parameters: `period=this_month|last_month|this_year`, `page`, `per_page` (maximum 100), and optional `as_of` (not in the future). The app fetches all ledger pages with the same as-of boundary and checks the owner, currency, page count, dates and record count before displaying totals. This boundary fixes the date window; it is not a database transaction snapshot. Concurrent changes that make the ledger incomplete produce a retry state.

Every returned payment must have both the authenticated client as payer and a task owned by that client. Only MAD records are returned. Other clients' payments and malformed cross-owner records are excluded.

- Selected-period spending, cumulative chart and category totals sum the **gross amount of completed payments**, using `paid_at`. Tasker fees are not deducted from client spending.
- Pending, failed, disputed and refunded records remain visible in history but do not contribute to completed spending. Their date is labeled payment creation date, not payment/refund date.
- Refunded rows show the original payment amount. No refund total is inferred because separate refund amounts/dates are not stored.
- Completed records without `paid_at` contribute only to all-time spending, with an explicit warning. Future-dated payments are excluded from all-time spending.
- Posted tasks and total spending are all-time metrics; completed tasks use the selected period; in-progress tasks reflect current assignments.
- Both period selectors share state. Account changes clear the prior account's data and reset the period. Refresh occurs on entry and pull-to-refresh.

## Deliberately unavailable capabilities

The backend does not implement a wallet ledger, funding gateway, remaining-budget ledger or card vault. These values return `null`, not zero or demo values. Add Funds and Add New Card open an explanation; they never initiate a charge or collect card details. Profile and notification controls retain the existing app behavior.

No payment records, fees, balances or historical transactions are changed by this feature. No database migration is required.

## Release

Publish the backend controller and route together, then refresh the server's route cache using the project's normal deployment process. Rebuild and distribute the Flutter app. Neither deployment nor app distribution is performed automatically by this change.

## Verification

- Backend: `php artisan test --compact --filter=ClientPaymentsApiTest`
- Flutter: `flutter test test/client_payments_test.dart test/earnings_test.dart`
- Local visual previews: add `--dart-define=PAYMENTS_SCREENSHOTS=true`; images are written under `build/payments-previews/`.

Tests cover ownership, gross amounts, statuses, date periods, pagination, stale-account responses, period races, navigation, unsupported actions, English/French/Arabic, dark theme and large text. Fixture amounts exist only in tests.
