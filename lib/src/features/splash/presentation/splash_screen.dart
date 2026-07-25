import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// In-app animated splash: breathing brand gradient, logo fade-in, and
/// World-of-Goo-style rotating funny tips. Shown briefly after boot; calls
/// [onDone] after [minDuration] (or immediately on tap to skip).
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onDone,
    this.minDuration = const Duration(milliseconds: 2600),
  });

  final VoidCallback onDone;
  final Duration minDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bg; // breathing gradient (loops)
  late final AnimationController _intro; // logo fade + scale (once)
  Timer? _tipTimer;
  Timer? _doneTimer;
  bool _finished = false;

  int _tipIndex = 0;
  late final List<int> _tipOrder; // shuffled 1..10

  @override
  void initState() {
    super.initState();
    _bg = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _tipOrder = List<int>.generate(10, (i) => i + 1)..shuffle(Random());
    _tipTimer = Timer.periodic(
      const Duration(milliseconds: 1300),
      (_) => setState(() => _tipIndex = (_tipIndex + 1) % _tipOrder.length),
    );
    _doneTimer = Timer(widget.minDuration, _finish);
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _bg.dispose();
    _intro.dispose();
    _tipTimer?.cancel();
    _doneTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tips = <String>[
      l.splashTip1,
      l.splashTip2,
      l.splashTip3,
      l.splashTip4,
      l.splashTip5,
      l.splashTip6,
      l.splashTip7,
      l.splashTip8,
      l.splashTip9,
      l.splashTip10,
    ];
    final tip = tips[_tipOrder[_tipIndex] - 1];

    return GestureDetector(
      onTap: _finish, // tap anywhere to skip
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _bg,
          builder: (context, child) {
            final t = _bg.value; // 0..1
            return Container(
              // Fill the whole screen: otherwise the DecoratedBox shrinks to
              // the Column's widest child and the gradient wouldn't span it.
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Slowly rotating brand-tinted gradient (soft, keeps the
                  // dark logo wordmark readable).
                  begin: Alignment(-1 + 2 * t, -1),
                  end: Alignment(1, 1 - 2 * t),
                  colors: [
                    Color.lerp(
                        const Color(0xFFDCEBFA), const Color(0xFFE9F6EC), t)!,
                    Color.lerp(
                        const Color(0xFFE9F6EC), const Color(0xFFDCEBFA), t)!,
                  ],
                ),
              ),
              child: child,
            );
          },
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                _AnimatedLogo(controller: _intro),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (c, a) =>
                        FadeTransition(opacity: a, child: c),
                    child: Text(
                      tip,
                      key: ValueKey(tip),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo with a fade + gentle scale-in, then a subtle continuous breathing.
class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
        child: Image.asset('assets/branding/logo_tight.png', width: 180),
      ),
    );
  }
}
