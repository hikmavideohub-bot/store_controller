// Slug Generator with Arabic-to-Latin Transliteration
//
// Generates URL-safe slugs from store names, with full support
// for Arabic text transliteration using dictionary + phonetic rules.

/// Dictionary of common Arabic words/names with proper transliteration
/// This provides natural, readable slugs for frequently used terms
const Map<String, String> arabicWordDictionary = {
  // Common names
  'محمد': 'muhammad',
  'أحمد': 'ahmad',
  'احمد': 'ahmad',
  'علي': 'ali',
  'عمر': 'omar',
  'خالد': 'khaled',
  'سعيد': 'saeed',
  'يوسف': 'yusuf',
  'إبراهيم': 'ibrahim',
  'ابراهيم': 'ibrahim',
  'عبدالله': 'abdullah',
  'عبد الله': 'abdullah',
  'عبدالرحمن': 'abdulrahman',
  'عبد الرحمن': 'abdulrahman',
  'فاطمة': 'fatima',
  'مريم': 'maryam',
  'نور': 'noor',
  'سارة': 'sara',
  'ليلى': 'layla',
  'هدى': 'huda',
  'سلمان': 'salman',
  'فيصل': 'faisal',
  'سلطان': 'sultan',
  'ناصر': 'nasser',
  'حسن': 'hassan',
  'حسين': 'hussein',
  'كريم': 'kareem',
  'جمال': 'jamal',
  'طارق': 'tariq',
  'زياد': 'ziad',
  'رامي': 'rami',
  'سامي': 'sami',
  'هاني': 'hani',
  'وليد': 'waleed',
  'ماجد': 'majed',
  'راشد': 'rashed',
  'مازن': 'mazen',
  'باسم': 'basem',
  'عادل': 'adel',
  'صالح': 'saleh',
  'منصور': 'mansour',
  'بدر': 'badr',
  'فهد': 'fahd',
  'تركي': 'turki',
  'سعود': 'saud',
  'مشاري': 'mishari',
  'عبدالعزيز': 'abdulaziz',
  'عبد العزيز': 'abdulaziz',

  // Store/Business related words
  'متجر': 'matjar',
  'محل': 'mahal',
  'سوق': 'souq',
  'مركز': 'markaz',
  'بيت': 'bait',
  'دار': 'dar',
  'مؤسسة': 'muassasa',
  'شركة': 'sharika',
  'مجموعة': 'majmoua',
  'عالم': 'alam',
  'كنز': 'kanz',
  'ذهب': 'dhahab',
  'الذهبي': 'aldhahabi',
  'ذهبي': 'dhahabi',
  'فضة': 'fidda',
  'لؤلؤ': 'lulu',
  'جوهرة': 'jawhara',
  'الماس': 'almas',

  // Products/Categories
  'إلكترونيات': 'electronics',
  'الكترونيات': 'electronics',
  'أزياء': 'fashion',
  'ازياء': 'fashion',
  'ملابس': 'malabis',
  'أحذية': 'shoes',
  'احذية': 'shoes',
  'حقائب': 'bags',
  'ساعات': 'watches',
  'عطور': 'perfumes',
  'مجوهرات': 'jewelry',
  'أثاث': 'furniture',
  'اثاث': 'furniture',
  'ديكور': 'decor',
  'مطبخ': 'kitchen',
  'طعام': 'food',
  'حلويات': 'sweets',
  'مخبز': 'bakery',
  'قهوة': 'coffee',
  'شاي': 'tea',
  'عسل': 'honey',
  'تمر': 'dates',
  'زيت': 'oil',
  'زيتون': 'olive',

  // Adjectives
  'الجديد': 'aljadeed',
  'جديد': 'jadeed',
  'القديم': 'alqadeem',
  'قديم': 'qadeem',
  'الكبير': 'alkabeer',
  'كبير': 'kabeer',
  'الصغير': 'alsagheer',
  'صغير': 'sagheer',
  'الأصلي': 'alasli',
  'أصلي': 'asli',
  'اصلي': 'asli',
  'الممتاز': 'almumtaz',
  'ممتاز': 'mumtaz',
  'الفاخر': 'alfakher',
  'فاخر': 'fakher',

  // Common prefixes/articles
  'ال': 'al',
  'و': 'wa',
  'في': 'fi',
  'من': 'min',
  'إلى': 'ila',
  'الى': 'ila',
  'على': 'ala',
  'مع': 'maa',

  // Places
  'الرياض': 'riyadh',
  'جدة': 'jeddah',
  'مكة': 'makkah',
  'المدينة': 'madinah',
  'دبي': 'dubai',
  'أبوظبي': 'abudhabi',
  'ابوظبي': 'abudhabi',
  'الكويت': 'kuwait',
  'قطر': 'qatar',
  'البحرين': 'bahrain',
  'عمان': 'oman',
  'مصر': 'egypt',
  'القاهرة': 'cairo',
  'بيروت': 'beirut',
  'دمشق': 'damascus',
  'عمّان': 'amman',
  'بغداد': 'baghdad',
};

/// Arabic to Latin character mapping for phonetic transliteration
/// Used for words not found in dictionary
const Map<String, String> arabicToLatinMap = {
  // Vowels and Alif variants
  'ا': 'a',
  'أ': 'a',
  'إ': 'i',
  'آ': 'aa',
  'ى': 'a',
  'ة': 'ah',
  'ء': '',

  // Consonants with standard romanization
  'ب': 'b',
  'ت': 't',
  'ث': 'th',
  'ج': 'j',
  'ح': 'h',
  'خ': 'kh',
  'د': 'd',
  'ذ': 'dh',
  'ر': 'r',
  'ز': 'z',
  'س': 's',
  'ش': 'sh',
  'ص': 's',
  'ض': 'd',
  'ط': 't',
  'ظ': 'z',
  'ع': 'a',
  'غ': 'gh',
  'ف': 'f',
  'ق': 'q',
  'ك': 'k',
  'ل': 'l',
  'م': 'm',
  'ن': 'n',
  'ه': 'h',
  'و': 'w',
  'ي': 'y',

  // Diacritics - use them for vowel sounds
  '\u064E': 'a', // Fatha
  '\u064F': 'u', // Damma
  '\u0650': 'i', // Kasra
  '\u0651': '',  // Shadda (double consonant - handled separately)
  '\u0652': '',  // Sukun (no vowel)

  // Persian/Urdu additions
  'پ': 'p',
  'چ': 'ch',
  'ژ': 'zh',
  'گ': 'g',
  'ک': 'k',
  'ی': 'y',
};

/// Reserved slugs that cannot be used by stores
const Set<String> reservedSlugs = {
  'admin',
  'login',
  'api',
  'support',
  'help',
  'settings',
  'dashboard',
  'www',
  's',
  'store',
  'stores',
  'app',
  'auth',
  'checkout',
  'payment',
  'cart',
  'order',
  'orders',
  'account',
  'profile',
  'search',
  'register',
  'signup',
  'signin',
  'logout',
  'reset',
  'verify',
  'confirm',
  'terms',
  'privacy',
  'about',
  'contact',
  'faq',
  'home',
  'index',
  'new',
  'edit',
  'delete',
  'create',
  'update',
  'user',
  'users',
  'product',
  'products',
  'category',
  'categories',
};

class SlugGenerator {
  /// Maximum slug length (URL-friendly)
  static const int maxSlugLength = 50;

  /// Minimum slug length
  static const int minSlugLength = 3;

  /// Generates a URL-safe slug from store name.
  /// Returns null if name cannot produce a valid slug.
  ///
  /// Examples:
  /// - "متجر محمد" → "mtjr-mhmd"
  /// - "My Store 123" → "my-store-123"
  /// - "" → null
  static String? generateSlug(String storeName) {
    if (storeName.trim().isEmpty) return null;

    String slug = storeName.trim();

    // Step 1: Transliterate Arabic to Latin
    slug = _transliterate(slug);

    // Step 2: Normalize - lowercase
    slug = slug.toLowerCase();

    // Step 3: Replace spaces and underscores with hyphens
    slug = slug.replaceAll(RegExp(r'[\s_]+'), '-');

    // Step 4: Remove all non-alphanumeric characters except hyphens
    slug = slug.replaceAll(RegExp(r'[^a-z0-9-]'), '');

    // Step 5: Remove consecutive hyphens
    slug = slug.replaceAll(RegExp(r'-+'), '-');

    // Step 6: Trim hyphens from start/end
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');

    // Step 7: Truncate to max length
    if (slug.length > maxSlugLength) {
      slug = slug.substring(0, maxSlugLength);
      // Don't end with a hyphen after truncation
      slug = slug.replaceAll(RegExp(r'-+$'), '');
    }

    // Step 8: Validate minimum length
    if (slug.length < minSlugLength) {
      return null;
    }

    // Step 9: Check reserved slugs
    if (reservedSlugs.contains(slug)) {
      return null;
    }

    return slug;
  }

  /// Transliterates Arabic text to Latin characters.
  ///
  /// Uses a two-phase approach:
  /// 1. Dictionary lookup for known words (provides natural transliteration)
  /// 2. Character-by-character transliteration for unknown words
  static String _transliterate(String text) {
    // Split text into words
    final words = text.split(RegExp(r'\s+'));
    final transliteratedWords = <String>[];

    for (final word in words) {
      if (word.isEmpty) continue;

      // Check dictionary first (exact match)
      if (arabicWordDictionary.containsKey(word)) {
        transliteratedWords.add(arabicWordDictionary[word]!);
        continue;
      }

      // Check dictionary without diacritics
      final cleanWord = _removeDiacritics(word);
      if (arabicWordDictionary.containsKey(cleanWord)) {
        transliteratedWords.add(arabicWordDictionary[cleanWord]!);
        continue;
      }

      // Try to match compound words (e.g., "المتجر" = "ال" + "متجر")
      final compoundResult = _tryCompoundMatch(word);
      if (compoundResult != null) {
        transliteratedWords.add(compoundResult);
        continue;
      }

      // Fall back to character-by-character transliteration
      transliteratedWords.add(_transliterateWord(word));
    }

    return transliteratedWords.join(' ');
  }

  /// Removes Arabic diacritics from text
  static String _removeDiacritics(String text) {
    return text.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');
  }

  /// Tries to match compound words by splitting at known prefixes
  static String? _tryCompoundMatch(String word) {
    // Common prefixes to check
    const prefixes = ['ال', 'و', 'ب', 'ل', 'ف', 'ك'];

    for (final prefix in prefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length) {
        final remainder = word.substring(prefix.length);
        final cleanRemainder = _removeDiacritics(remainder);

        // Check if remainder is in dictionary
        if (arabicWordDictionary.containsKey(remainder)) {
          final prefixTrans = arabicWordDictionary[prefix] ?? _transliterateWord(prefix);
          return '$prefixTrans${arabicWordDictionary[remainder]}';
        }
        if (arabicWordDictionary.containsKey(cleanRemainder)) {
          final prefixTrans = arabicWordDictionary[prefix] ?? _transliterateWord(prefix);
          return '$prefixTrans${arabicWordDictionary[cleanRemainder]}';
        }
      }
    }

    return null;
  }

  /// Transliterates a single word character by character
  /// with improved vowel insertion rules
  static String _transliterateWord(String word) {
    final buffer = StringBuffer();
    final chars = word.split('');

    for (int i = 0; i < chars.length; i++) {
      final char = chars[i];
      // Check if character is in Arabic mapping
      if (arabicToLatinMap.containsKey(char)) {
        final latin = arabicToLatinMap[char]!;
        buffer.write(latin);


      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }





  /// Checks if a proposed slug is reserved
  static bool isReserved(String slug) {
    return reservedSlugs.contains(slug.toLowerCase());
  }

  /// Generates a unique slug by appending numeric suffix
  /// e.g., "mtjr-mhmd", "mtjr-mhmd-2", "mtjr-mhmd-3"
  static String appendSuffix(String baseSlug, int suffix) {
    if (suffix <= 1) return baseSlug;
    return '$baseSlug-$suffix';
  }

  /// Validates a slug format
  static bool isValidSlug(String slug) {
    if (slug.length < minSlugLength || slug.length > maxSlugLength) {
      return false;
    }
    if (reservedSlugs.contains(slug)) {
      return false;
    }
    // Must be lowercase alphanumeric with hyphens only
    return RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(slug);
  }
}
