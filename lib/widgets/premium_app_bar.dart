import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/icon_a2h//pwa_service.dart';
import '../services/icon_a2h/pwa_install_button.dart';
/// Premium Animation Utilities
class PremiumAnimations {
  /// Fade-in animation with staggered delay
  static Widget fadeInStaggered({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: duration.inMilliseconds + (index * delay.inMilliseconds),
      ),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Shimmer loading effect
  /// Nutzt standardmäßig die 'tertiary' Farbe (Gold) des Themes
  static Widget shimmerLoading({
    required Widget child,
    bool isLoading = false,
    Color? shimmerColor,
  }) {
    return Builder(
      builder: (context) {
        final color = shimmerColor ?? Theme.of(context).colorScheme.tertiary;
        return Stack(
          children: [
            child,
            if (isLoading)
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        Colors.transparent,
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(color: Colors.transparent),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Pulse animation for important elements
  static Widget pulse({
    required Widget child,
    bool active = true,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!active) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.05),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        duration: duration,
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// Gold shimmer effect for premium elements
  static Widget goldShimmer({required Widget child, bool active = true}) {
    return Builder(
      builder: (context) {
        final gold = Theme.of(context).colorScheme.tertiary;
        return Stack(
          children: [
            child,
            if (active)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          gold.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Elegant scale animation for buttons
  static Widget scaleOnTap({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = const Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
      lowerBound: 0.95,
      upperBound: 1.0,
    );

    return GestureDetector(
      onTapDown: (_) => controller.reverse(),
      onTapUp: (_) => controller.forward(),
      onTapCancel: () => controller.forward(),
      onTap: onTap,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.scale(scale: controller.value, child: child);
        },
        child: child,
      ),
    );
  }

  /// Smooth page transition
  static const PageTransitionsTheme slideUpTransition = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );
}

/// Premium App Bar with enhanced animations
class PremiumAnimatedAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSettings;
  final List<Widget>? actions;
  final bool hasSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchCleared;
  final VoidCallback? onFiltersPressed;
  final VoidCallback? onMenuPressed;

  const PremiumAnimatedAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showSettings = true,
    this.actions,
    this.hasSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.onSearchCleared,
    this.onFiltersPressed,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize {
    if (hasSearch) {
      return const Size.fromHeight(120);
    }
    return const Size.fromHeight(kToolbarHeight);
  }

  @override
  State<PremiumAnimatedAppBar> createState() => _PremiumAnimatedAppBarState();
}

class _PremiumAnimatedAppBarState extends State<PremiumAnimatedAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;
  final FocusNode _searchFocusNode = FocusNode();
  ModalRoute<dynamic>? _route;


  @override
  void initState() {
    super.initState();
    PwaService.instance.init(); // Startet den PWA-Listener
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    );

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleController.forward();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Wenn eine neue Route über diese gelegt wird: Suche defokussieren,
    // damit die Tastatur nicht "hängen bleibt" beim Zurückkommen.
    final route = ModalRoute.of(context);
    if (_route != route) {
      (_route?.secondaryAnimation)?.removeStatusListener(_handleRouteSecondaryStatus);
      (_route?.secondaryAnimation)?.addStatusListener(_handleRouteSecondaryStatus);
      _route = route;

    }
  }

  void _handleRouteSecondaryStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward || status == AnimationStatus.completed) {
      _unfocusSearch();
    }
  }


  @override
  void dispose() {
    (_route?.secondaryAnimation)?.removeStatusListener(_handleRouteSecondaryStatus);
    _titleController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }


  void _unfocusSearch() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;
    // Wir nutzen tertiary für "Premium/Gold" Elemente
    final premiumColor = colors.tertiary;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _unfocusSearch,
      child: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      leading: widget.showBackButton
          ? _buildScaleOnTapIcon(
              onTap: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: colors.onSurface,
            )
          : widget.onMenuPressed != null
          ? _buildScaleOnTapIcon(
              onTap: widget.onMenuPressed!,
              icon: const Icon(Icons.menu_rounded),
              color: colors.onSurface,
              tooltip: s.menuTooltip,
            )
          : null,
      title: FadeTransition(
        opacity: _titleAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_titleAnimation),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
        ),
      ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            // Nutzt jetzt das universelle Widget (inkl. Apple iOS Fallback!)
            child: PwaInstallButton(color: premiumColor),
          ),
          if (widget.actions != null) ...widget.actions!,
        ],
        bottom: widget.hasSearch
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: FadeTransition(
                opacity: _titleAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Do nothing - prevent the parent GestureDetector from unfocusing
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              // Nutzt Input-Fill-Color oder Surface
                              color:
                                  theme.inputDecorationTheme.fillColor ??
                                  colors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.outline.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: widget.searchController,
                              focusNode: _searchFocusNode,
                              onChanged: widget.onSearchChanged,
                              onTap: () {
                                _unfocusSearch();
                                (widget.onSearchCleared ?? () {})();
                                setState(() {});
                              },
                              onTapOutside: (_) {
                                _unfocusSearch(); // <-- Tastatur zu, Suche nicht mehr aktiv
                              },
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                color: theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: premiumColor,
                              ),
                              suffixIcon:
                                  widget.searchController?.text.isNotEmpty ==
                                      true
                                  ? _buildScaleOnTapIcon(
                                    onTap: () {
                                      _unfocusSearch();
                                      (widget.onSearchCleared ?? () {})();
                                      setState(() {});
                                    },

                                    icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                      ),
                                      color: theme.hintColor,
                                    )
                                  : null,
                              filled: false,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                            ),
                          ),
                        ),
                        ),
                      ),
                      if (widget.onFiltersPressed != null) ...[
                        const SizedBox(width: 8),
                        _buildScaleOnTapIcon(
                          onTap: widget.onFiltersPressed!,
                          icon: const Icon(Icons.tune_rounded),
                          color: premiumColor,
                          tooltip: s.filterTooltip,
                          containerDecoration: BoxDecoration(
                            color:
                                theme.inputDecorationTheme.fillColor ??
                                colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          : null,
    )
    );
  }

  Widget _buildScaleOnTapIcon({
    required VoidCallback onTap,
    required Widget icon,
    Color? color,
    String? tooltip,
    Decoration? containerDecoration,
  }) {
    return GestureDetector(
      onTapDown: (_) => _scaleIcon(true),
      onTapUp: (_) => _scaleIcon(false),
      onTapCancel: () => _scaleIcon(false),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.95 : 1.0,
          _isPressed ? 0.95 : 1.0,
          1.0,
        ),
        decoration: containerDecoration,
        child: IconButton(
          icon: icon,
          onPressed: null,
          tooltip: tooltip,
          color: color,
        ),
      ),
    );
  }

  bool _isPressed = false;

  void _scaleIcon(bool pressed) {
    setState(() {
      _isPressed = pressed;
    });
  }
}

/// Animated Stat Card with hover effects
class AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final String? subValue;
  final int index;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.subValue,
    this.index = 0,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Default Gold (Tertiary) falls keine Farbe übergeben wurde
    final iconColor = widget.iconColor ?? colors.tertiary;

    return PremiumAnimations.fadeInStaggered(
      index: widget.index,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            transform: Matrix4.diagonal3Values(
              _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
              _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
              1.0,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: iconColor.withValues(alpha: _isHovered ? 0.5 : 0.1),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isHovered ? 0.08 : 0.04,
                  ),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: Offset(0, _isHovered ? 4 : 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(_isHovered ? 8 : 6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: _isHovered ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    size: _isHovered ? 18 : 16,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: _isHovered ? 20 : 18,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                  child: Text(widget.value),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subValue != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subValue!,
                    style: TextStyle(
                      fontSize: 9,
                      color: colors.tertiary, // Subvalues oft in Gold/Akzent
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated Quick Action Button
class AnimatedQuickActionButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final int index;

  const AnimatedQuickActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
    this.index = 0,
  });

  @override
  State<AnimatedQuickActionButton> createState() =>
      _AnimatedQuickActionButtonState();
}

class _AnimatedQuickActionButtonState extends State<AnimatedQuickActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeColor = widget.color ?? colors.tertiary;

    return PremiumAnimations.fadeInStaggered(
      index: widget.index,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            transform: Matrix4.diagonal3Values(
              _isPressed ? 0.98 : 1.0,
              _isPressed ? 0.98 : 1.0,
              1.0,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: activeColor.withValues(alpha: _isHovered ? 0.5 : 0.1),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isHovered ? 0.06 : 0.03,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(_isHovered ? 10 : 8),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(
                      alpha: _isHovered ? 0.15 : 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: activeColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isHovered ? 0.25 : 0.0,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced Loading Screen with Premium Animations
class PremiumLoadingScreen extends StatelessWidget {
  final String? message;

  const PremiumLoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final premiumColor = colorScheme.tertiary; // Gold
    final s = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: premiumColor.withValues(alpha: 0.1),
              border: Border.all(
                color: premiumColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: premiumColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          PremiumAnimations.shimmerLoading(
            isLoading: true,
            child: Text(
              message ?? s.loadingMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary, // Text nutzt Primary (Teal)
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          PremiumAnimations.goldShimmer(
            active: true,
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: colorScheme.primary, // Spinner nutzt Primary
                strokeWidth: 3,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
