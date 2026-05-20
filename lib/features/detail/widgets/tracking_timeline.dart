import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/tracking_event_model.dart';

/// Vertical timeline widget showing all tracking events for a package.
class TrackingTimeline extends StatelessWidget {
  final List<TrackingEventModel> events;

  const TrackingTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No tracking events available',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Sort events by timestamp (most recent first)
    final sortedEvents = List<TrackingEventModel>.from(events)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(sortedEvents.length, (index) {
          final event = sortedEvents[index];
          final isFirst = index == 0;
          final isLast = index == sortedEvents.length - 1;

          return _TimelineItem(
            event: event,
            isFirst: isFirst,
            isLast: isLast,
            isActive: isFirst,
          );
        }),
      ),
    );
  }
}

/// Individual timeline item representing a single tracking event.
class _TimelineItem extends StatelessWidget {
  final TrackingEventModel event;
  final bool isFirst;
  final bool isLast;
  final bool isActive;

  const _TimelineItem({
    required this.event,
    required this.isFirst,
    required this.isLast,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Timeline Rail ───────────────────────────────────────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top connector line
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: AppTheme.dividerColor,
                  )
                else
                  const SizedBox(height: 12),

                // Status dot
                Container(
                  width: isActive ? 16 : 12,
                  height: isActive ? 16 : 12,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _getEventColor(event.status)
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? _getEventColor(event.status)
                          : AppTheme.dividerColor,
                      width: isActive ? 0 : 2,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color:
                                  _getEventColor(event.status).withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: isActive
                      ? const Icon(
                          Icons.check_rounded,
                          size: 10,
                          color: Colors.white,
                        )
                      : null,
                ),

                // Bottom connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(minHeight: 30),
                      color: AppTheme.dividerColor,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ─── Event Content ───────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isActive
                    ? _getEventColor(event.status).withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: isActive
                      ? _getEventColor(event.status).withOpacity(0.2)
                      : AppTheme.dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event description
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Location
                  if (event.location.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: isActive
                              ? _getEventColor(event.status)
                              : AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive
                                  ? _getEventColor(event.status)
                                  : AppTheme.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  // Date and time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppTheme.textTertiary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(event.timestamp)} • ${timeFormat.format(event.timestamp)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String status) {
    switch (status.toLowerCase()) {
      case 'picked_up':
      case 'pending':
        return AppTheme.textSecondary;
      case 'in_transit':
        return AppTheme.statusInTransit;
      case 'in_customs':
        return AppTheme.statusInCustoms;
      case 'out_for_delivery':
        return AppTheme.statusOutForDelivery;
      case 'delivered':
        return AppTheme.statusDelivered;
      case 'exception':
        return AppTheme.statusException;
      default:
        return AppTheme.primaryColor;
    }
  }
}
