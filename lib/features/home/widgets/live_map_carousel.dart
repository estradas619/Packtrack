import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/package_model.dart';
import '../../../data/providers/tracking_provider.dart';

/// Carousel widget showing a live map focused on the nearest delivery.
class LiveMapCarousel extends StatefulWidget {
  const LiveMapCarousel({super.key});

  @override
  State<LiveMapCarousel> createState() => _LiveMapCarouselState();
}

class _LiveMapCarouselState extends State<LiveMapCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.92,
  );
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<TrackingProvider>(
      builder: (context, provider, _) {
        final activePackages = provider.activePackages;
        if (activePackages.isEmpty) return const SizedBox.shrink();

        // Sort by nearest delivery
        final sorted = List<PackageModel>.from(activePackages)
          ..sort((a, b) {
            if (a.estimatedDelivery == null) return 1;
            if (b.estimatedDelivery == null) return -1;
            return a.estimatedDelivery!.compareTo(b.estimatedDelivery!);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.statusOutForDelivery,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.mapTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Map Carousel
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: sorted.length.clamp(0, 3),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _MapCard(package: sorted[index]),
                  );
                },
              ),
            ),

            // Page indicator dots
            if (sorted.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    sorted.length.clamp(0, 3),
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == index ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Individual map card showing package location and route.
class _MapCard extends StatelessWidget {
  final PackageModel package;

  const _MapCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasCoordinates = package.currentLatitude != null &&
        package.currentLongitude != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        color: Colors.white,
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasCoordinates)
            _buildMapPlaceholder()
          else
            _buildNoLocationPlaceholder(),

          // Gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          package.orderName ?? package.trackingNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          package.carrier,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (package.estimatedDelivery != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: package.isArrivingToday
                            ? AppTheme.secondaryColor
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        package.isArrivingToday
                            ? l10n.today
                            : _formatETA(package.estimatedDelivery!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Live indicator
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.primaryColor.withOpacity(0.15),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _MapRoutePainter(
          currentLat: package.currentLatitude!,
          currentLng: package.currentLongitude!,
          destLat: package.destinationLatitude ?? package.currentLatitude!,
          destLng: package.destinationLongitude ?? package.currentLongitude!,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildNoLocationPlaceholder() {
    return Container(
      color: AppTheme.backgroundGrey,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 32,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: 4),
            Text(
              'Location updating...',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatETA(DateTime eta) {
    final now = DateTime.now();
    final diff = eta.difference(now);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    return '${diff.inDays}d';
  }
}

/// Custom painter to draw a simplified route on the map placeholder.
class _MapRoutePainter extends CustomPainter {
  final double currentLat;
  final double currentLng;
  final double destLat;
  final double destLng;

  _MapRoutePainter({
    required this.currentLat,
    required this.currentLng,
    required this.destLat,
    required this.destLng,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.6);
    path.cubicTo(
      size.width * 0.35, size.height * 0.3,
      size.width * 0.65, size.height * 0.7,
      size.width * 0.85, size.height * 0.4,
    );

    canvas.drawPath(path, paint);

    final traveledPath = Path();
    traveledPath.moveTo(size.width * 0.15, size.height * 0.6);
    traveledPath.cubicTo(
      size.width * 0.35, size.height * 0.3,
      size.width * 0.45, size.height * 0.5,
      size.width * 0.55, size.height * 0.5,
    );
    canvas.drawPath(traveledPath, dashPaint);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.6),
      5,
      Paint()..color = AppTheme.textTertiary,
    );

    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.5),
      7,
      Paint()..color = AppTheme.primaryColor,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.5),
      4,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.4),
      6,
      Paint()..color = AppTheme.secondaryColor,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.4),
      3,
      Paint()..color = Colors.white,
    );

    final gridPaint = Paint()
      ..color = AppTheme.dividerColor.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (var i = 0; i < 8; i++) {
      final y = size.height * (i / 8);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var i = 0; i < 12; i++) {
      final x = size.width * (i / 12);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
