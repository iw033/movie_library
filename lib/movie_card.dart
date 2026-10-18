import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'movie.dart';

/// PART 3: THE MOVIE CARD (Container + Stack).
///
/// This widget is STATELESS. The discount value is NOT stored here:
/// it lives in HomePage's State and comes in through the constructor,
/// and a tap is reported back with a VoidCallback (BONUS).
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.discount,
    required this.onDiscountTap,
    this.onTap,
    this.index = 0,
  });

  final Movie movie;
  final int discount; // BONUS: same value on every card
  final VoidCallback onDiscountTap; // BONUS: tell the parent to change it
  final VoidCallback? onTap;
  final int index; // only used for the staggered entrance animation

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeSlideIn(
      delayMs: math.min(index, 8) * 90,
      child: Container(
        // clipBehavior so the image follows the rounded corners
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.cardColor, // background color taken from the app theme
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.glow.withOpacity(0.20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.glow.withOpacity(0.28),
              blurRadius: 22,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Poster + Stack ----------
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'poster_${movie.title}',
                        child: Image.asset(
                          movie.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      // soft dark gradient so the white texts are readable
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.55, 1.0],
                                colors: [
                                  Colors.black.withOpacity(0.35),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.75),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // TOP-LEFT: rating badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electric,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glow.withOpacity(0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                movie.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // TOP-RIGHT: bookmark icon
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.bookmark_border_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),

                      // BOTTOM-LEFT: release year
                      Positioned(
                        bottom: 10,
                        left: 12,
                        child: Text(
                          movie.year.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      // BOTTOM-RIGHT (BONUS): discount badge, tap it = all cards change
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onDiscountTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.glow, AppColors.electric],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.glow.withOpacity(0.55),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                              child: Text(
                                '-$discount%',
                                key: ValueKey<int>(discount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- Title + genre ----------
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        movie.genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
