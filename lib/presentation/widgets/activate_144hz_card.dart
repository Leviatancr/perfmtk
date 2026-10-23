import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/core/providers/shell_provider.dart';

/// One-tap card that forces the display to 144 Hz via Android settings commands.
class Activate144HzCard extends ConsumerStatefulWidget {
  const Activate144HzCard({super.key});

  @override
  ConsumerState<Activate144HzCard> createState() => _Activate144HzCardState();
}

class _Activate144HzCardState extends ConsumerState<Activate144HzCard> {
  bool _busy = false;

  static const _kColor = Color(0xFFE040FB); // vivid purple accent

  Future<void> _apply144Hz() async {
    if (_busy) return;
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);

    try {
      final shell = ref.read(shellExecutorProvider);
      await shell.executeCommand(
        'settings put system peak_refresh_rate 144.0 ; '
        'settings put system min_refresh_rate 144.0 ; '
        'settings put system user_refresh_rate 144',
        timeout: const Duration(seconds: 8),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  '144 Hz aplicados',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: _kColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('Error al aplicar 144 Hz'),
            backgroundColor:
                Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: _kColor.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kColor.withValues(alpha: isDark ? 0.10 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          // ── Icon badge ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: _kColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: _busy
                ? SizedBox(
                    width: AppConstants.iconSizeLarge,
                    height: AppConstants.iconSizeLarge,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          const AlwaysStoppedAnimation(_kColor),
                    ),
                  )
                : const Icon(
                    Icons.monitor_rounded,
                    color: _kColor,
                    size: AppConstants.iconSizeLarge,
                  ),
          ),

          const SizedBox(width: AppConstants.spacing16),

          // ── Text ──────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activar 144 Hz',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Fija instantáneamente la pantalla a 144 Hz en el sistema para juegos como Minecraft.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppConstants.spacing12),

          // ── Action button ─────────────────────────────────────────────────
          FilledButton(
            onPressed: _busy ? null : _apply144Hz,
            style: FilledButton.styleFrom(
              backgroundColor: _kColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _kColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing14,
                vertical: AppConstants.spacing10,
              ),
            ),
            child: const Text(
              '144 Hz',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
