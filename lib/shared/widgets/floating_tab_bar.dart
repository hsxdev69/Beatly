import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/dimensions.dart';
import 'glass_container.dart';

class FloatingTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 16.0),
      child: GlassContainer(
        height: AppDimensions.bottomNavHeight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        color: AppColors.darkSurface.withValues(alpha: 0.85),
        blur: 24.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _buildTabItem(1, Icons.search_rounded, Icons.search_outlined, 'Search'),
            _buildTabItem(2, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
            _buildTabItem(3, Icons.library_music_rounded, Icons.library_music_outlined, 'Library'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16.0 : 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
