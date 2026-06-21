class MoodEntry {
  final DateTime date;
  final String label;
  final String emoji;

  const MoodEntry({
    required this.date,
    required this.label,
    required this.emoji,
  });

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'label': label,
        'emoji': emoji,
      };

  factory MoodEntry.fromMap(Map<dynamic, dynamic> map) {
    return MoodEntry(
      date: DateTime.parse(map['date'] as String),
      label: map['label'] as String,
      emoji: map['emoji'] as String,
    );
  }
}

class MoodOption {
  final String label;
  final String emoji;

  const MoodOption({required this.label, required this.emoji});
}

const kMoodOptions = [
  MoodOption(label: 'Happy', emoji: '😊'),
  MoodOption(label: 'Sad', emoji: '😢'),
  MoodOption(label: 'Energetic', emoji: '⚡'),
  MoodOption(label: 'Calm', emoji: '😌'),
  MoodOption(label: 'Stressed', emoji: '😰'),
  MoodOption(label: 'Motivated', emoji: '💪'),
  MoodOption(label: 'Tired', emoji: '😴'),
  MoodOption(label: 'Excited', emoji: '🤩'),
];
