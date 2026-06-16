import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flyAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _scaleAnimation;
  
  final List<Animation<double>> _dotAnimations = [];
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );
    
    _flyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _rotateAnimation = Tween<double>(begin: 360, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _textSlideAnimation = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    
    for (int i = 0; i < 3; i++) {
      _dotAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.8 + (i * 0.07), 1.0, curve: Curves.elasticOut),
          ),
        ),
      );
    }
    
    _animationController.forward();
    
    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Offset _getLogoPosition(double progress, Size screenSize) {
    if (progress >= 1.0) return Offset.zero;
    
    final startX = screenSize.width / 2 + 150;
    final startY = -100;
    final endX = 0.0;
    final endY = 0.0;
    
    final eased = Curves.easeOutBack.transform(progress);
    
    return Offset(
      startX * (1 - eased) + endX * eased,
      startY * (1 - eased) + endY * eased,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE4F1FF),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final flyProgress = _flyAnimation.value;
          final logoPosition = _getLogoPosition(flyProgress, screenSize);
          final rotation = _rotateAnimation.value;
          
          return Stack(
            children: [
              // Background with subtle gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE4F1FF),
                      const Color(0xFFE4F1FF).withOpacity(0.95),
                      const Color(0xFFAED2FF).withOpacity(0.3),
                      const Color(0xFF9400FF).withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              
              // Decorative circles for depth
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9400FF).withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFAED2FF).withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                top: 150,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF27005D).withOpacity(0.05),
                  ),
                ),
              ),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (flyProgress < 0.99)
                      Transform.translate(
                        offset: logoPosition,
                        child: Transform.rotate(
                          angle: rotation * 3.14159 / 180,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: const DevSyncFlyingLogo(),
                          ),
                        ),
                      )
                    else
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: const DevSyncFlyingLogo(),
                      ),
                    
                    const SizedBox(height: 30),
                    
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF27005D), Color(0xFF9400FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                'devsync',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Code together, in real time.',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF9400FF).withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _dotAnimations[index],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, -15 * _dotAnimations[index].value),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: [
                                      const Color(0xFF9400FF),
                                      const Color(0xFFAED2FF),
                                      const Color(0xFF27005D),
                                    ][index],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: [
                                          const Color(0xFF9400FF),
                                          const Color(0xFFAED2FF),
                                          const Color(0xFF27005D),
                                        ][index].withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DevSyncFlyingLogo extends StatefulWidget {
  const DevSyncFlyingLogo({super.key});

  @override
  State<DevSyncFlyingLogo> createState() => _DevSyncFlyingLogoState();
}

class _DevSyncFlyingLogoState extends State<DevSyncFlyingLogo> with SingleTickerProviderStateMixin {
  late AnimationController _drawController;
  late Animation<double> _bracketLeftAnimation;
  late Animation<double> _bracketRightAnimation;
  late Animation<double> _slashOneAnimation;
  late Animation<double> _slashTwoAnimation;
  late Animation<double> _dotAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _drawController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _bracketLeftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    
    _bracketRightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawController, curve: const Interval(0.15, 0.45, curve: Curves.easeOut)),
    );
    
    _slashOneAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawController, curve: const Interval(0.3, 0.6, curve: Curves.easeOut)),
    );
    
    _slashTwoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawController, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)),
    );
    
    _dotAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawController, curve: const Interval(0.65, 1.0, curve: Curves.elasticOut)),
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawController, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)),
    );
    
    _drawController.forward();
  }
  
  @override
  void dispose() {
    _drawController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _drawController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9400FF).withOpacity(0.25 * _glowAnimation.value),
                blurRadius: 30 * _glowAnimation.value,
                spreadRadius: 10 * _glowAnimation.value,
              ),
            ],
          ),
          child: SizedBox(
            width: 130,
            height: 130,
            child: CustomPaint(
              painter: DevSyncFlyingLogoPainter(
                bracketLeftProgress: _bracketLeftAnimation.value,
                bracketRightProgress: _bracketRightAnimation.value,
                slashOneProgress: _slashOneAnimation.value,
                slashTwoProgress: _slashTwoAnimation.value,
                dotScale: _dotAnimation.value,
                glowIntensity: _glowAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DevSyncFlyingLogoPainter extends CustomPainter {
  final double bracketLeftProgress;
  final double bracketRightProgress;
  final double slashOneProgress;
  final double slashTwoProgress;
  final double dotScale;
  final double glowIntensity;
  
  DevSyncFlyingLogoPainter({
    required this.bracketLeftProgress,
    required this.bracketRightProgress,
    required this.slashOneProgress,
    required this.slashTwoProgress,
    required this.dotScale,
    required this.glowIntensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw glowing background circle
    final glowPaint = Paint()
      ..color = const Color(0xFF9400FF).withOpacity(0.10 * glowIntensity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 60 * glowIntensity, glowPaint);
    
    // Draw outer ring
    final ringPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
        colors: [Color(0xFF9400FF), Color(0xFFAED2FF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    if (glowIntensity > 0.5) {
      canvas.drawCircle(center, 55, ringPaint);
    }
    
    // Draw left bracket <
    if (bracketLeftProgress > 0) {
      final gradientPaint = Paint()
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..shader = const LinearGradient(
          colors: [Color(0xFF27005D), Color(0xFF9400FF)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      _drawPartialLine(canvas, const Offset(35, 48), const Offset(25, 63), gradientPaint, bracketLeftProgress);
      _drawPartialLine(canvas, const Offset(25, 63), const Offset(35, 78), gradientPaint, bracketLeftProgress);
    }
    
    // Draw right bracket >
    if (bracketRightProgress > 0) {
      final gradientPaint = Paint()
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..shader = const LinearGradient(
          colors: [Color(0xFF27005D), Color(0xFF9400FF)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      _drawPartialLine(canvas, const Offset(85, 48), const Offset(95, 63), gradientPaint, bracketRightProgress);
      _drawPartialLine(canvas, const Offset(95, 63), const Offset(85, 78), gradientPaint, bracketRightProgress);
    }
    
    // Draw slash one /
    if (slashOneProgress > 0) {
      final slashPaint = Paint()
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFAED2FF)
        ..style = PaintingStyle.stroke;
      
      _drawPartialLine(canvas, const Offset(48, 43), const Offset(58, 81), slashPaint, slashOneProgress);
    }
    
    // Draw slash two \
    if (slashTwoProgress > 0) {
      final slashPaint = Paint()
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE4F1FF)
        ..style = PaintingStyle.stroke;
      
      _drawPartialLine(canvas, const Offset(71, 81), const Offset(81, 43), slashPaint, slashTwoProgress);
    }
    
    // Draw center dot
    if (dotScale > 0) {
      final dotPaint = Paint()
        ..color = const Color(0xFF27005D)
        ..style = PaintingStyle.fill;
      
      final dotRadius = 6 * dotScale;
      canvas.drawCircle(center, dotRadius, dotPaint);
      
      final glowDotPaint = Paint()
        ..color = const Color(0xFF9400FF).withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, dotRadius + 4, glowDotPaint);
    }
  }
  
  void _drawPartialLine(Canvas canvas, Offset start, Offset end, Paint paint, double progress) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final partialEnd = Offset(start.dx + dx * progress, start.dy + dy * progress);
    canvas.drawLine(start, partialEnd, paint);
  }
  
  @override
  bool shouldRepaint(covariant DevSyncFlyingLogoPainter oldDelegate) {
    return oldDelegate.bracketLeftProgress != bracketLeftProgress ||
           oldDelegate.bracketRightProgress != bracketRightProgress ||
           oldDelegate.slashOneProgress != slashOneProgress ||
           oldDelegate.slashTwoProgress != slashTwoProgress ||
           oldDelegate.dotScale != dotScale ||
           oldDelegate.glowIntensity != glowIntensity;
  }
}