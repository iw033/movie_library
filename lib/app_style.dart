import 'package:flutter/material.dart';

/// Colors of the "Blue Ocean" theme (the glowing blue tone).
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF020B1A); // deep sea
  static const Color card = Color(0xFF0A1B36); // card background (used via Theme.cardColor)
  static const Color glow = Color(0xFF3DDCFF); // the blue glow
  static const Color electric = Color(0xFF1E6BFF); // electric blue
  static const Color ice = Color(0xFFBFF3FF); // light ice blue
}

/// Smooth fade + slide-up route used for every page change.
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Fade + slide-up entrance animation. It is a StatelessWidget
/// (TweenAnimationBuilder keeps the animation state for us).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offset = 40,
  });

  final Widget child;
  final int delayMs;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final total = delayMs + 700;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1.0, curve: Curves.easeOutCubic),
      builder: (context, v, child) {
        return Opacity(
          opacity: v.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(
            offset: Offset(0, offset * (1 - v)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
