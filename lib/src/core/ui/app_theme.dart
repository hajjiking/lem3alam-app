import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../networking/dio_provider.dart';

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';
  var _loaded = false;

  @override
  ThemeMode build() {
    if (!_loaded) {
      _loaded = true;
      Future.microtask(load);
    }
    return ThemeMode.system;
  }

  Brightness get effectiveBrightness {
    final platform = PlatformDispatcher.instance.platformBrightness;
    return switch (state) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platform,
    };
  }

  Future<void> load() async {
    final storage = ref.read(secureStorageProvider);
    final value = await storage.read(key: _key);
    if (value == null || value.isEmpty) return;
    if (!ref.mounted) return;
    state = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final storage = ref.read(secureStorageProvider);
    await storage.write(
      key: _key,
      value: switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> toggle() async {
    final currentlyDark = effectiveBrightness == Brightness.dark;
    await setThemeMode(currentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}

abstract class AppTheme {
  static ThemeData light() => _theme(_lightScheme, _lightTokens);

  static ThemeData dark() => _theme(_darkScheme, _darkTokens);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Lem3alamColors.primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD9E6FF),
    onPrimaryContainer: Color(0xFF0A255C),
    secondary: Lem3alamColors.secondaryBlue,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDBEAFE),
    onSecondaryContainer: Color(0xFF0B3A94),
    tertiary: Lem3alamColors.accentGreen,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFCCFBDE),
    onTertiaryContainer: Color(0xFF04492F),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Lem3alamColors.background,
    onSurface: Lem3alamColors.text,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFF4F7FB),
    surfaceContainer: Color(0xFFEEF2F7),
    surfaceContainerHigh: Color(0xFFE6ECF3),
    surfaceContainerHighest: Color(0xFFDDE5EF),
    onSurfaceVariant: Color(0xFF4B5563),
    outline: Color(0xFF93A4BA),
    outlineVariant: Color(0xFFC5D0DD),
    shadow: Color(0x1A0F2A50),
    scrim: Color(0x660B1F3A),
    inverseSurface: Color(0xFF1A2540),
    onInverseSurface: Color(0xFFF3F6FB),
    inversePrimary: Color(0xFFB5C9FF),
    surfaceTint: Lem3alamColors.primaryBlue,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB5C9FF),
    onPrimary: Color(0xFF06214F),
    primaryContainer: Color(0xFF143B85),
    onPrimaryContainer: Color(0xFFDBE3FF),
    secondary: Color(0xFF93B8FF),
    onSecondary: Color(0xFF07255A),
    secondaryContainer: Color(0xFF103577),
    onSecondaryContainer: Color(0xFFD8E5FF),
    tertiary: Color(0xFF86E7B9),
    onTertiary: Color(0xFF003825),
    tertiaryContainer: Color(0xFF025134),
    onTertiaryContainer: Color(0xFFBFF5DA),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0F172A),
    onSurface: Color(0xFFE6ECF5),
    surfaceContainerLowest: Color(0xFF0A1020),
    surfaceContainerLow: Color(0xFF111B32),
    surfaceContainer: Color(0xFF142141),
    surfaceContainerHigh: Color(0xFF1B2B52),
    surfaceContainerHighest: Color(0xFF233668),
    onSurfaceVariant: Color(0xFFC1C9D6),
    outline: Color(0xFF7986A3),
    outlineVariant: Color(0xFF3E4A6B),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE6ECF5),
    onInverseSurface: Color(0xFF162343),
    inversePrimary: Lem3alamColors.primaryBlue,
    surfaceTint: Color(0xFFB5C9FF),
  );

  static const _lightTokens = Lem3alamThemeTokens(
    warning: Color(0xFF946200),
    success: Color(0xFF087F5B),
    info: Color(0xFF087F8C),
    accentPurple: Color(0xFF6D4AFF),
    headerStart: Color(0xFF075DF5),
    headerEnd: Color(0xFF0052E8),
    archLine: Color(0x1F0E355A),
  );

  static const _darkTokens = Lem3alamThemeTokens(
    warning: Color(0xFFF4B860),
    success: Color(0xFF8FD8C7),
    info: Color(0xFF56D2D6),
    accentPurple: Color(0xFFA88CFF),
    headerStart: Color(0xFF0B3F9F),
    headerEnd: Color(0xFF062D78),
    archLine: Color(0x33C8E8E8),
  );

  static ThemeData _theme(ColorScheme colorScheme, Lem3alamThemeTokens tokens) {
    final baseTextTheme = ThemeData(
      brightness: colorScheme.brightness,
      useMaterial3: true,
      fontFamily: 'Cairo',
    ).textTheme;

    final textTheme = baseTextTheme
        .copyWith(
          displayLarge: baseTextTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.8,
          ),
          displayMedium: baseTextTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.4,
          ),
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          titleSmall: baseTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            height: 1.55,
          ),
          bodySmall: baseTextTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
          labelMedium: baseTextTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          labelSmall: baseTextTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    const buttonRadius = AppStyle.controlRadius;
    final fieldRadius = BorderRadius.circular(AppStyle.controlRadius);
    final cardRadius = BorderRadius.circular(AppStyle.cardRadius);
    final buttonShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius));
    final cardShape = RoundedRectangleBorder(borderRadius: cardRadius);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[tokens],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLowest,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: Colors.transparent,
        shape: cardShape.copyWith(
          side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: colorScheme.outlineVariant,
        dragHandleSize: const Size(40, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 2,
        insetPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppStyle.controlHeight),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppStyle.controlHeight),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.2),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, AppStyle.controlHeight),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        floatingLabelStyle: textTheme.bodyMedium
            ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 1.8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest,
        side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.75)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle:
            textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
            color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.10),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle:
            textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
        unselectedLabelStyle:
            textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
        linearMinHeight: 6,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicatorColor: colorScheme.primary,
        dividerColor: colorScheme.outlineVariant,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
        shape: buttonShape,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 24,
      ),
    );
  }
}

/// Shared geometry for both Material controls and custom feature widgets.
abstract final class AppStyle {
  static const double pagePadding = 16;
  static const double cardPadding = 18;
  static const double cardRadius = 22;
  static const double controlRadius = 16;
  static const double sheetRadius = 28;
  static const double controlHeight = 52;

  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: context.appColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: context.appColors.outlineVariant.withValues(alpha: 0.6),
        ),
      );
}

extension AppThemeContext on BuildContext {
  ColorScheme get appColors => Theme.of(this).colorScheme;
  Lem3alamThemeTokens get appTokens =>
      Theme.of(this).extension<Lem3alamThemeTokens>() ??
      (appColors.brightness == Brightness.dark
          ? AppTheme._darkTokens
          : AppTheme._lightTokens);
}

abstract final class Lem3alamColors {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF111827);

  static const Color moroccanNavy = Color(0xFF0E355A);
  static const Color teal = Color(0xFF11999E);
  static const Color turquoise = Color(0xFF00ADB5);
  static const Color mint = Color(0xFF8FD3C1);
  static const Color marrakeshGold = Color(0xFFE69A2E);
  static const Color mintWhite = Color(0xFFF8FBFB);
  static const Color darkPetrol = Color(0xFF1A2E3B);
}

@immutable
class Lem3alamThemeTokens extends ThemeExtension<Lem3alamThemeTokens> {
  const Lem3alamThemeTokens({
    required this.warning,
    required this.success,
    required this.info,
    required this.accentPurple,
    required this.headerStart,
    required this.headerEnd,
    required this.archLine,
  });

  final Color warning;
  final Color success;
  final Color info;
  final Color accentPurple;
  final Color headerStart;
  final Color headerEnd;
  final Color archLine;

  @override
  Lem3alamThemeTokens copyWith({
    Color? warning,
    Color? success,
    Color? info,
    Color? accentPurple,
    Color? headerStart,
    Color? headerEnd,
    Color? archLine,
  }) {
    return Lem3alamThemeTokens(
      warning: warning ?? this.warning,
      success: success ?? this.success,
      info: info ?? this.info,
      accentPurple: accentPurple ?? this.accentPurple,
      headerStart: headerStart ?? this.headerStart,
      headerEnd: headerEnd ?? this.headerEnd,
      archLine: archLine ?? this.archLine,
    );
  }

  @override
  Lem3alamThemeTokens lerp(
      ThemeExtension<Lem3alamThemeTokens>? other, double t) {
    if (other is! Lem3alamThemeTokens) {
      return this;
    }

    return Lem3alamThemeTokens(
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      success: Color.lerp(success, other.success, t) ?? success,
      info: Color.lerp(info, other.info, t) ?? info,
      accentPurple:
          Color.lerp(accentPurple, other.accentPurple, t) ?? accentPurple,
      headerStart: Color.lerp(headerStart, other.headerStart, t) ?? headerStart,
      headerEnd: Color.lerp(headerEnd, other.headerEnd, t) ?? headerEnd,
      archLine: Color.lerp(archLine, other.archLine, t) ?? archLine,
    );
  }
}
