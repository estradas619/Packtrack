import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../../data/models/package_model.dart';

/// Utility class with helper methods used across the app.
class Helpers {
  Helpers._();

  // ─── Date Formatting ───────────────────────────────────────────────────────

  /// Format a date to a human-readable relative string.
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('MMM dd').format(date);
  }

  /// Format ETA to a user-friendly string.
  static String formatETA(DateTime? eta) {
    if (eta == null) return '-';

    final now = DateTime.now();
    final diff = eta.difference(now);

    if (diff.isNegative) return 'Delivered';
    if (diff.inHours < 1) return 'Less than 1 hour';
    if (diff.inHours < 24) return '${diff.inHours} hours';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return '${diff.inDays} days';

    return DateFormat('MMM dd, yyyy').format(eta);
  }

  /// Format date for display.
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date and time.
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  // ─── Status Helpers ────────────────────────────────────────────────────────

  /// Get the color associated with a package status.
  static Color getStatusColor(PackageStatus status) {
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

  /// Get the icon associated with a package status.
  static IconData getStatusIcon(PackageStatus status) {
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

  // ─── Tracking Number Formatting ────────────────────────────────────────────

  /// Format a tracking number for display (add spaces for readability).
  static String formatTrackingNumber(String trackingNumber) {
    if (trackingNumber.length <= 8) return trackingNumber;

    // Group in chunks of 4 for long numbers
    final buffer = StringBuffer();
    for (var i = 0; i < trackingNumber.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(trackingNumber[i]);
    }
    return buffer.toString();
  }

  // ─── Validation ────────────────────────────────────────────────────────────

  /// Check if a string looks like a valid tracking number.
  static bool isValidTrackingNumber(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    // Minimum 6 characters, alphanumeric
    return cleaned.length >= 6 && RegExp(r'^[A-Za-z0-9]+$').hasMatch(cleaned);
  }

  // ─── UI Helpers ────────────────────────────────────────────────────────────

  /// Show a snackbar with a message.
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppTheme.errorColor : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
