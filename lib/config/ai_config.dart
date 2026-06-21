/// Optional: pass at build time with
/// `--dart-define=GEMINI_API_KEY=your_key`
class AiConfig {
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}
