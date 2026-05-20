import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../widgets/premium_card.dart';
import '../widgets/micro_insurance_card.dart';
import '../widgets/affiliate_offers_card.dart';
import '../widgets/carrier_partnerships_card.dart';
import '../widgets/business_analytics_card.dart';

/// Extras screen containing monetization options presented elegantly.
///
/// This screen is only accessible "on demand" — it does NOT clutter
/// the main dashboard. Options are presented as clean, informative cards.
class ExtrasScreen extends StatelessWidget {
  const ExtrasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.translate('extras_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Section Header ──────────────────────────────────────────
            Text(
              l10n.translate('extras_subtitle'),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // ─── Premium Subscription ────────────────────────────────────
            const PremiumCard(),

            const SizedBox(height: 16),

            // ─── Micro Insurance ─────────────────────────────────────────
            const MicroInsuranceCard(),

            const SizedBox(height: 16),

            // ─── Affiliate Offers ────────────────────────────────────────
            const AffiliateOffersCard(),

            const SizedBox(height: 16),

            // ─── Carrier Partnerships ────────────────────────────────────
            const CarrierPartnershipsCard(),

            const SizedBox(height: 16),

            // ─── Business Analytics (for power users) ────────────────────
            const BusinessAnalyticsCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
