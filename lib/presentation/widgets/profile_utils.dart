import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';

/// Utilidad centralizada para propiedades visuales de perfiles.
/// Elimina la lógica duplicada que existía en 5+ widgets.
abstract final class ProfileUtils {
  static String nameFor(BuildContext context, ProfileType profile) {
    final key = switch (profile) {
      ProfileType.performance => AppLocale.performance,
      ProfileType.balanced => AppLocale.balanced,
    };
    return key.getString(context);
  }

  static String shortNameFor(BuildContext context, ProfileType profile) {
    final key = switch (profile) {
      ProfileType.performance => AppLocale.tabPerf,
      ProfileType.balanced => AppLocale.tabBalanced,
    };
    return key.getString(context);
  }

  static String cardNameFor(BuildContext context, ProfileType profile) {
    final key = switch (profile) {
      ProfileType.performance => AppLocale.cardPerformance,
      ProfileType.balanced => AppLocale.cardBalanced,
    };
    return key.getString(context);
  }

  static String tagFor(BuildContext context, ProfileType profile) {
    final key = switch (profile) {
      ProfileType.performance => AppLocale.cardTagPerformance,
      ProfileType.balanced => AppLocale.cardTagBalanced,
    };
    return key.getString(context);
  }

  // ── Color ─────────────────────────────────────────────────────────────────
  static Color colorFor(ProfileType? profile, {bool isDark = true}) {
    if (isDark) {
      switch (profile) {
        case ProfileType.performance:
          return const Color(0xFFFF6B35);
        case ProfileType.balanced:
          return const Color(0xFF4A9EFF);
        case null:
          return const Color(0xFF8E99A4);
      }
    } else {
      switch (profile) {
        case ProfileType.performance:
          return const Color(0xFFEA580C); // Warm refined flame orange (WCAG AA compliant)
        case ProfileType.balanced:
          return const Color(0xFF2563EB); // Refined Dimensity tech royal blue
        case null:
          return const Color(0xFF64748B); // Slate 500
      }
    }
  }

  static Color colorForContext(BuildContext context, ProfileType? profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return colorFor(profile, isDark: isDark);
  }

  // ── Icon ──────────────────────────────────────────────────────────────────
  static IconData iconFor(ProfileType? profile) {
    switch (profile) {
      case ProfileType.performance:
        return Icons.bolt_rounded;
      case ProfileType.balanced:
        return Icons.balance_rounded;
      case null:
        return Icons.settings_applications_rounded;
    }
  }

  // ── Gradient ──────────────────────────────────────────────────────────────
  static List<Color> gradientFor(ProfileType? profile, {bool isDark = true}) {
    final base = colorFor(profile, isDark: isDark);
    if (!isDark) {
      return [base, base.withValues(alpha: 0.85)];
    }
    switch (profile) {
      case ProfileType.performance:
        return [const Color(0xFFFF6B35), const Color(0xFFFF3B00)];
      case ProfileType.balanced:
        return [const Color(0xFF4A9EFF), const Color(0xFF1A6FD4)];
      case null:
        return [base, base.withValues(alpha: 0.7)];
    }
  }
}
