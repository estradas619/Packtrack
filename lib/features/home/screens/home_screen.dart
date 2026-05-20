import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/tracking_provider.dart';
import '../../../data/providers/search_history_provider.dart';
import '../widgets/smart_search_bar.dart';
import '../widgets/live_map_carousel.dart';
import '../widgets/order_group_card.dart';
import '../widgets/language_selector.dart';
import '../widgets/empty_state_widget.dart';
import '../../extras/screens/extras_screen.dart';

/// Main home screen with search bar, live map, and grouped orders.
/// Completely clean — no ads, no clutter. Only packages.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().initialize();
      context.read<SearchHistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TrackingProvider>().refreshAll(),
          color: AppTheme.primaryColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ─── Header with Language Selector + Profile ─────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      // User greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeTitle,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      // Language selector
                      const LanguageSelector(),
                      const SizedBox(width: 8),
                      // Profile / Extras menu
                      const _ProfileMenu(),
                    ],
                  ),
                ),
              ),

              // ─── Smart Search Bar ──────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SmartSearchBar(),
                ),
              ),

              // ─── Live Map Carousel ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<TrackingProvider>(
                  builder: (context, provider, _) {
                    if (provider.activePackages.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: LiveMapCarousel(),
                    );
                  },
                ),
              ),

              // ─── Section Title: Orders ─────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<TrackingProvider>(
                  builder: (context, provider, _) {
                    if (provider.packages.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.allOrders,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${provider.activePackages.length}',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ─── Order Group Cards ─────────────────────────────────────
              Consumer<TrackingProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (provider.packages.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(
                        title: l10n.noPackages,
                        subtitle: l10n.noPackagesSubtitle,
                      ),
                    );
                  }

                  // Group packages by order
                  final orders = provider.orders;

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OrderGroupCard(order: orders[index]),
                          );
                        },
                        childCount: orders.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile menu button with dropdown for Extras.
class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_rounded,
          size: 18,
          color: AppTheme.primaryColor,
        ),
      ),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'extras',
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 18),
              const SizedBox(width: 10),
              Text(l10n.translate('extras_title')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_rounded, size: 18),
              const SizedBox(width: 10),
              Text(l10n.settings),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'extras':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExtrasScreen()),
        );
        break;
      case 'settings':
        // TODO: Navigate to settings screen
        break;
    }
  }
}
