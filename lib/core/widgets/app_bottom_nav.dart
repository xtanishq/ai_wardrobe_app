import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      backgroundColor: Colors.transparent,
      color: AppTheme.surfacePrimary,
      buttonBackgroundColor: AppTheme.accentPurple,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 400),
      onTap: onTap,
      letIndexChange: (index) => true,
      items: [
        Icon(
          currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
          size: 30,
          color: currentIndex == 0 ? Colors.white : AppTheme.textMuted,
        ),
        Icon(
          currentIndex == 1 ? Icons.grid_view_rounded : Icons.grid_view_outlined,
          size: 30,
          color: currentIndex == 1 ? Colors.white : AppTheme.textMuted,
        ),
      ],
    );
  }
}
