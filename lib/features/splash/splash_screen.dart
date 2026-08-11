import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _coinController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _coinController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _coinController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: -pi * 2, end: 0.0).animate(
      CurvedAnimation(
        parent: _coinController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.85), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _coinController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    _pulseController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      final onboardingDone = await OnboardingScreen.isDone();
      if (mounted) {
        context.go(onboardingDone ? '/dashboard' : '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _coinController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0e2358),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'lib/assets/Score-no-coin.png',
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),
                AnimatedBuilder(
                  animation: Listenable.merge([_coinController, _pulseController]),
                  builder: (context, child) {
                    final baseScale = _scaleAnimation.value;
                    final pulseScale = _pulseController.isAnimating ? _pulseAnimation.value : 1.0;
                    return Transform.scale(
                      scale: baseScale * pulseScale,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'lib/assets/Score-coin.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
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
