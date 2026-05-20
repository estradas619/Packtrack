import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/package_model.dart';
import '../../detail/screens/package_detail_screen.dart';

/// Card widget that groups packages by order/purchase.
class OrderGroupCard extends StatelessWidget {
  final OrderModel order;

  const OrderGroupCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
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
          // ─── Order Header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Order icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.overallStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(order.overallStatus),
                    size: 16,
                    color: _getStatusColor(order.overallStatus),
                  ),
                ),
                const SizedBox(width: 12),
                // Order name and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.deliveredCount}/${order.totalCount} ${l10n.translate('packages_count', params: {'count': '${order.totalCount}'})}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // ETA
                if (order.nearestDelivery != null)
                  _buildETABadge(context, order.nearestDelivery!),
              ],
            ),
          ),

          // ─── Progress Bar ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: order.progress,
                backgroundColor: AppTheme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(order.overallStatus),
                ),
                minHeight: 3,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ─── Package List ────────────────────────────────────────────
          ...order.packages.map((pkg) => _PackageRow(package: pkg)),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildETABadge(BuildContext context, DateTime eta) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = eta.difference(now);

    String label;
    Color color;

    if (diff.isNegative) {
      label = l10n.translate('status_delivered');
      color = AppTheme.statusDelivered;
    } else if (diff.inDays == 0) {
      label = l10n.today;
      color = AppTheme.statusOutForDelivery;
    } else if (diff.inDays == 1) {
      label = l10n.tomorrow;
      color = AppTheme.statusInTransit;
    } else {
      label = '${diff.inDays}d';
      color = AppTheme.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(PackageStatus status) {
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

  IconData _getStatusIcon(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return Icons.schedule_rounded;
      case PackageStatus.inTransit:
        return Icons.local_shipping_rounded;
      case PackageStatus.inCustoms:
        return Icons.gavel_rounded;
      case PackageStatus.outForDelivery:
        return Icons.delivery_dining_rounded;
      case PackageStatus.delivered:
        return Icons.check_circle_rounded;
      case PackageStatus.exception:
        return Icons.error_rounded;
      case PackageStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }
}

/// Individual package row within an order card.
class _PackageRow extends StatelessWidget {
  final PackageModel package;

  const _PackageRow({required this.package});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PackageDetailScreen(package: package),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(package.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Tracking info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.trackingNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${package.carrier} • ${_getStatusText(context, package.status)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(BuildContext context, PackageStatus status) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.statusText(status.key);
  }

  Color _getStatusColor(PackageStatus status) {
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
