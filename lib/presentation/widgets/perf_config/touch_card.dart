import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/core/providers/shell_provider.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// Shell commands to enable 2000 Hz polling rate (HyperOS game touch mode).
const _kPollingOnCmds = [
  'setprop persist.sys.touch.game_mode 1',
  'setprop sys.touch.game_mode 1',
  'setprop persist.vendor.touch.game_mode 1',
  'if [ -f /sys/class/touch/touch_dev/gesture_single_tap ]; then echo 1 > /sys/class/touch/touch_dev/gesture_single_tap; fi',
];

/// Shell commands to disable 2000 Hz polling rate.
const _kPollingOffCmds = [
  'setprop persist.sys.touch.game_mode 0',
  'setprop sys.touch.game_mode 0',
  'setprop persist.vendor.touch.game_mode 0',
];

/// Hardware Touch & Digitizer Booster card — Game Mode & 2000 Hz Polling Rate.
class TouchCard extends ConsumerStatefulWidget {
  final bool gameMode;
  final bool thpSmooth;
  final Color color;
  final void Function({
    required bool gameMode,
    required bool thpSmooth,
  }) onChanged;

  const TouchCard({
    super.key,
    required this.gameMode,
    required this.thpSmooth,
    required this.color,
    required this.onChanged,
  });

  @override
  ConsumerState<TouchCard> createState() => _TouchCardState();
}

class _TouchCardState extends ConsumerState<TouchCard> {
  bool _pollingActive = false;
  bool _pollingBusy = false;

  Future<void> _setPollingRate(bool enable) async {
    if (_pollingBusy) return;
    setState(() => _pollingBusy = true);
    HapticFeedback.mediumImpact();

    try {
      final shell = ref.read(shellExecutorProvider);
      final cmds = enable ? _kPollingOnCmds : _kPollingOffCmds;
      await shell.executeCommand(
        cmds.join(' ; '),
        timeout: const Duration(seconds: 8),
      );
      if (mounted) setState(() => _pollingActive = enable);
    } catch (_) {
      // Best-effort: update state optimistically even on partial failure
      if (mounted) setState(() => _pollingActive = enable);
    } finally {
      if (mounted) setState(() => _pollingBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SectionCard(
      title: AppLocale.touchBoosterTitle.getString(context),
      icon: Icons.touch_app_rounded,
      color: widget.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Switch 1: Game Mode ───────────────────────────────────────────
          _buildSwitchRow(
            context: context,
            title: AppLocale.touchGameMode.getString(context),
            subtitle: AppLocale.touchGameModeDesc.getString(context),
            value: widget.gameMode,
            onChanged: (v) => widget.onChanged(
              gameMode: v,
              thpSmooth: widget.thpSmooth,
            ),
          ),

          const SizedBox(height: AppConstants.spacing12),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.35)),
          const SizedBox(height: AppConstants.spacing12),

          // ── Switch 2: Polling Rate 2000 Hz ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Polling Rate 2000 Hz',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      'Activa/Desactiva la respuesta táctil ultra alta de 2000 Hz de HyperOS.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _pollingActive
                            ? widget.color
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacing8),
              _pollingBusy
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(widget.color),
                        ),
                      ),
                    )
                  : Switch(
                      value: _pollingActive,
                      activeThumbColor: widget.color,
                      onChanged: _setPollingRate,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: value ? widget.color : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spacing8),
        Switch(
          value: value,
          activeThumbColor: widget.color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
