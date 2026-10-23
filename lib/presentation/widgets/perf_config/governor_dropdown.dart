import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';

/// Governors compatible with Dimensity 9300+ (and other modern MediaTek SoCs).
const _kAllowedGovernors = {'performance', 'schedutil', 'powersave'};

/// Brief description for each allowed governor (bilingual: es / en).
String _governorDescription(String governor) {
  switch (governor) {
    case 'performance':
      return 'Frecuencias al máximo continuo, latencia mínima para juegos exigentes.';
    case 'schedutil':
      return 'Ajuste dinámico e inteligente según carga (equilibrado).';
    case 'powersave':
      return 'Frecuencias mínimas para máximo ahorro energético.';
    default:
      return '';
  }
}

/// Dropdown for selecting a kernel governor from a filtered list.
/// Only "performance", "schedutil" and "powersave" are shown.
class GovernorDropdown extends StatelessWidget {
  final String label;
  final String currentValue;
  final List<String> governors;
  final Color color;
  final ValueChanged<String> onChanged;

  const GovernorDropdown({
    super.key,
    required this.label,
    required this.currentValue,
    required this.governors,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Keep only allowed governors that are actually present on this device.
    final filtered = governors
        .where((g) => _kAllowedGovernors.contains(g))
        .toList();

    // Fallback: if the device reports none of the three, show them all anyway.
    final displayList = filtered.isNotEmpty ? filtered : governors;

    final safeValue =
        displayList.contains(currentValue) ? currentValue : displayList.first;

    final description = _governorDescription(safeValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacing6),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing12,
              vertical: AppConstants.spacing10,
            ),
            filled: true,
            fillColor: color.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
          ),
          dropdownColor: cs.surfaceContainerHighest,
          iconEnabledColor: color,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
          items: displayList
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacing4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
