import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

/// Affiliate offers card showing contextual partner deals.
///
/// Non-intrusive affiliate marketing that only appears in the
/// extras section, never on the main dashboard.
class AffiliateOffersCard extends StatelessWidget {
  const AffiliateOffersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBC04).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: Color(0xFFFBBC04),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('affiliate_title'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.translate('affiliate_subtitle'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sample offers
            _OfferItem(
              icon: Icons.inventory_2_outlined,
              title: l10n.translate('affiliate_offer_1_title'),
              description: l10n.translate('affiliate_offer_1_desc'),
              discount: '15% OFF',
            ),
            const SizedBox(height: 10),
            _OfferItem(
              icon: Icons.lock_outline_rounded,
              title: l10n.translate('affiliate_offer_2_title'),
              description: l10n.translate('affiliate_offer_2_desc'),
              discount: '20% OFF',
            ),
            const SizedBox(height: 10),
            _OfferItem(
              icon: Icons.store_rounded,
              title: l10n.translate('affiliate_offer_3_title'),
              description: l10n.translate('affiliate_offer_3_desc'),
              discount: 'Free Trial',
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String discount;

  const _OfferItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              discount,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
