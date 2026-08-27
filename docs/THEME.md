# App styling

`lib/src/core/ui/app_theme.dart` is the shared source for the light and dark palettes, Cairo typography, Material controls, and geometry. Keep screen-specific colors out of feature widgets.

- Use `Theme.of(context).textTheme` for text and `context.appColors` for surfaces, content, and actions.
- Use `context.appTokens` for warning, success, information, and decorative header accents.
- Use `AppSectionCard` or `AppStyle.cardDecoration(context)` for section surfaces; inherit button and input styles from the theme.
- Use `AppStyle` for common page padding, card padding, and corner radii. Let content grow at larger text scales instead of fixing its height.
- Task badges share the mappings in `features/tasks/presentation/task_style.dart`.
- White/black media overlays, the camera preview, and third-party brand marks intentionally retain their own colors.

Cairo is bundled in `assets/fonts/Cairo.ttf`, supports Arabic/Latin text, and does not require a network request. Source: [Google Fonts Cairo](https://github.com/google/fonts/tree/main/ofl/cairo). The accompanying SIL Open Font License is included and registered in the app's license registry.

## Verification

```sh
flutter test test/theme_consistency_test.dart
flutter test test/theme_consistency_test.dart --dart-define=THEME_SNAPSHOTS=true
```

The optional second command renders local previews into `build/theme_preview/`. Tests cover light/dark controls, compact RTL forms, larger text, shared cards, calendar selection, and all profile tabs.
