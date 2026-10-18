import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'movie.dart';

/// Cover-flow carousel with 3D tilt and a card FLIP:
/// - the middle poster is big and glowing, the side posters are smaller,
///   dimmer and tilted in 3D
/// - tap the middle poster: it flips around (rotateY) and shows its info
/// - it auto-plays, can be dragged (touch or mouse) and loops forever
class MovieCarousel extends StatefulWidget {
  const MovieCarousel({super.key, required this.items, required this.onOpen});

  final List<Movie> items;
  final void Function(Movie movie) onOpen;

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel>
    with TickerProviderStateMixin {
  // the "page" value: 0.0 = first movie centered, 1.0 = second, ...
  late final AnimationController _page =
      AnimationController.unbounded(vsync: this, value: 0);
  // 0 = front (poster), 1 = back (info)
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  Timer? _timer;

  int get _n => widget.items.length;
  int get _current => _page.value.round() % _n;
  bool get _flipped =>
      _flip.status == AnimationStatus.completed ||
      _flip.status == AnimationStatus.forward;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    _flip.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_flipped) return; // do not move while the user reads the info
      _goTo(_page.value.round() + 1);
    });
  }

  void _goTo(int target) {
    _flip.reverse();
    _page.animateTo(
      target.toDouble(),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleFlip() {
    if (_flipped) {
      _flip.reverse();
      _startTimer();
    } else {
      _timer?.cancel();
      _flip.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = math.min(270.0, constraints.maxWidth * 0.58);
        final cardH = cardW * 1.5;
        final spacing = cardW * 0.80;

        return Column(
          children: [
            SizedBox(
              height: cardH + 50,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) {
                  _timer?.cancel();
                  _flip.reverse();
                },
                onHorizontalDragUpdate: (d) {
                  _page.stop();
                  _page.value -= d.delta.dx / spacing;
                },
                onHorizontalDragEnd: (d) {
                  final pages = -(d.primaryVelocity ?? 0) / spacing * 0.18;
                  _goTo((_page.value + pages).round());
                  _startTimer();
                },
                child: AnimatedBuilder(
                  animation: Listenable.merge([_page, _flip]),
                  builder: (context, _) => _buildStack(cardW, cardH, spacing),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _page,
              builder: (context, _) => _buildInfo(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStack(double cardW, double cardH, double spacing) {
    final page = _page.value;
    final n = _n;

    final slots = <MapEntry<int, double>>[];
    for (int i = 0; i < n; i++) {
      // shortest signed distance to the center, wrapped for looping
      final d = ((i - page + n / 2) % n) - n / 2;
      if (d.abs() <= 2.6) slots.add(MapEntry(i, d));
    }
    // far cards first, the centered one is painted last (on top)
    slots.sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // the blue glow behind the center poster
        Center(
          child: Container(
            width: cardW * 2.4,
            height: cardH * 1.05,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.glow.withOpacity(0.38),
                  AppColors.electric.withOpacity(0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        for (final slot in slots)
          _buildCard(slot.key, slot.value, cardW, cardH, spacing),
      ],
    );
  }

  Widget _buildCard(
      int index, double d, double cardW, double cardH, double spacing) {
    final ad = d.abs();
    final scale = (1 - 0.16 * ad).clamp(0.55, 1.0).toDouble();
    final opacity = (1 - 0.40 * ad).clamp(0.0, 1.0).toDouble();
    final dx =
        d.sign * (ad <= 1 ? ad * spacing : spacing + (ad - 1) * spacing * 0.75);
    final focus = (1 - ad).clamp(0.0, 1.0).toDouble();
    final movie = widget.items[index];

    final isCenter = ad < 0.5;
    final flipAngle = isCenter ? _flip.value * math.pi : 0.0;
    final showBack = isCenter && _flip.value > 0.5;
    // side cards are tilted in 3D toward the center
    final tilt = -d.clamp(-1.5, 1.5).toDouble() * 0.5;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateY(tilt + flipAngle);

    return Transform.translate(
      offset: Offset(dx, 0),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: () {
              if (isCenter) {
                _toggleFlip();
              } else {
                _timer?.cancel();
                _goTo(_page.value.round() + d.round());
                _startTimer();
              }
            },
            child: SizedBox(
              width: cardW,
              height: cardH,
              child: Transform(
                alignment: Alignment.center,
                transform: transform,
                child: showBack
                    // the back face is mirrored by the flip, so mirror it back
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: _BackTile(
                          movie: movie,
                          onOpen: () => widget.onOpen(movie),
                        ),
                      )
                    : _PosterTile(movie: movie, focus: focus),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    final movie = widget.items[_current];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Column(
              key: ValueKey(movie.title),
              children: [
                Text(
                  movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [AppColors.glow, AppColors.electric],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glow.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => widget.onOpen(movie),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Watch',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _n; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: i == _current ? 22 : 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _current
                        ? AppColors.glow
                        : Colors.white.withOpacity(0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap the middle poster to flip it',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PosterTile extends StatelessWidget {
  const _PosterTile({required this.movie, required this.focus});

  final Movie movie;
  final double focus; // 1 = centered, 0 = far

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.glow.withOpacity(0.15 + 0.45 * focus),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withOpacity(0.55 * focus),
            blurRadius: 36,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            movie.image,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.55, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 14,
            child: Text(
              '${movie.rating} ★',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _pill('${movie.year}'),
                    _pill(movie.genre),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The back of the flipped card: story + a button to open the details.
class _BackTile extends StatelessWidget {
  const _BackTile({required this.movie, required this.onOpen});

  final Movie movie;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1456C8), Color(0xFF0A2A66), Color(0xFF04122B)],
        ),
        border: Border.all(color: AppColors.glow.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withOpacity(0.55),
            blurRadius: 36,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.glow, size: 20),
              const SizedBox(width: 4),
              Text(
                '${movie.rating}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [_pill('${movie.year}'), _pill(movie.genre)],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              movie.overview,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.glow,
                foregroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Open details',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _pill(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.16),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );
}
