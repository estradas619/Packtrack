import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/package_model.dart';
import '../../../services/support/carrier_support_service.dart';

/// Intelligent "Contact Carrier" button that appears in the detail screen.
///
/// This button is only visible/active when the package has been stuck
/// for 48+ hours without movement. It copies the tracking number to
/// the clipboard and opens the phone dialer with the carrier's
/// customer service number.
class ContactCarrierButton extends StatelessWidget {
  final PackageModel package;

  const ContactCarrierButton({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isStuck = CarrierSupportService.isPackageStuck(package);
    final hoursSince =
        CarrierSupportService.getHoursSinceLastMovement(package);
    final contact = CarrierSupportService.getContact(package.carrier);

    // Don't show if package is delivered or not stuck
    if (package.isDelivered) return const SizedBox.shrink();

    // Show in disabled state if not stuck yet, active if stuck 48h+
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: isStuck
            ? AppTheme.accentColor.withOpacity(0.08)
            : AppTheme.backgroundGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InkWell(
          onTap: isStuck ? () => _handleContact(context) : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: isStuck
                    ? AppTheme.accentColor.withOpacity(0.3)
                    : AppTheme.dividerColor.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isStuck
                        ? AppTheme.accentColor.withOpacity(0.15)
                        : AppTheme.dividerColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.phone_in_talk_rounded,
                    size: 20,
                    color: isStuck
                        ? AppTheme.accentColor
                        : AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(width: 14),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('contact_carrier'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isStuck
                              ? AppTheme.textPrimary
                              : AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isStuck
                            ? l10n.translate(
                                'stuck_hours',
                                params: {'hours': hoursSince.toString()},
                              )
                            : l10n.translate('contact_carrier_inactive'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isStuck
                              ? AppTheme.accentColor
                              : AppTheme.textTertiary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow or lock icon
                Icon(
                  isStuck
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.lock_outline_rounded,
                  size: 14,
                  color: isStuck
                      ? AppTheme.textSecondary
                      : AppTheme.textTertiary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContact(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contact = CarrierSupportService.getContact(package.carrier);

    if (contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('carrier_contact_unavailable')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show confirmation bottom sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ContactBottomSheet(
        package: package,
        contact: contact,
      ),
    );
  }
}

/// Bottom sheet shown when user taps the contact button.
class _ContactBottomSheet extends StatelessWidget {
  final PackageModel package;
  final CarrierContact contact;

  const _ContactBottomSheet({
    required this.package,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            l10n.translate('contact_carrier_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate(
              'contact_carrier_desc',
              params: {'carrier': package.carrier},
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Info card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _InfoLine(
                  icon: Icons.tag_rounded,
                  label: l10n.translate('tracking_number'),
                  value: package.trackingNumber,
                ),
                const SizedBox(height: 10),
                _InfoLine(
                  icon: Icons.phone_rounded,
                  label: l10n.translate('phone_number'),
                  value: contact.bestPhone ?? '-',
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // Note about clipboard
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.translate('tracking_copied_note'),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Call button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      CarrierSupportService.contactCarrier(
                        package: package,
                        region: 'MX',
                      );
                    },
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: Text(l10n.translate('call_now')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Website button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      CarrierSupportService.openSupportWebsite(
                        package.carrier,
                      );
                    },
                    icon: const Icon(Icons.language_rounded, size: 18),
                    label: Text(l10n.translate('visit_website')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Info line in the contact bottom sheet.
class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
