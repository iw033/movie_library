import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_style.dart';

const double _tau = math.pi * 2;

/// Animated ocean-colored backdrop: deep blue water, swaying light rays,
/// drifting glow orbs, rising bubbles and falling petals/light flakes.
/// If a [scroll] controller is given, the layers move at different speeds
/// while the page scrolls (parallax). Pure CustomPainter, no assets.
class OceanBackground extends StatefulWidget {
  const OceanBackground({super.key, this.scroll});

  final ScrollController? scroll;

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _OceanPainter(_controller, widget.scroll),
        size: Size.infinite,
      ),
    );
  }
}

class _Particle {
  const _Particle(this.x, this.phase, this.speed, this.size, this.sway);

  final double x;
  final double phase;
  final int speed;
  final double size;
  final double sway;
}

class _OceanPainter extends CustomPainter {
  _OceanPainter(this.anim, this.scroll)
      : super(
          repaint: scroll == null ? anim : Listenable.merge([anim, scroll]),
        );

  final Animation<double> anim;
  final ScrollController? scroll;

  static final List<_Particle> _bubbles = List.generate(30, (i) {
    final r = math.Random(i * 7 + 3);
    return _Particle(
      r.nextDouble(),
      r.nextDouble(),
      1 + r.nextInt(3),
      2 + r.nextDouble() * 6,
      8 + r.nextDouble() * 14,
    );
  });

  static final List<_Particle> _petals = List.generate(18, (i) {
    final r = math.Random(i * 13 + 11);
    return _Particle(
      r.nextDouble(),
      r.nextDouble(),
      3 + r.nextInt(4),
      4 + r.nextDouble() * 5,
      20 + r.nextDouble() * 30,
    );
  });

  double get _offset {
    final s = scroll;
    if (s == null || !s.hasClients) return 0;
    return math.max(0.0, s.offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    final off = _offset;

    // deep water
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(w / 2, 0),
          Offset(w / 2, h),
          const [Color(0xFF0A3F94), Color(0xFF062454), Color(0xFF020B1A)],
          const [0.0, 0.40, 0.9],
        ),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w * 0.8, -h * 0.02 - off * 0.1),
          math.max(w, h) * 0.55,
          [AppColors.glow.withOpacity(0.38), AppColors.glow.withOpacity(0.0)],
        ),
    );

    // light rays (slowest layer)
    for (int i = 0; i < 5; i++) {
      final sway = math.sin(_tau * (t * 2 + i / 5)) * 28;
      final x0 = w * (0.05 + i * 0.24) + sway - off * 0.06;
      final path = Path()
        ..moveTo(x0 - 8, 0)
        ..lineTo(x0 + 22, 0)
        ..lineTo(x0 + 130 + sway, h * 0.9)
        ..lineTo(x0 - 90 + sway, h * 0.9)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(x0, 0),
            Offset(x0, h * 0.9),
            [AppColors.ice.withOpacity(0.14), AppColors.ice.withOpacity(0.0)],
          ),
      );
    }

    // glow orbs (medium layer)
    const orbs = [
      [0.15, 0.30, 180.0, 0.0],
      [0.85, 0.60, 220.0, 0.4],
      [0.45, 0.90, 200.0, 0.7],
    ];
    for (final o in orbs) {
      final cx = w * o[0] + math.sin(_tau * (t * 2 + o[3])) * 40;
      final cy = h * o[1] + math.sin(_tau * (t * 3 + o[3])) * 30 - off * 0.25;
      canvas.drawCircle(
        Offset(cx, cy),
        o[2],
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(cx, cy),
            o[2],
            [
              AppColors.electric.withOpacity(0.22),
              AppColors.electric.withOpacity(0.0),
            ],
          ),
      );
    }

    // bubbles rising
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint();
    for (final b in _bubbles) {
      final prog = (t * b.speed + b.phase) % 1.0;
      final y = h * (1.05 - prog * 1.15) - off * 0.12;
      final x = b.x * w + math.sin(_tau * (t * b.speed * 2 + b.phase)) * b.sway;
      line.color = Colors.white.withOpacity(0.10 + 0.20 * (1 - prog));
      fill.color = Colors.white.withOpacity(0.04);
      canvas.drawCircle(Offset(x, y), b.size, fill);
      canvas.drawCircle(Offset(x, y), b.size, line);
    }

    // petals / light flakes falling diagonally (fastest layer)
    final petal = Paint();
    for (final p in _petals) {
      final prog = (t * p.speed + p.phase) % 1.0;
      final y = (prog * (h + 80) - 40 + off * 0.35) % (h + 80) - 40;
      final x = (p.x * w + prog * w * 0.25 +
              math.sin(_tau * (t * p.speed * 2 + p.phase)) * p.sway) %
          w;
      petal.color = AppColors.ice.withOpacity(0.35 + 0.25 * math.sin(prog * math.pi));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(_tau * (t * p.speed * 2 + p.phase));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: p.size * 2, height: p.size),
        petal,
      );
      canvas.restore();
    }

    // vignette
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w / 2, h / 2),
          math.max(w, h) * 0.75,
          [Colors.transparent, Colors.black.withOpacity(0.55)],
          const [0.55, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _OceanPainter oldDelegate) => false;
}
