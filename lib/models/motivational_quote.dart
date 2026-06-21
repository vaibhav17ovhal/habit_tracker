class MotivationalQuote {
  final String quote;
  final String author;
  final String imageUrl;
  final int slot;
  final List<int> gradientColors;

  const MotivationalQuote({
    required this.quote,
    required this.author,
    required this.imageUrl,
    required this.slot,
    required this.gradientColors,
  });

  Map<String, dynamic> toMap() => {
        'quote': quote,
        'author': author,
        'imageUrl': imageUrl,
        'slot': slot,
        'gradientColors': gradientColors,
      };

  factory MotivationalQuote.fromMap(Map<dynamic, dynamic> map) {
    return MotivationalQuote(
      quote: map['quote'] as String,
      author: map['author'] as String? ?? 'Habit Hero',
      imageUrl: map['imageUrl'] as String,
      slot: map['slot'] as int? ?? 0,
      gradientColors: (map['gradientColors'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          defaultGradientForSlot(map['slot'] as int? ?? 0),
    );
  }
}

const _gradientPalette = [
  [0xFF3B82F6, 0xFF2563EB],
  [0xFF10B981, 0xFF059669],
  [0xFF8B5CF6, 0xFF7C3AED],
  [0xFFEC4899, 0xFFDB2777],
  [0xFFF97316, 0xFFEA580C],
  [0xFF06B6D4, 0xFF0891B2],
  [0xFF6366F1, 0xFF4F46E5],
  [0xFFFACC15, 0xFFEAB308],
];

List<int> defaultGradientForSlot(int slot) {
  return _gradientPalette[slot.abs() % _gradientPalette.length];
}

int currentBannerSlot() {
  const slotMs = 30 * 60 * 1000;
  return DateTime.now().millisecondsSinceEpoch ~/ slotMs;
}
