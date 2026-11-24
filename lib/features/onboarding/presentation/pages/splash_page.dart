import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // late AnimationController _controller;
  // late Animation<double> _fadeAnimation;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 2),
    // );
    // _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    // );
    //
    // _controller.forward();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Ensure we show the splash screen for at least 2.5 seconds total
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    // _controller.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset("asset/playstore.png", height: 180, width: 180),
            Spacer(),
            Text(
              "Glimora AI",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.textMain,
                shadows: [
                  Shadow(
                    color: AppTheme.accentPurple.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "AI Art & Photo Editor",
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, _) {
                    return Container(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      height: MediaQuery.sizeOf(context).height * 0.008,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white24.withOpacity(0.2),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: _animation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentLavender,
                                    AppTheme.accentSky,
                                    AppTheme.accentWarm
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
