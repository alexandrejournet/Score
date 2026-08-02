import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _coinController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _coinController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _coinController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: -pi, end: 0.0).animate(
      CurvedAnimation(parent: _coinController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _coinController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _coinController.dispose();
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
                  animation: _coinController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
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
