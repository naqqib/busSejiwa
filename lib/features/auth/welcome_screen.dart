import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

/// Choreographed splash-to-welcome screen for BusSejiwa.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Phase 1: Logo drives in from the left & fades in
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoDriveIn;

  // Phase 2: Diagonal glossy shine sweeps across the logo
  late final Animation<double> _logoSheen;

  // Phase 3: Logo zooms out & lifts up; background & title appear
  late final Animation<double> _logoZoom;
  late final Animation<Offset> _brandLift;
  late final Animation<double> _bgFade;

  // Phase 4: Welcome headline, subtitle & pill buttons glide up
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // Phase 1: Logo fades in and slides in from the left like a bus arriving
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
    );

    _logoDriveIn =
        Tween<Offset>(begin: const Offset(-0.45, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.24, curve: Curves.easeOutCubic),
          ),
        );

    // Phase 2: Shiny light beam sweeps left (-1.5) -> right (1.5) across logo
    _logoSheen = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.46, curve: Curves.easeInOut),
      ),
    );

    // Phase 3: Zoom out (1.55 -> 1.0) and lift from center to upper area
    _logoZoom = Tween<double>(begin: 1.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.78, curve: Curves.easeInOutCubic),
      ),
    );

    _brandLift = Tween<Offset>(begin: const Offset(0, 0.85), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.48, 0.78, curve: Curves.easeInOutCubic),
          ),
        );

    _bgFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.78, curve: Curves.easeInOut),
    );

    // Phase 4: Welcome text & buttons glide up
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.72, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7F1),
      body: Stack(
        children: [
          // Emerald Safety gradient background (fades in during Phase 3)
          FadeTransition(
            opacity: _bgFade,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE6F7F1),
                    Color(0xFF1F6E5C),
                    Color(0xFF0B2E26),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Brand block: Logo first (drive-in + shine + zoom out), then title
                  SlideTransition(
                    position: _brandLift,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SlideTransition(
                          position: _logoDriveIn,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoZoom,
                              child: SizedBox(
                                width: 132,
                                height: 132,
                                child: AnimatedBuilder(
                                  animation: _logoSheen,
                                  builder: (context, child) {
                                    return ShaderMask(
                                      // srcATop paints the shine ONLY on top of the non-transparent logo pixels
                                      blendMode: BlendMode.srcATop,
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            begin: Alignment(
                                              _logoSheen.value - 0.6,
                                              -0.5,
                                            ),
                                            end: Alignment(
                                              _logoSheen.value + 0.6,
                                              0.5,
                                            ),
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withValues(
                                                alpha: 0.70,
                                              ),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.25, 0.5, 0.75],
                                          ).createShader(
                                            Rect.fromLTWH(
                                              0,
                                              0,
                                              bounds.width,
                                              bounds.height,
                                            ),
                                          ),
                                      child: child,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/logo_full.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Welcome headline, subtitle & pill buttons (Phase 4)
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'SAFER BUS\nJOURNEYS START HERE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Real-time speed alerts, transparent safety ratings, and instant plate lookup for Malaysian passengers.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0B2E26),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Create an Account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.10,
                              ),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'I Already Have an Account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
