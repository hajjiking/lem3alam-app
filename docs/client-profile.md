# Client profile and account settings

Authenticated clients can open `/profile` from the Profile item in the bottom
navigation. The screen uses live account data and does not display fixture or
derived contact information.

## Backend contract

- `GET /api/v1/profile` returns the authenticated user's profile under `data`.
- `PUT /api/v1/profile` accepts `name`, `email`, `phone`, and `location`.
- `POST /api/v1/profile/avatar` accepts one JPG, JPEG, PNG, or GIF image under
  2 MB as multipart field `avatar`.
- `DELETE /api/v1/profile/avatar` removes the authenticated user's photo.
- The response must contain the updated authenticated user under `data`.

The mobile repository verifies that the returned profile ID still matches the
active client account. A `401` expires only the matching session, and switching
accounts while a request is running prevents the old response from being shown.
Laravel validation errors are displayed on the corresponding edit fields.

## Included settings

The profile screen supports profile-photo upload/removal, links to notifications
and language selection, toggles the existing light/dark appearance setting, and
supports logout. Password changes, notification delivery preferences, and
account deletion are separate follow-up capabilities because they require
additional API and product decisions.

## Identity verification

The profile loads `GET /api/v1/kyc/documents` and shows the authenticated
client's verified, pending, rejected, or not-submitted state. Rejection reasons
are shown without exposing stored document paths.

Clients can submit an ID card, passport, driver licence, identity selfie, or
proof of address through `POST /api/v1/kyc/documents`. The app accepts one JPG,
JPEG, PNG, or PDF file up to 5 MB, reads it with a bounded stream, and sends it
as multipart field `document` with the selected `type`. A successful submission
reloads server state and displays the pending review status.

## Verification

Run:

```bash
flutter test test/client_profile_test.dart test/client_kyc_test.dart
```

The tests cover response mapping, trimmed update payloads, account ownership,
session expiry, and the edit/save interface.
