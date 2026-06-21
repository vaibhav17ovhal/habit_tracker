import 'dart:async';

import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/models/motivational_quote.dart';
import 'package:Demo/providers/banner_quote_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MotivationalQuoteBanner extends StatefulWidget {
  const MotivationalQuoteBanner({super.key});

  @override
  State<MotivationalQuoteBanner> createState() =>
      _MotivationalQuoteBannerState();
}

class _MotivationalQuoteBannerState extends State<MotivationalQuoteBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerQuoteProvider>().loadForCurrentSlot();
    });
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      context.read<BannerQuoteProvider>().refreshIfSlotChanged();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BannerQuoteProvider>();
    final quote = provider.current;

    if (provider.isLoading && quote == null) {
      return const _BannerLoadingPlaceholder();
    }

    if (quote == null) {
      return _BannerErrorPlaceholder(
        message: provider.error ?? 'Unable to load banner',
        onRetry: () => provider.loadForCurrentSlot(forceRefresh: true),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _QuoteBannerCard(
        key: ValueKey('${quote.slot}_${quote.imageUrl}'),
        quote: quote,
        isRefreshing: provider.isLoading,
      ),
    );
  }
}

class _QuoteBannerCard extends StatelessWidget {
  final MotivationalQuote quote;
  final bool isRefreshing;

  const _QuoteBannerCard({
    super.key,
    required this.quote,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: quote.gradientColors.map(Color.new).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(quote.gradientColors.first).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 14,
                                    color: MyColors.accentYellow,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AI Motivation',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isRefreshing) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Text(
                          quote.quote,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '— ${quote.author}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CachedNetworkImage(
                      imageUrl: quote.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: MyColors.primaryBlue.withValues(alpha: 0.4),
                          size: 32,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: MyColors.primaryBlue.withValues(alpha: 0.4),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerLoadingPlaceholder extends StatelessWidget {
  const _BannerLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [MyColors.primaryBlue, Color(0xFF2563EB)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            const SizedBox(height: 12),
            Text(
              'Loading vector illustration...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerErrorPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BannerErrorPlaceholder({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 168,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: MyColors.neutralGray,
        border: Border.all(color: MyColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: MyColors.kDescriptionColor,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: MyColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
