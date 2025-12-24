// lib/animations/premium_animations.dart
import 'dart:math'; // ✅ Math-Funktionen importieren
import 'package:flutter/material.dart';
import '../theme.dart';

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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface2 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.transparent,
                AppTheme.gold.withValues(alpha: 0.1),
                AppTheme.gold.withValues(alpha: 0.2),
                AppTheme.gold.withValues(alpha: 0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              begin: const Alignment(-1.0, 0.0),
              end: const Alignment(1.0, 0.0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            color: isDark ? AppTheme.surface : Colors.white,
          ),
        ),
      ),
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
        return Transform.scale(
          scale: value,
          child: child,
        );
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
  // FADE IN ANIMATION (MIT DELAY)
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
  // GOLD GLOW ANIMATION (KORRIGIERT)
  // ==============================
  static Widget goldGlow({
    required Widget child,
    bool animate = true,
    double intensity = 0.15,
  }) {
    if (!animate) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final double glowValue = (value * 2 * pi); // ✅ pi von dart:math
        final double glow = (sin(glowValue) + 1) / 2 * intensity; // ✅ sin von dart:math

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: glow),
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
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // ==============================
  // ROTATING LOADING
  // ==============================
  static Widget rotatingLoading({
    double size = 24,
    Color color = AppTheme.gold,
    double strokeWidth = 2.5,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  // ==============================
  // BOUNCE ANIMATION (KORRIGIERT)
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
        final double bounce = sin(value * 2 * pi) * intensity; // ✅ sin von dart:math

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
  // PULSE ANIMATION (für wichtige Elemente)
  // ==============================
  static Widget pulse({
    required Widget child,
    bool active = true,
    Color pulseColor = AppTheme.gold,
    double maxScale = 1.05,
  }) {
    if (!active) return child;

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
                    color: pulseColor.withValues(alpha: opacity),
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
  }

  // ==============================
  // RIPPLE EFFECT ANIMATION
  // ==============================
  static Widget ripple({
    required Widget child,
    required VoidCallback onTap,
    Color rippleColor = AppTheme.gold,
    double rippleRadius = 20,
  }) {
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
                  color: rippleColor.withValues(alpha: 1 - value),
                ),
              );
            },
            child: null,
          ),
        ],
      ),
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