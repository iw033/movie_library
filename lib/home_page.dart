import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'details_page.dart';
import 'movie.dart';
import 'movie_card.dart';
import 'movie_carousel.dart';
import 'ocean_background.dart';
import 'scroll_reveal.dart';

/// PART 4 + PART 5 + BONUS
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = ''; // PART 5: typed text (no TextEditingController)
  String _genre = 'All'; // extra: genre chips
  bool _isGrid = true; // PART 4: list <-> grid
  int _discount = 20; // BONUS: ONE value shared by every card

  final ScrollController _scroll = ScrollController();
  final GlobalKey _libraryKey = GlobalKey();

  double get _offset => _scroll.hasClients ? math.max(0.0, _scroll.offset) : 0.0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scroll.animateTo(0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic);
  }

  void _scrollToLibrary() {
    final ctx = _libraryKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
  }

  List<String> get _genres =>
      ['All', ...movies.map((m) => m.genre).toSet()];

  /// Filter by title OR genre, case-insensitive (+ the selected chip).
  List<Movie> get _filteredMovies {
    final q = _query.trim().toLowerCase();
    return movies
        .where((m) => _genre == 'All' || m.genre == _genre)
        .where((m) =>
            m.title.toLowerCase().contains(q) ||
            m.genre.toLowerCase().contains(q))
        .toList();
  }

  /// BONUS: the card calls this -> we change the value here -> setState
  /// rebuilds HomePage -> every card gets the new number.
  void _onDiscountTap() {
    setState(() {
      _discount = _discount > 1 ? _discount - 1 : 20;
    });
  }

  void _openDetails(Movie movie) {
    Navigator.of(context).push(
      fadeRoute(DetailsPage(movie: movie, discount: _discount)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredMovies;
    final featured = ([...movies]..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(7)
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: AnimatedBuilder(
        animation: _scroll,
        builder: (context, _) => AnimatedScale(
          scale: _offset > 400 ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: FloatingActionButton.small(
            backgroundColor: AppColors.electric,
            onPressed: _scrollToTop,
            child: const Icon(Icons.keyboard_arrow_up_rounded,
                color: Colors.white),
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedBuilder(
          animation: _scroll,
          builder: (context, _) => _buildAppBar(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: OceanBackground(scroll: _scroll)),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      const SizedBox(height: kToolbarHeight),
                      // parallax: the title scrolls slower and fades out
                      AnimatedBuilder(
                        animation: _scroll,
                        builder: (context, child) => Opacity(
                          opacity: (1 - _offset / 260).clamp(0.0, 1.0).toDouble(),
                          child: Transform.translate(
                            offset: Offset(0, _offset * 0.45),
                            child: child,
                          ),
                        ),
                        child: const _Header(),
                      ),
                      const SizedBox(height: 8),
                      MovieCarousel(items: featured, onOpen: _openDetails),
                      const SizedBox(height: 34),
                      KeyedSubtree(
                        key: _libraryKey,
                        child: _sectionTitle(list.length),
                      ),
                      _searchField(),
                      _genreChips(),
                      const SizedBox(height: 8),
                      _buildContent(list),
                      const _Footer(),
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

  PreferredSizeWidget _buildAppBar() {
    final wide = MediaQuery.of(context).size.width >= 700;
    return AppBar(
      // transparent at the top, glassy dark blue after scrolling
      backgroundColor:
          AppColors.bg.withOpacity((_offset / 220).clamp(0.0, 0.85).toDouble()),
      title: const Text('Movie Library'),
      actions: [
        if (wide) ...[
          TextButton(
            onPressed: _scrollToTop,
            child: const Text('Home', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: _scrollToLibrary,
            child: const Text('Movies', style: TextStyle(color: Colors.white70)),
          ),
        ],
        IconButton(
          tooltip: _isGrid ? 'List view' : 'Grid view',
          onPressed: () => setState(() => _isGrid = !_isGrid),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              _isGrid ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
              key: ValueKey<bool>(_isGrid),
              color: AppColors.glow,
            ),
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _sectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'All movies',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glow.withOpacity(0.5)),
              color: Colors.white.withOpacity(0.06),
            ),
            child: Text(
              '$count movies',
              style: const TextStyle(color: AppColors.ice, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // PART 5: TextField with onChanged only (no TextEditingController)
  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: (value) => setState(() => _query = value),
        cursorColor: AppColors.glow,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search movies...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: AppColors.glow),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: _border(AppColors.glow.withOpacity(0.30), 1),
          enabledBorder: _border(AppColors.glow.withOpacity(0.30), 1),
          focusedBorder: _border(AppColors.glow, 1.8),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _genreChips() {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final g in _genres)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g),
                selected: _genre == g,
                showCheckmark: false,
                onSelected: (_) => setState(() => _genre = g),
                selectedColor: AppColors.electric,
                backgroundColor: Colors.white.withOpacity(0.07),
                side: BorderSide(color: AppColors.glow.withOpacity(0.35)),
                labelStyle: TextStyle(
                  color: _genre == g ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Movie> list) {
    // PART 5: nothing matches
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 70),
        child: Center(
          child: Text(
            'No movies found',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final columns = width < 700 ? 2 : (width < 1000 ? 3 : 4);

    // PART 4: GridView.builder (SliverGridDelegateWithFixedCrossAxisCount)
    // 2 columns on phones, more columns on wide screens (web).
    if (_isGrid) {
      return GridView.builder(
        key: const ValueKey('grid'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.64,
        ),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final movie = list[i];
          return ScrollReveal(
            key: ValueKey(movie.title),
            controller: _scroll,
            delayMs: (i % columns) * 110,
            child: MovieCard(
              movie: movie,
              index: i,
              discount: _discount,
              onDiscountTap: _onDiscountTap,
              onTap: () => _openDetails(movie),
            ),
          );
        },
      );
    }

    // PART 4: ListView.builder, one movie per row
    return ListView.builder(
      key: const ValueKey('list'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final movie = list[i];
        return Center(
          key: ValueKey(movie.title),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: SizedBox(
                height: 360,
                child: ScrollReveal(
                  controller: _scroll,
                  child: MovieCard(
                    movie: movie,
                    index: i,
                    discount: _discount,
                    onDiscountTap: _onDiscountTap,
                    onTap: () => _openDetails(movie),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Big glowing title under the AppBar.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Column(
          children: [
            const Text(
              'NOW SHOWING · TOP RATED',
              style: TextStyle(
                color: AppColors.glow,
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                colors: [Colors.white, AppColors.ice, AppColors.glow],
              ).createShader(rect),
              child: const Text(
                'Blue Ocean.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  shadows: [Shadow(color: AppColors.glow, blurRadius: 22)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
      child: Column(
        children: [
          Container(
            height: 1,
            color: AppColors.glow.withOpacity(0.25),
          ),
          const SizedBox(height: 18),
          const Text(
            'BLUE OCEAN · MOVIE LIBRARY',
            style: TextStyle(
              color: AppColors.glow,
              letterSpacing: 3,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Made with Flutter',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
