class AllEmojiCatalog {
  static final List<String> all = _build();

  static List<String> _build() {
    final out = <String>[];

    void addRange(int start, int end) {
      for (int cp = start; cp <= end; cp++) {
        if (_skip(cp)) continue;
        out.add(String.fromCharCode(cp));
      }
    }

    // Core emoji ranges
    addRange(0x1F600, 0x1F64F); // emoticons
    addRange(0x1F300, 0x1F5FF); // symbols & pictographs
    addRange(0x1F680, 0x1F6FF); // transport
    addRange(0x1F900, 0x1F9FF); // supplemental
    addRange(0x1FA70, 0x1FAFF); // extended
    addRange(0x2600, 0x26FF);   // misc symbols
    addRange(0x2700, 0x27BF);   // dingbats
    addRange(0x1F1E6, 0x1F1FF); // regional indicators

    final seen = <String>{};
    return out.where((e) => seen.add(e)).toList();
  }

  static bool _skip(int cp) {
    if (cp == 0x200D) return true; // ZWJ
    if (cp == 0xFE0E || cp == 0xFE0F) return true; // variation
    if (cp >= 0x1F3FB && cp <= 0x1F3FF) return true; // skin tones
    if (cp == 0x20E3) return true; // keycap combiner
    return false;
  }
}
