import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PulseScore extends StatefulWidget {
  final int value;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final String? suffix;
  final bool animate;

  const PulseScore({
    super.key,
    required this.value,
    this.fontSize = 28,
    this.color = Colors.black,
    this.fontWeight = FontWeight.w800,
    this.suffix,
    this.animate = true,
  });

  @override
  State<PulseScore> createState() => _PulseScoreState();
}

class _PulseScoreState extends State<PulseScore> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(PulseScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _previousValue && widget.animate) {
      _previousValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Text(
        widget.suffix != null ? '${widget.value} ${widget.suffix}' : '${widget.value}',
        style: GoogleFonts.bricolageGrotesque(
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          color: widget.color,
        ),
      ),
    );
  }
}
