import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/tracking_provider.dart';
import '../../../data/providers/search_history_provider.dart';
import '../../../services/tracking/carrier_detector.dart';

/// Smart search bar with auto-detection, paste support, and QR/barcode scan.
class SmartSearchBar extends StatefulWidget {
  const SmartSearchBar({super.key});

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showHistory = false;
  CarrierDetectionResult? _detectedCarrier;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _focusNode.addListener(() {
      setState(() {
        _showHistory = _focusNode.hasFocus && _controller.text.isEmpty;
      });
      if (_focusNode.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });

    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    if (text.length >= 6) {
      final result = CarrierDetector.detect(text);
      setState(() {
        _detectedCarrier = result.detected ? result : null;
        _showHistory = false;
      });
    } else {
      setState(() {
        _detectedCarrier = null;
        _showHistory = _focusNode.hasFocus && text.isEmpty;
      });
    }
  }

  Future<void> _onSubmit() async {
    final trackingNumber = _controller.text.trim();
    if (trackingNumber.isEmpty) return;

    // Add to search history
    await context.read<SearchHistoryProvider>().addEntry(trackingNumber);

    // Track the package
    await context.read<TrackingProvider>().trackNewPackage(trackingNumber);

    // Clear and unfocus
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _detectedCarrier = null;
      _showHistory = false;
    });
  }

  Future<void> _onScanPressed() async {
    // In production, this would open mobile_scanner
    // For now, show a dialog indicating scanner functionality
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Scanner'),
          ],
        ),
        content: const Text(
          'QR/Barcode scanner will open the device camera.\n\n'
          'Supported formats:\n'
          '• QR Code\n'
          '• Code 128\n'
          '• Code 39\n'
          '• EAN-13\n'
          '• UPC-A',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onPastePressed() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!.trim();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Search Input ────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundGrey,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: _focusNode.hasFocus
                ? Border.all(color: AppTheme.primaryColor, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),
              // Paste button
              IconButton(
                onPressed: _onPastePressed,
                icon: const Icon(
                  Icons.content_paste_rounded,
                  size: 18,
                  color: AppTheme.textTertiary,
                ),
                tooltip: 'Paste',
                splashRadius: 20,
              ),
              // Scan button
              Container(
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _onScanPressed,
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  tooltip: l10n.scanCode,
                  splashRadius: 20,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        // ─── Carrier Detection Badge ────────────────────────────────
        if (_detectedCarrier != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_detectedCarrier!.carrier} • ${(_detectedCarrier!.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ─── Search History Dropdown ─────────────────────────────────
        if (_showHistory)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<SearchHistoryProvider>(
              builder: (context, historyProvider, _) {
                if (historyProvider.history.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.recentSearches,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => historyProvider.clearAll(),
                            child: Text(
                              l10n.clearHistory,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...historyProvider.history.take(5).map((entry) {
                        return InkWell(
                          onTap: () {
                            _controller.text = entry.trackingNumber;
                            _onSubmit();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history_rounded,
                                  size: 16,
                                  color: AppTheme.textTertiary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.trackingNumber,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        entry.carrier,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => historyProvider
                                      .removeEntry(entry.trackingNumber),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
