import 'package:flutter/material.dart';

import '../models/motivational_quote.dart';
import '../services/banner_quote_service.dart';
import '../services/hive_service.dart';

class BannerQuoteProvider extends ChangeNotifier {
  final BannerQuoteService _service = BannerQuoteService();

  MotivationalQuote? _current;
  bool _isLoading = false;
  String? _error;
  int _slot = currentBannerSlot();

  MotivationalQuote? get current => _current;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get slot => _slot;

  Future<void> loadForCurrentSlot({bool forceRefresh = false}) async {
    final slot = currentBannerSlot();
    if (!forceRefresh &&
        _current != null &&
        _current!.slot == slot &&
        !_isLoading) {
      return;
    }

    _slot = slot;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (forceRefresh) {
        await _clearSlotCache(slot);
      }
      _current = await _service.getQuoteForSlot(slot);
      _error = null;
    } catch (e) {
      _error = 'Could not load motivation banner';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshIfSlotChanged() async {
    final slot = currentBannerSlot();
    if (slot != _slot || _current == null) {
      await loadForCurrentSlot();
    }
  }

  static const _cacheVersion = 'v2_vector';

  Future<void> _clearSlotCache(int slot) async {
    await HiveService.settings
        .delete('${HiveService.keyBannerQuote}_${_cacheVersion}_$slot');
  }
}
