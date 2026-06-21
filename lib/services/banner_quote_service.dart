import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/ai_config.dart';
import '../models/motivational_quote.dart';
import '../services/hive_service.dart';

class BannerQuoteService {
  static const _quoteTags = 'motivational|inspirational|success|wisdom';
  static const _cacheVersion = 'v2_vector';

  Future<MotivationalQuote> getQuoteForSlot(int slot) async {
    final cacheKey = '${HiveService.keyBannerQuote}_${_cacheVersion}_$slot';
    final cached = HiveService.settings.get(cacheKey);
    if (cached is Map) {
      return MotivationalQuote.fromMap(cached);
    }

    final fetched = await _fetchFreshQuote(slot);
    await HiveService.settings.put(cacheKey, fetched.toMap());
    return fetched;
  }

  Future<MotivationalQuote> _fetchFreshQuote(int slot) async {
    final quoteData = AiConfig.hasGeminiKey
        ? await _fetchQuoteFromGemini(slot)
        : await _fetchQuoteFromApi();

    final imageUrl = _buildVectorIllustrationUrl(
      quote: quoteData.quote,
      slot: slot,
    );

    return MotivationalQuote(
      quote: quoteData.quote,
      author: quoteData.author,
      imageUrl: imageUrl,
      slot: slot,
      gradientColors: defaultGradientForSlot(slot),
    );
  }

  Future<({String quote, String author})> _fetchQuoteFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=$_quoteTags'),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as String?;
        final author = data['author'] as String?;
        if (content != null && content.isNotEmpty) {
          return (quote: content, author: author ?? 'Unknown');
        }
      }
    } catch (_) {}

    return _fallbackQuote();
  }

  Future<({String quote, String author})> _fetchQuoteFromGemini(int slot) async {
    try {
      final themes = [
        'building daily habits',
        'morning discipline',
        'fitness consistency',
        'mindfulness and focus',
        'reading and growth',
        'breaking bad habits',
        'self improvement journey',
      ];
      final theme = themes[slot % themes.length];

      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/'
          'gemini-2.0-flash:generateContent?key=${AiConfig.geminiApiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Write one short motivational quote (max 120 characters) '
                      'about $theme for a habit tracker app called Habit Hero. '
                      'Return ONLY valid JSON: {"quote":"...","author":"..."} '
                      'where author is a fitting name or "Habit Hero".',
                },
              ],
            },
          ],
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final text = body['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String?;
        if (text != null) {
          final cleaned = text
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
          final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
          final quote = parsed['quote'] as String?;
          final author = parsed['author'] as String?;
          if (quote != null && quote.isNotEmpty) {
            return (quote: quote, author: author ?? 'Habit Hero');
          }
        }
      }
    } catch (_) {}

    return _fetchQuoteFromApi();
  }

  ({String quote, String author}) _fallbackQuote() {
    final fallbacks = <Map<String, String>>[
      {
        'quote': 'Small steps every day lead to big changes.',
        'author': 'Habit Hero',
      },
      {
        'quote':
            'Discipline is choosing what you want most over what you want now.',
        'author': 'Habit Hero',
      },
      {
        'quote': 'Your future self will thank you for today\'s effort.',
        'author': 'Habit Hero',
      },
      {
        'quote': 'Consistency beats perfection every single time.',
        'author': 'Habit Hero',
      },
    ];
    final index = currentBannerSlot() % fallbacks.length;
    final item = fallbacks[index];
    return (quote: item['quote']!, author: item['author']!);
  }

  String _buildVectorIllustrationUrl({required String quote, required int slot}) {
    final themes = [
      'person meditating peacefully',
      'runner exercising outdoors',
      'person reading a book happily',
      'person writing in journal',
      'healthy lifestyle wellness',
      'yoga and mindfulness',
      'morning routine productivity',
      'achievement celebration habits',
    ];
    final theme = themes[slot % themes.length];

    final prompt =
        'Flat vector illustration only, 2D cartoon style, clean minimal line art, '
        'Storyset undraw freepik vector aesthetic, NO photorealism, NO 3D render, '
        'NO photography, simple geometric shapes, soft pastel blue yellow white palette, '
        'habit tracker app illustration about $theme inspired by: '
        '"${_truncate(quote, 100)}". '
        'Single centered character scene, plain light background, '
        'no text, no words, no letters, no watermark';

    final encoded = Uri.encodeComponent(prompt);
    return 'https://image.pollinations.ai/prompt/$encoded'
        '?width=512&height=512&seed=$slot&nologo=true&enhance=false&model=turbo';
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}...';
  }
}
