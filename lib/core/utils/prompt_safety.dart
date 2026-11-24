class PromptSafety {
  static final List<String> _blockedPatterns = [
    // Child Safety
    r'\b(loli|shota|underage|minor)\b',

    // Explicit Sexual Content
    r'\b(nude|naked|porn|xxx|hentai|sex|sexual|erotic)\b',
    r'\b(bdsm|bondage|fetish|orgasm)\b',

    // Sexual Body Parts
    r'\b(vagina|penis|cock|dick|pussy)\b',

    // Violence / Self Harm
    r'\b(gore|bloodbath|mutilated|torture)\b',
    r'\b(suicide|self[\s_-]?harm)\b',

    // Criminal Sexual Content
    r'\b(rape|incest|bestiality)\b',
  ];

  static bool isPromptSafe(String prompt) {
    if (prompt.trim().isEmpty) return false;

    final normalized = _normalize(prompt);

    for (final pattern in _blockedPatterns) {
      final regex = RegExp(
        pattern,
        caseSensitive: false,
      );

      if (regex.hasMatch(normalized)) {
        return false;
      }
    }

    return true;
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}