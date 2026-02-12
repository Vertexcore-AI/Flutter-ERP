import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AnimatedRotatingText extends StatefulWidget {
  final String staticText;
  final List<String> rotatingWords;
  final String? suffixText;
  final Duration duration;
  final TextStyle? textStyle;
  final TextStyle? rotatingTextStyle;
  final TextStyle? suffixTextStyle;

  const AnimatedRotatingText({
    super.key,
    required this.staticText,
    required this.rotatingWords,
    this.suffixText,
    this.duration = const Duration(seconds: 2),
    this.textStyle,
    this.rotatingTextStyle,
    this.suffixTextStyle,
  });

  @override
  State<AnimatedRotatingText> createState() => _AnimatedRotatingTextState();
}

class _AnimatedRotatingTextState extends State<AnimatedRotatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.rotatingWords.length;
        });
        _controller.reset();
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${widget.staticText} ',
            style: widget.textStyle ??
                GoogleFonts.spaceGrotesk(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - _fadeAnimation.value) * -8),
                    child: Text(
                      widget.rotatingWords[_currentIndex],
                      style: widget.rotatingTextStyle ??
                          GoogleFonts.spaceGrotesk(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.brandGreen,
                            height: 1.1,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.suffixText != null)
            TextSpan(
              text: ' ${widget.suffixText}',
              style: widget.suffixTextStyle ??
                  widget.textStyle ??
                  GoogleFonts.spaceGrotesk(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
            ),
        ],
      ),
    );
  }
}
