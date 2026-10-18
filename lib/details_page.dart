import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'movie.dart';
import 'ocean_background.dart';

/// Opens when a card is tapped. The poster flies from the card (Hero).
class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.movie, required this.discount});

  final Movie movie;
  final int discount;

  @override
  Widget build(BuildContext context) {
    // other movies, same genre first
    final others = movies.where((m) => m.title != movie.title).toList()
      ..sort((a, b) {
        final sa = a.genre == movie.genre ? 0 : 1;
        final sb = b.genre == movie.genre ? 0 : 1;
        return sa != sb ? sa.compareTo(sb) : b.rating.compareTo(a.rating);
      });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.glow),
        title: const Text('Now showing'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: OceanBackground()),
          // blurred poster as a colorful backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.38,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Image.asset(movie.image, fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bg.withOpacity(0.2),
                    AppColors.bg.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: kToolbarHeight + 8, bottom: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth > 760;
                          final poster = _poster();
                          final info = _info(context, wide);
                          if (wide) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  poster,
                                  const SizedBox(width: 44),
                                  Expanded(child: info),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [poster, const SizedBox(height: 26), info],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      FadeSlideIn(
                        delayMs: 650,
                        child: _moreLikeThis(context, others),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _poster() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withOpacity(0.45),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Hero(
        tag: 'poster_${movie.title}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Image.asset(
              movie.image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(BuildContext context, bool wide) {
    final align = wide ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final ta = wide ? TextAlign.left : TextAlign.center;
    return Column(
      crossAxisAlignment: align,
      children: [
        FadeSlideIn(
          delayMs: 250,
          child: Text(
            movie.title,
            textAlign: ta,
            style: const TextStyle(
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: Colors.white,
              shadows: [Shadow(color: AppColors.glow, blurRadius: 20)],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          delayMs: 350,
          child: Wrap(
            alignment: wide ? WrapAlignment.start : WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(Icons.star_rounded, movie.rating.toString()),
              _chip(Icons.theaters_rounded, movie.genre),
              _chip(Icons.calendar_month_rounded, '${movie.year}'),
              _chip(Icons.local_offer_rounded, '-$discount%'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FadeSlideIn(
          delayMs: 450,
          child: Text(
            movie.overview,
            textAlign: ta,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.7,
              fontSize: 15.5,
            ),
          ),
        ),
        const SizedBox(height: 28),
        FadeSlideIn(
          delayMs: 550,
          child: _WatchButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.electric,
                  content: Text('Enjoy "${movie.title}" 🌊'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _moreLikeThis(BuildContext context, List<Movie> others) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'More like this',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: others.length,
            itemBuilder: (context, i) {
              final m = others[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    fadeRoute(DetailsPage(movie: m, discount: discount)),
                  ),
                  child: SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.glow.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.glow.withOpacity(0.18),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              m.image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${m.genre} · ${m.rating} ★',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: AppColors.glow.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.glow),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _WatchButton extends StatelessWidget {
  const _WatchButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.glow, AppColors.electric],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withOpacity(0.55),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 44, vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Watch now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.5,
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
