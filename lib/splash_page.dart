import 'dart:async';

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'home_page.dart';
import 'ocean_background.dart';

/// Intro screen (like the "Blue Ocean" design): it fades into the home page
/// after a few seconds, or immediately when the user taps "Dive in".
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _duration = Duration(milliseconds: 4200);

  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_duration, _goHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goHome() {
    if (_leaving || !mounted) return;
    _leaving = true;
    Navigator.of(context).pushReplacement(fadeRoute(const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: OceanBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),
                  const FadeSlideIn(
                    child: Text(
                      'BLUE OCEAN · CINEMA',
                      style: TextStyle(
                        color: AppColors.glow,
                        letterSpacing: 4,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const FadeSlideIn(
                    delayMs: 200,
                    offset: 60,
                    child: Text(
                      'Blue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 96,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -3,
                        shadows: [
                          Shadow(color: AppColors.glow, blurRadius: 36),
                        ],
                      ),
                    ),
                  ),
                  FadeSlideIn(
                    delayMs: 450,
                    offset: 60,
                    child: Transform.translate(
                      offset: const Offset(6, -8),
                      child: const Text(
                        'Ocean.',
                        style: TextStyle(
                          color: AppColors.ice,
                          fontSize: 44,
                          height: 1,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const FadeSlideIn(
                    delayMs: 700,
                    child: Text(
                      'Your movie library, one dive away.\nSearch, browse and enjoy.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  FadeSlideIn(
                    delayMs: 900,
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: _goHome,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        label: const Text('Dive in'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.glow),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 34,
                            vertical: 14,
                          ),
                          backgroundColor: AppColors.glow.withOpacity(0.10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // loading line that fills while we wait
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: _duration,
                    builder: (context, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 3,
                        color: AppColors.glow,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
