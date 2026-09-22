# Client profile and account settings

Authenticated clients can open `/profile` from the Profile item in the bottom
navigation. The screen uses live account data and does not display fixture or
derived contact information.

## Backend contract

- `GET /api/v1/profile` returns the authenticated user's profile under `data`.
- `PUT /api/v1/profile` accepts `name`, `email`, `phone`, and `location`.
- The response must contain the updated authenticated user under `data`.

The mobile repository verifies that the returned profile ID still matches the
active client account. A `401` expires only the matching session, and switching
accounts while a request is running prevents the old response from being shown.
Laravel validation errors are displayed on the corresponding edit fields.

## Included settings

The profile screen links to notifications and language selection, toggles the
existing light/dark appearance setting, and supports logout. Avatar upload,
password changes, notification delivery preferences, and account deletion are
separate follow-up capabilities because they require additional API and product
decisions.

## Verification

Run:

```bash
flutter test test/client_profile_test.dart
```

The tests cover response mapping, trimmed update payloads, account ownership,
session expiry, and the edit/save interface.
