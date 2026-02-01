// lib/animations/premium_animations.dart
import 'dart:math';
import 'package:flutter/material.dart';
// import '../theme.dart'; // Nicht mehr nötig

class PremiumAnimations {
  // ==============================
  // SHIMMER LOADING EFFECT
  // ==============================
  static Widget shimmerLoading({
    double? width,
    double? height,
    double borderRadius = 16,
    bool isDark = true,
  }) {
    // Wir nutzen Builder, um auf das Theme zuzugreifen
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        // Schimmer-Farbe: Primärfarbe (Teal) oder Tertiary (Gold)
        final shimmerColor = colors.primary;
        final baseColor = isDark
            ? colors
                  .surfaceContainerHighest // Dunkles Grau im Dark Mode
            : Colors.grey.shade200;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Colors.transparent,
                    shimmerColor.withValues(alpha: 0.1),
                    shimmerColor.withValues(alpha: 0.2),
                    shimmerColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  begin: const Alignment(-1.0, 0.0),
                  end: const Alignment(1.0, 0.0),
                  tileMode: TileMode.clamp,
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Container(color: colors.surface),
            ),
          ),
        );
      },
    );
  }

  // ==============================
  // PULSATING GOLD EFFECT
  // ==============================
  static Widget pulsatingGold({
    required Widget child,
    bool isActive = true,
    double minScale = 0.98,
    double maxScale = 1.02,
  }) {
    if (!isActive) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minScale, end: maxScale),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  // ==============================
  // SCALE ON TAP ANIMATION
  // ==============================
  static Widget scaleOnTap({
    required Widget child,
    required VoidCallback onTap,
    double tapScale = 0.95,
  }) {
    bool isPressed = false;

    return GestureDetector(
      onTapDown: (_) => isPressed = true,
      onTapUp: (_) => isPressed = false,
      onTapCancel: () => isPressed = false,
      onTap: onTap,
      child: StatefulBuilder(
        builder: (context, setState) {
          return AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isPressed ? tapScale : 1.0,
            curve: Curves.easeOutBack,
            child: child,
          );
        },
      ),
    );
  }

  // ==============================
  // FADE IN ANIMATION
  // ==============================
  static Widget fadeIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOutCubic,
    double startOpacity = 0.0,
    double endOpacity = 1.0,
    Offset offset = const Offset(0, 20),
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool visible = false;

        Future.delayed(delay, () {
          if (context.mounted) {
            setState(() => visible = true);
          }
        });

        return AnimatedOpacity(
          opacity: visible ? endOpacity : startOpacity,
          duration: duration,
          curve: curve,
          child: Transform.translate(
            offset: visible ? Offset.zero : offset,
            child: child,
          ),
        );
      },
    );
  }

  // ==============================
  // GOLD GLOW ANIMATION
  // ==============================
  static Widget goldGlow({
    required Widget child,
    bool animate = true,
    double intensity = 0.15,
  }) {
    if (!animate) return child;

    return Builder(
      builder: (context) {
        // Tertiary ist unser neues Gold
        final glowColor = Theme.of(context).colorScheme.tertiary;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final double glowValue = (value * 2 * pi);
            final double glow = (sin(glowValue) + 1) / 2 * intensity;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: glow),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }

  // ==============================
  // SLIDE IN ANIMATION
  // ==============================
  static Widget slideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutBack,
    Offset beginOffset = const Offset(0, 30),
    Offset endOffset = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: beginOffset, end: endOffset),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(offset: value, child: child);
      },
      child: child,
    );
  }

  // ==============================
  // ROTATING LOADING
  // ==============================
  static Widget rotatingLoading({
    double size = 24,
    Color? color,
    double strokeWidth = 2.5,
  }) {
    return Builder(
      builder: (context) {
        // Default: Primary (Teal) statt Gold
        final c = color ?? Theme.of(context).colorScheme.primary;

        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(c),
          ),
        );
      },
    );
  }

  // ==============================
  // BOUNCE ANIMATION
  // ==============================
  static Widget bounce({
    required Widget child,
    bool animate = true,
    double intensity = 0.1,
  }) {
    if (!animate) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final double bounce = sin(value * 2 * pi) * intensity;

        return Transform.translate(
          offset: Offset(0, -bounce * 20),
          child: child,
        );
      },
      child: child,
    );
  }

  // ==============================
  // STAGGERED FADE IN LIST
  // ==============================
  static Widget staggeredFadeInList({
    required List<Widget> children,
    Duration interval = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Column(
      children: List.generate(children.length, (index) {
        return fadeIn(
          child: children[index],
          delay: interval * index,
          duration: duration,
        );
      }),
    );
  }

  // ==============================
  // PULSE ANIMATION
  // ==============================
  static Widget pulse({
    required Widget child,
    bool active = true,
    Color? pulseColor,
    double maxScale = 1.05,
  }) {
    if (!active) return child;

    return Builder(
      builder: (context) {
        // Default: Primary (Teal)
        final c = pulseColor ?? Theme.of(context).colorScheme.primary;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: maxScale),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 0.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, opacity, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.withValues(alpha: opacity),
                      ),
                      width: 100 * scale,
                      height: 100 * scale,
                    ),
                    child!,
                  ],
                );
              },
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }

  // ==============================
  // RIPPLE EFFECT ANIMATION
  // ==============================
  static Widget ripple({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
    double rippleRadius = 20,
  }) {
    return Builder(
      builder: (context) {
        // Default: Primary (Teal)
        final c = rippleColor ?? Theme.of(context).colorScheme.primary;

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              child,
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Container(
                    width: rippleRadius * value * 2,
                    height: rippleRadius * value * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.withValues(alpha: 1 - value),
                    ),
                  );
                },
                child: null,
              ),
            ],
          ),
        );
      },
    );
  }

  // ==============================
  // FLIP ANIMATION
  // ==============================
  static Widget flip({
    required Widget front,
    required Widget back,
    bool showFront = true,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: showFront ? 0.0 : 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final angle = value * pi; // 0 bis π (180 Grad)

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle),
          alignment: Alignment.center,
          child: value < 0.5 ? front : back,
        );
      },
      child: null,
    );
  }
}
