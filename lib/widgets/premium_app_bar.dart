import 'package:flutter/material.dart';
import '../theme.dart';

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
      duration: Duration(milliseconds: duration.inMilliseconds + (index * delay.inMilliseconds)),
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
  static Widget shimmerLoading({
    required Widget child,
    bool isLoading = false,
    Color shimmerColor = AppTheme.gold,
  }) {
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
                    shimmerColor.withAlpha(40),
                    shimmerColor.withAlpha(80),
                    shimmerColor.withAlpha(40),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
      ],
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
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        duration: duration,
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  /// Gold shimmer effect for premium elements
  static Widget goldShimmer({
    required Widget child,
    bool active = true,
  }) {
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
                      AppTheme.gold.withAlpha(20),
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
          return Transform.scale(
            scale: controller.value,
            child: child,
          );
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
class PremiumAnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
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

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: widget.showBackButton
          ? _buildScaleOnTapIcon(
        onTap: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
        color: theme.colorScheme.onSurface,
      )
          : widget.onMenuPressed != null
          ? _buildScaleOnTapIcon(
        onTap: widget.onMenuPressed!,
        icon: const Icon(Icons.menu_rounded),
        color: theme.colorScheme.onSurface,
        tooltip: 'القائمة',
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
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
      actions: [
        AnimatedBuilder(
          animation: _titleAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _titleAnimation.value)),
              child: Opacity(
                opacity: _titleAnimation.value,
                child: child,
              ),
            );
          },
          child: Row(
            children: [
              PremiumAnimations.pulse(
                active: true,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.gold, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withAlpha(80),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.asset(
                      'assets/icon/wolf.png',
                      fit: BoxFit.cover,
                      color: isDark ? null : Colors.black.withAlpha(200),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (widget.showSettings && widget.onMenuPressed == null)
                _buildScaleOnTapIcon(
                  onTap: () => Navigator.of(context).pushNamed('/settings'),
                  icon: const Icon(Icons.settings_outlined),
                  color: theme.colorScheme.onSurface.withAlpha(180),
                  tooltip: 'الإعدادات',
                ),
              ...?widget.actions,
            ],
          ),
        ),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surface2 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline, width: 1),
                    ),
                    child: TextField(
                      controller: widget.searchController,
                      onChanged: widget.onSearchChanged,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث بالاسم أو ID',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(100),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.gold),
                        suffixIcon: widget.searchController?.text.isNotEmpty == true
                            ? _buildScaleOnTapIcon(
                          onTap: widget.onSearchCleared ?? () {},
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          color: AppTheme.muted,
                        )
                            : null,
                        filled: false,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      ),
                    ),
                  ),
                ),
                if (widget.onFiltersPressed != null) ...[
                  const SizedBox(width: 8),
                  _buildScaleOnTapIcon(
                    onTap: widget.onFiltersPressed!,
                    icon: const Icon(Icons.tune_rounded),
                    color: AppTheme.gold,
                    tooltip: 'فلتر',
                    containerDecoration: BoxDecoration(
                      color: isDark ? AppTheme.surface2 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline, width: 1),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      )
          : null,
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
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.gold.withAlpha(_isHovered ? 50 : 30),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_isHovered ? 20 : 10),
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
                    color: (widget.iconColor ?? AppTheme.gold)
                        .withAlpha(_isHovered ? 40 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    size: _isHovered ? 18 : 16,
                    color: widget.iconColor ?? AppTheme.gold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: _isHovered ? 20 : 18,
                    fontWeight: FontWeight.w900,
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
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subValue != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subValue!,
                    style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.gold.withAlpha(180),
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
  State<AnimatedQuickActionButton> createState() => _AnimatedQuickActionButtonState();
}

class _AnimatedQuickActionButtonState extends State<AnimatedQuickActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.gold.withAlpha(_isHovered ? 50 : 30),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_isHovered ? 15 : 10),
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
                    color: (widget.color ?? AppTheme.gold)
                        .withAlpha(_isHovered ? 40 : 25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color ?? AppTheme.gold,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isHovered ? 0.25 : 0.0,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withAlpha(100),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PremiumAnimations.pulse(
            active: true,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.gold, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withAlpha(128),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/icon/wolf.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PremiumAnimations.shimmerLoading(
            isLoading: true,
            child: Text(
              message ?? 'جاري التحميل...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.gold,
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
                color: AppTheme.gold,
                strokeWidth: 3,
                backgroundColor: AppTheme.gold.withAlpha(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}