# Tasker earnings

The Earnings tab is available only to authenticated taskers. The layout follows
the supplied design using the shared header, navigation, theme and translations.
Both period selectors update the same controller (this month, last month, year).
No reference-image amounts or example jobs are seeded in the production app.

## Money and scope

- `GET /api/v1/tasker/earnings` returns only the authenticated payee's completed
  MAD payments. Pending, failed, refunded, disputed, other-currency and future
  payments do not contribute to earned totals. Filters cannot select another user.
- Payments use `paid_at`, not task completion dates. Task counts are separate
  from payment counts; a completed task is not proof of payment.
- `FeeCalculator` is the single calculation entry point in this feature. It
  parses decimal amounts into integer centimes, rounds estimates once per
  transaction, and verifies recorded gross minus fee equals recorded net.
- Historical fees are preserved, including zero fees or rates other than 5%.
  Mismatched payment records produce a retry/error state, not invented totals.
- The API's named **5% estimate rate** is display-only. Active-job estimates use
  the accepted offer, or minimum task budget if there is no accepted offer.
  They are clearly labelled and excluded from totals, comparisons and charts.
  Estimates do not change billing rates or write payment records. Cash receipt
  confirmation is a separate explicit write, described below.
- Summary, cumulative chart and category totals are derived from the same fully
  paginated ledger. Fees are summed per payment, not rounded on an aggregate.
  Category percentages use largest-remainder rounding to sum to 100% when net
  earnings are positive. Zero-earnings periods have no artificial percentages.
- The current month/year compares the same elapsed interval in the previous
  month/year, capped at its end. Last month compares complete calendar months.
  With zero previous earnings, no percentage increase is claimed.
- Active-job and all-time job/rating statistics remain current when the earnings
  period changes. Historical completed-task counts follow the selected period.
- **Available Balance is unavailable** because there is no withdrawal ledger.
  It is not derived from completed or released payments. Tapping it explains why.
- The app reuses the existing native chart/donut approach rather than adding a
  charting dependency. Charts, currencies, and labels support light/dark themes
  and Arabic RTL. Transaction details are read-only and link to the task.

## Deploy

Deploy the Laravel files listed in [cash-payment-confirmation.md](cash-payment-confirmation.md)
together with `app/Http/Controllers/Api/TaskerEarningsController.php`. No schema migration is required. Refresh the
route/config caches through your normal deployment process, then rebuild and
install the Flutter app. Nothing has been deployed or paid out by this task.

The endpoint accepts `period=this_month|last_month|this_year`, `page`, `per_page`
(max 100), and an optional `as_of` timestamp. The app reuses the first response's
timestamp for later pages so date boundaries do not move during pagination.
The payload includes current/previous payment records, active estimates,
tasker-specific statistics, and period metadata. Currency is currently MAD only.

## Verify

- `flutter test test/fee_calculator_test.dart test/earnings_test.dart`
- Backend: `php artisan test --filter=TaskerEarningsApiTest`
- Optional fixture screenshots:
  `flutter test test/earnings_test.dart --dart-define=EARNINGS_SCREENSHOTS=true`
  (written to `build/earnings-previews`).

No live financial accounts or production transactions are used by the tests.

## Cash receipt confirmation

Client approval now prepares a pending payment. A tasker sees **Confirm cash
received** above the Earnings summary and in completed task details. It remains
outside earned totals until the tasker confirms actual receipt. Confirmation
refreshes earnings and the tasker dashboard. Reopening the Earnings tab or pulling
to refresh fetches newly approved jobs. See [the payment workflow](cash-payment-confirmation.md)
for non-cash limitations and deployment details.
