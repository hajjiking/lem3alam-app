# Completion and cash receipt

Client approves completion → pending payment → tasker confirms actual cash
receipt → completed payment with `paid_at` → tasker earnings/dashboard update.

- Applies to approval from both the Flutter API and server-rendered website.
- The tasker sees a confirmation card in Earnings and completed task details.
  A dialog states the task and full gross cash amount; cancellation does nothing.
- Only the assigned, authenticated tasker may confirm a completed cash job.
  Clients, administrators through this endpoint, other taskers, and unfinished
  or non-cash jobs are rejected.
- The amount is read from the existing valid payment, otherwise the assigned
  tasker's accepted fixed-price offer, otherwise a fixed budget with equal min/max.
  Ranges, hourly rates without an invoice, missing offers and conflicting payment
  records require review. No guessed minimum is used as an actual payment.
- New payments use the shared **5% fee policy**, rounded half-up once per payment
  in integer centimes: 450.00 MAD gross → 22.50 MAD fee → 427.50 MAD net.
  The same rate drives earnings estimates. Existing recorded/manual fees remain
  authoritative. Completed, refunded, failed and disputed records are not rewritten.
- Unconfirmed MAD payments created by the old automatic completion flow with
  zero fees, gross equal to net, no payment/release date, and no recorded fee-policy
  marker are corrected when prepared/confirmed. GET previews the correction
  without writing; confirmation must match the reviewed gross, fee and net.
  A policy marker prevents repeated correction. Manually created zero-fee rows
  and explicit fee waivers are not silently converted.
- Task row locks serialize preparation, cash confirmation and API payment creation.
  Existing payments are reused; duplicate/ambiguous records are not auto-repaired.
  Retrying a successful cash confirmation returns success without changing
  payment dates or adding another payment. A changed amount returns HTTP 409.
- Cash confirmation records `cash_confirmed_by` and `cash_confirmed_at` in
  `payment_details`, plus `paid_at` and `released_at`. Cash is already in the
  tasker's hands; this is not a bank payout or a withdrawable wallet balance.
- Already-approved cash jobs without payments appear too. Listing is read-only;
  the payment is created only when the tasker explicitly confirms receipt.
- Outstanding cash confirmations are independent of the Earnings date filter.
  Newly confirmed payments are counted in the period of receipt, not completion.

## Non-cash limitation

There is no configured card/online payment gateway in this project. A completed,
previously verified non-cash payment is marked released after client approval.
Unpaid card payments are prepared as pending, **not falsely marked paid**.
Generic `online` tasks without an existing payment require a provider/method
integration before a transaction can be created. No external charge or transfer
is performed. Gateway capture, signed callbacks and payout integration are not
implemented by this change.

## Endpoints

- `GET /api/v1/tasker/cash-payments?page=1&per_page=100`
  (optional `task_id`, still scoped to the authenticated tasker).
- `POST /api/v1/tasks/{task}/confirm-cash` with the reviewed decimal breakdown,
  e.g. `{"amount":"450.00","platform_fee":"22.50","net_amount":"427.50"}`.
  All three values must match the server quote; they do not override it.

## Deploy together

From the Laravel project:

- `app/Services/CompletionPaymentService.php`
- `app/Services/PaymentFeeCalculator.php`
- `app/Models/Payment.php`
- `app/Http/Controllers/Api/TaskerEarningsController.php`
- `app/Http/Controllers/Api/TaskerCashPaymentController.php`
- `app/Http/Controllers/Api/ClientCompletionController.php`
- `app/Http/Controllers/Api/PaymentController.php`
- `app/Http/Controllers/TaskController.php`
- `routes/api.php`

Refresh route/config caches using the normal deployment process, then rebuild
and install the Flutter app. No migration or automatic historical payment write
is required. This task does not deploy, confirm cash, or charge live accounts.
Older app builds that send only the gross amount cannot confirm cash until
updated: the fee and net amounts must now be reviewed and submitted as well.

## Verification

- Laravel: `php artisan test --filter='PaymentFeesApiTest|CompletionPaymentApiTest|ClientCompletionApiTest|TaskerEarningsApiTest'`
- Flutter: `flutter test test/cash_payments_test.dart test/earnings_test.dart test/client_completion_test.dart`
- `dart analyze lib test`
