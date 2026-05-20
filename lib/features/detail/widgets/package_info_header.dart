import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/package_model.dart';

/// Header section in the detail screen showing key package information.
class PackageInfoHeader extends StatelessWidget {
  final PackageModel package;

  const PackageInfoHeader({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Package Name & Status Badge ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (package.orderName != null)
                      Text(
                        package.orderName!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      package.carrier,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: package.status),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ─── Info Grid ───────────────────────────────────────────────
          _InfoRow(
            icon: Icons.tag_rounded,
            label: l10n.trackingNumber,
            value: package.trackingNumber,
            isMonospace: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.flight_takeoff_rounded,
                  label: l10n.origin,
                  value: package.origin ?? '-',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoRow(
                  icon: Icons.flight_land_rounded,
                  label: l10n.destination,
                  value: package.destination ?? '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: l10n.estimatedDelivery,
            value: package.estimatedDelivery != null
                ? dateFormat.format(package.estimatedDelivery!)
                : '-',
            valueColor: package.isArrivingToday
                ? AppTheme.statusOutForDelivery
                : null,
          ),

          // ─── Progress Bar ────────────────────────────────────────────
          const SizedBox(height: 16),
          _ProgressSection(package: package),
        ],
      ),
    );
  }
}

/// Status badge widget.
class _StatusBadge extends StatelessWidget {
  final PackageStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getColor().withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            l10n.statusText(status.key),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case PackageStatus.pending:
        return AppTheme.textTertiary;
      case PackageStatus.inTransit:
        return AppTheme.statusInTransit;
      case PackageStatus.inCustoms:
        return AppTheme.statusInCustoms;
      case PackageStatus.outForDelivery:
        return AppTheme.statusOutForDelivery;
      case PackageStatus.delivered:
        return AppTheme.statusDelivered;
      case PackageStatus.exception:
        return AppTheme.statusException;
      case PackageStatus.unknown:
        return AppTheme.textTertiary;
    }
  }
}

/// Information row with icon, label, and value.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppTheme.textPrimary,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Progress section showing delivery progress.
class _ProgressSection extends StatelessWidget {
  final PackageModel package;

  const _ProgressSection({required this.package});

  @override
  Widget build(BuildContext context) {
    final progress = package.status.progress;

    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.backgroundGrey,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(package.status),
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        // Progress labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ProgressLabel(
              label: 'Picked Up',
              isActive: progress >= 0.1,
            ),
            _ProgressLabel(
              label: 'In Transit',
              isActive: progress >= 0.4,
            ),
            _ProgressLabel(
              label: 'Out for Delivery',
              isActive: progress >= 0.8,
            ),
            _ProgressLabel(
              label: 'Delivered',
              isActive: progress >= 1.0,
            ),
          ],
        ),
      ],
    );
  }

  Color _getProgressColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.delivered:
        return AppTheme.statusDelivered;
      case PackageStatus.outForDelivery:
        return AppTheme.statusOutForDelivery;
      case PackageStatus.exception:
        return AppTheme.statusException;
      default:
        return AppTheme.primaryColor;
    }
  }
}

/// Individual progress label.
class _ProgressLabel extends StatelessWidget {
  final String label;
  final bool isActive;

  const _ProgressLabel({
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        color: isActive ? AppTheme.textPrimary : AppTheme.textTertiary,
      ),
    );
  }
}
