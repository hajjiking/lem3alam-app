import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'splash_animation.dart';
import 'splash_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _shimmerController;
  late final SplashAnimationValues _animation;
  late final Animation<double> _waveSlide;
  late final Animation<double> _progressBar;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = SplashAnimationValues(parent: _controller);

    _waveSlide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _progressBar = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashState = ref.watch(splashControllerProvider);
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final isLandscape = size.width > size.height;
    final shortest = size.shortestSide;

    final logoHeight = (shortest * 0.38).clamp(100.0, 220.0);
    final appNameHeight = (shortest * 0.12).clamp(36.0, 72.0);
    final taglineFontSize = (shortest * 0.035).clamp(12.0, 16.0);
    final waveHeight = isLandscape ? size.height * 0.35 : size.height * 0.25;
    final waveSlideMultiplier = isLandscape ? 0.45 : 0.38;
    final taglineBottom = isLandscape ? size.height * 0.25 : size.height * 0.19;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _shimmerController]),
        builder: (context, child) {
          return SplashBackground(
            patternOpacity: _animation.backgroundFade.value,
            glowProgress: _animation.backgroundGlow.value,
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 48 : 24,
                    ),
                    child: isLandscape
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildLogo(logoHeight),
                              SizedBox(width: shortest * 0.04),
                              _buildAppName(appNameHeight),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLogo(logoHeight),
                              const SizedBox(height: 18),
                              _buildAppName(appNameHeight),
                            ],
                          ),
                  ),
                ),

                // Tagline with slide + fade
                Positioned(
                  bottom: taglineBottom,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: _animation.taglineSlide,
                    child: Opacity(
                      opacity: _animation.taglineOpacity.value,
                      child: _Tagline(fontSize: taglineFontSize),
                    ),
                  ),
                ),

                // Wave footer
                Transform.translate(
                  offset: Offset(
                    0,
                    size.height * waveSlideMultiplier * _waveSlide.value,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipPath(
                      clipper: _WaveClipper(),
                      child: _WaveBody(
                        height: waveHeight,
                        bottomPadding: math.max(mq.padding.bottom, 20),
                        loadingOpacity: _animation.loadingOpacity.value,
                        statusText: splashState.isReady
                            ? 'جاري فتح التطبيق...'
                            : 'جاري التحميل...',
                        statusFontSize:
                            (shortest * 0.032).clamp(12.0, 14.0),
                        progressWidth:
                            (size.width * 0.62).clamp(160.0, 320.0),
                        progressFactor: _progressBar.value,
                        shimmerValue: _shimmerController.value,
                        gapHeight:
                            (shortest * 0.028).clamp(8.0, 14.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(double height) {
    return SlideTransition(
      position: _animation.logoSlide,
      child: Transform.rotate(
        angle: _animation.logoRotation.value,
        child: Transform.scale(
          scale: _animation.logoScale.value * _animation.logoPulse.value,
          child: Opacity(
            opacity: _animation.logoOpacity.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0)
                        .withValues(alpha: _animation.glowPulse.value),
                    blurRadius: 30 * _animation.backgroundGlow.value,
                    spreadRadius: 10 * _animation.backgroundGlow.value,
                  ),
                  BoxShadow(
                    color: const Color(0xFF42A5F5)
                        .withValues(alpha: _animation.glowPulse.value * 0.5),
                    blurRadius: 50 * _animation.backgroundGlow.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/logo_character.png',
                height: height,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppName(double height) {
    return Transform.scale(
      scale: _animation.textScale.value,
      child: Opacity(
        opacity: _animation.textOpacity.value,
        child: Image.asset(
          'assets/app_name.png',
          height: height,
        ),
      ),
    );
  }
}

class _WaveBody extends StatelessWidget {
  const _WaveBody({
    required this.height,
    required this.bottomPadding,
    required this.loadingOpacity,
    required this.statusText,
    required this.statusFontSize,
    required this.progressWidth,
    required this.progressFactor,
    required this.shimmerValue,
    required this.gapHeight,
  });

  final double height;
  final double bottomPadding;
  final double loadingOpacity;
  final String statusText;
  final double statusFontSize;
  final double progressWidth;
  final double progressFactor;
  final double shimmerValue;
  final double gapHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, height * 0.15, 24, bottomPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: loadingOpacity,
            child: Text(
              statusText,
              style: TextStyle(
                color: Colors.white,
                fontSize: statusFontSize,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: gapHeight),
          SizedBox(
            width: progressWidth,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  // Track
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  // Fill with shimmer
                  FractionallySizedBox(
                    widthFactor: progressFactor,
                    alignment: Alignment.centerLeft,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        final shimmerOffset =
                            (shimmerValue * 3 - 1) * bounds.width;
                        return LinearGradient(
                          colors: const [
                            Colors.white,
                            Color(0xFFB3E5FC),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          transform: _SlidingGradientTransform(shimmerOffset),
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.offset);

  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(offset, 0, 0);
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: const LinearGradient(
              colors: [Color(0x001565C0), Color(0xFF1565C0)],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'خدمة موثوقة، بين يديك',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1565C0),
            fontFamily: 'Cairo',
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0x001565C0)],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, 40);

    final firstControlPoint = Offset(size.width / 4, 0);
    final firstEndPoint = Offset(size.width / 2, 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 3 / 4, 40);
    final secondEndPoint = Offset(size.width, 10);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
