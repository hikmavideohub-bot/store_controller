import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

class EmojiPickerSheet extends StatelessWidget {
  final String? selected;
  final ScrollController? scrollController;

  const EmojiPickerSheet({
    super.key,
    this.selected,
    this.scrollController,
  });

  /// Filtert unerwünschte Emojis (Flaggen)
  List<CategoryEmoji> _getFilteredEmojis() {

    return defaultEmojiSet.map((categoryEmoji) {
      final filteredList = categoryEmoji.emoji
          .toList();
      return CategoryEmoji(categoryEmoji.category, filteredList);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Ermittelt die Höhe der Tastatur
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Basis-Höhe (400) + Tastatur-Höhe
      height: 400 + keyboardHeight,
      color: colors.surface,
      // WICHTIG: Padding unten für die Tastatur
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        child: Column(
          children: [
            // Griff oben
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (Category? category, Emoji emoji) {
                  Navigator.pop(context, emoji.emoji);
                },
                textEditingController: null,

                config: Config(
                  height: 256,
                  checkPlatformCompatibility: true,

                  // Filter-Funktion
                  emojiSet: (_) => _getFilteredEmojis(),

                  // --- Design der Emoji-Ansicht ---
                  emojiViewConfig: EmojiViewConfig(
                    backgroundColor: colors.surface,
                    columns: 7,
                    emojiSizeMax: 28 *
                        (foundation.defaultTargetPlatform == TargetPlatform.iOS
                            ? 1.20
                            : 1.0),
                    noRecents: Text(
                      'لا يوجد مستخدمة حديثاً',
                      style: TextStyle(fontSize: 16, color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // ✅ SUCHE IST OBEN (TOP)
                  viewOrderConfig: const ViewOrderConfig(
                    top: EmojiPickerItem.searchBar,      // Suche oben
                    middle: EmojiPickerItem.categoryBar, // Kategorien mitte
                    bottom: EmojiPickerItem.emojiView,   // Emojis unten
                  ),

                  // --- Design der Suchleiste ---
                  searchViewConfig: SearchViewConfig(
                    // Wir geben der Suche eine andere Hintergrundfarbe, damit man sie sieht
                    backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    buttonIconColor: colors.primary, // Icon in Teal
                    hintText: '🔍 بحث عن رمز...',
                    hintTextStyle: TextStyle(color: theme.hintColor),
                  ),

                  // --- Untere Leiste ---
                  bottomActionBarConfig: BottomActionBarConfig(
                    backgroundColor: colors.surface,
                    buttonColor: colors.surface,
                    buttonIconColor: colors.onSurface,
                    showBackspaceButton: false,
                    showSearchViewButton: false,
                  ),

                  // --- Design der Kategorie-Leiste ---
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: colors.surface,
                    dividerColor: colors.outline.withValues(alpha: 0.2),
                    indicatorColor: colors.primary,
                    iconColorSelected: colors.primary,
                    iconColor: theme.hintColor,
                    tabIndicatorAnimDuration: kTabScrollDuration,

                    categoryIcons: const CategoryIcons(
                      recentIcon: Icons.access_time_rounded,
                      smileyIcon: Icons.emoji_emotions_rounded,
                      animalIcon: Icons.pets_rounded,
                      foodIcon: Icons.fastfood_rounded,
                      activityIcon: Icons.sports_soccer_rounded,
                      travelIcon: Icons.location_city_rounded,
                      objectIcon: Icons.lightbulb_rounded,
                      symbolIcon: Icons.emoji_symbols_rounded,
                      flagIcon: Icons.flag_rounded,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}