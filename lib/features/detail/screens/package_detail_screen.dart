import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/package_model.dart';
import '../widgets/detail_map_widget.dart';
import '../widgets/tracking_timeline.dart';
import '../widgets/package_info_header.dart';
import '../widgets/contact_carrier_button.dart';

/// Detail screen showing full tracking information for a single package.
///
/// Includes the intelligent "Contact Carrier" button that activates
/// when the package has been stuck for 48+ hours without movement.
class PackageDetailScreen extends StatelessWidget {
  final PackageModel package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Custom App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            actions: [
              // Share button
              IconButton(
                onPressed: () => _shareStatus(context),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    size: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DetailMapWidget(package: package),
            ),
          ),

          // ─── Package Info Header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: PackageInfoHeader(package: package),
          ),

          // ─── Contact Carrier Button (Intelligent - 48h rule) ────────
          SliverToBoxAdapter(
            child: ContactCarrierButton(package: package),
          ),

          // ─── Timeline Section Title ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.timeline_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.timeline,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),

          // ─── Tracking Timeline ───────────────────────────────────────
          SliverToBoxAdapter(
            child: TrackingTimeline(events: package.events),
          ),

          // ─── Bottom Actions ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                children: [
                  // Copy tracking number button
                  _ActionButton(
                    icon: Icons.copy_rounded,
                    label: l10n.copyTracking,
                    onTap: () => _copyTrackingNumber(context),
                  ),
                  const SizedBox(height: 10),
                  // Share status button
                  _ActionButton(
                    icon: Icons.share_rounded,
                    label: l10n.shareStatus,
                    onTap: () => _shareStatus(context),
                    isPrimary: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyTrackingNumber(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: package.trackingNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copied),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusText = l10n.statusText(package.status.key);

    final message = l10n.translate(
      'share_message',
      params: {
        'tracking': package.trackingNumber,
        'carrier': package.carrier,
        'status': statusText,
        'link': 'https://packtrack.app/track/${package.trackingNumber}',
      },
    );

    Share.share(message, subject: 'PackTrack - ${package.trackingNumber}');
  }
}

/// Reusable action button for the detail screen.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppTheme.primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: isPrimary
                ? null
                : Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppTheme.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
