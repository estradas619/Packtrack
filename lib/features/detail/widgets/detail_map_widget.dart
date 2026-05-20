import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/package_model.dart';

/// Expanded interactive map showing the full route of a package.
/// Uses a pure Flutter CustomPainter visualization (no external map package).
class DetailMapWidget extends StatelessWidget {
  final PackageModel package;

  const DetailMapWidget({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholderMap();
  }

  /// Placeholder map with visual route representation.
  Widget _buildPlaceholderMap() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0.08),
            AppTheme.primaryColor.withOpacity(0.15),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            painter: _DetailMapGridPainter(),
            size: Size.infinite,
          ),
          // Route visualization
          CustomPaint(
            painter: _DetailRoutePainter(
              events: package.events,
              status: package.status,
            ),
            size: Size.infinite,
          ),
          // Status overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping_rounded,
                    color: _getStatusColor(package.status),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          package.origin ?? 'Origin',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          package.destination ?? 'Destination',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(package.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(package.status.progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(package.status),
                      ),
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

/// Painter for the map grid background.
class _DetailMapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.dividerColor.withOpacity(0.4)
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (var i = 0; i <= 12; i++) {
      final y = size.height * (i / 12);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (var i = 0; i <= 16; i++) {
      final x = size.width * (i / 16);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for the route visualization.
class _DetailRoutePainter extends CustomPainter {
  final List events;
  final PackageStatus status;

  _DetailRoutePainter({required this.events, required this.status});

  @override
  void paint(Canvas canvas, Size size) {
    if (events.isEmpty) return;

    final totalStops = events.length;
    final progress = status.progress;

    // Draw route path
    final routePaint = Paint()
      ..color = AppTheme.dividerColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final activePath = Path();

    // Generate points along a curve
    final points = <Offset>[];
    for (var i = 0; i < totalStops; i++) {
      final t = i / (totalStops - 1).clamp(1, totalStops);
      final x = size.width * 0.1 + (size.width * 0.8 * t);
      final y = size.height * 0.5 +
          (size.height * 0.15 * (i.isEven ? -1 : 1)) *
              (1 - (t - 0.5).abs() * 2);
      points.add(Offset(x, y));
    }

    // Draw full route
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final midX = (prev.dx + curr.dx) / 2;
        path.quadraticBezierTo(prev.dx, prev.dy, midX, (prev.dy + curr.dy) / 2);
      }
      path.lineTo(points.last.dx, points.last.dy);
      canvas.drawPath(path, routePaint);
    }

    // Draw active portion
    final activeStops = (totalStops * progress).ceil().clamp(0, totalStops);
    if (activeStops > 0 && points.isNotEmpty) {
      activePath.moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < activeStops && i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final midX = (prev.dx + curr.dx) / 2;
        activePath.quadraticBezierTo(
            prev.dx, prev.dy, midX, (prev.dy + curr.dy) / 2);
      }
      if (activeStops < points.length) {
        activePath.lineTo(
            points[activeStops - 1].dx, points[activeStops - 1].dy);
      }
      canvas.drawPath(activePath, activePaint);
    }

    // Draw stop dots
    for (var i = 0; i < points.length; i++) {
      final isActive = i < activeStops;
      final isCurrent = i == activeStops - 1;

      canvas.drawCircle(
        points[i],
        isCurrent ? 8 : 5,
        Paint()
          ..color = isActive ? AppTheme.primaryColor : AppTheme.dividerColor,
      );

      if (isActive) {
        canvas.drawCircle(
          points[i],
          isCurrent ? 4 : 2.5,
          Paint()..color = Colors.white,
        );
      }
    }

    // Draw destination marker
    if (points.isNotEmpty) {
      final dest = points.last;
      canvas.drawCircle(
        dest,
        8,
        Paint()..color = AppTheme.secondaryColor,
      );
      canvas.drawCircle(
        dest,
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
