# lem3alam_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API Base URL (Mobile)

The app reads the API base URL from a compile-time define:

- `API_BASE_URL` (defaults to `https://lem3alam.ma/public/api/v1/`)

Example (Android emulator pointing to local XAMPP/Laravel on the host machine):

```bash
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2/m3alam/public/api/v1/
```

## Navigation & Routes

This app uses `GoRouter` (Navigator 2.0) with an indexed-stack shell for the primary bottom navigation tabs.

### Primary tabs

- Tasks: `/tasks`
- Dashboard: `/dashboard` (requires authentication)

### Standalone routes

- Splash: `/splash`
- Login: `/login`
- Register: `/register`

### Task routes

- Task list: `/tasks`
- Task detail: `/tasks/:id`
- Create task: `/tasks/create` (requires authentication)
- Edit task: `/tasks/:id/edit` (requires authentication)

### Deep links

Android and iOS are configured to accept a custom URL scheme:

- `lem3alam://app/tasks`
- `lem3alam://app/tasks/123`
- `lem3alam://app/tasks/123/edit`

## Navigation Testing Scenarios

- Unauthenticated startup redirects from `/splash` to `/tasks`
- Dashboard tab tap while unauthenticated routes to `/login`
- Authenticated startup redirects from `/splash` to `/dashboard`
- Branch back stack: from `/tasks` → `/tasks/:id` → back returns to `/tasks`
- Tab switching preserves branch stacks (Tasks and Dashboard keep their own history)
- Rapid transitions: quickly switching tabs and triggering route changes does not crash or produce assertion errors
- Interrupted flows: open Login, press back, confirm returning to previous page without losing app state
