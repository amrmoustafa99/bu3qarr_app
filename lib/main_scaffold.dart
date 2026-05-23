import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';
import 'features/ads_list/ads_list_page.dart';
import 'home_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    _PlaceholderPage(label: 'المفضلة'),
    SizedBox.shrink(),
    _PlaceholderPage(label: 'حسابي'),
  ];

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AdsListPage()));
      return;
    }
    if (index == 2) {
      _showAddBottomSheet();
      return;
    }
    setState(() => _navIndex = index == 3 ? 1 : (index == 4 ? 2 : index));
  }

  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _AddBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Pages ──
          IndexedStack(index: _navIndex, children: _pages),
          // ── Floating Bottom Nav ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _FloatingBottomNav(
              currentIndex: _navIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Floating Bottom Nav — Pill style
// ─────────────────────────────────────────────
class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: bottomPadding + AppSpacing.base,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _FloatingNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _FloatingNavItem(
              icon: Icons.tv_outlined,
              activeIcon: Icons.tv_rounded,
              isActive: false,
              onTap: () => onTap(1),
            ),
            _FloatingNavItem(
              icon: Icons.apartment_outlined,
              activeIcon: Icons.apartment_rounded,
              isActive: false,
              onTap: () => onTap(2),
            ),
            _FloatingNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              isActive: currentIndex == 2,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryLight : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              size: 26,
              color: isActive ? AppColors.primary : AppColors.mediumGray,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add Ad Bottom Sheet — Floating Pill
// ─────────────────────────────────────────────
class _AddBottomSheet extends StatefulWidget {
  const _AddBottomSheet();

  @override
  State<_AddBottomSheet> createState() => _AddBottomSheetState();
}

class _AddBottomSheetState extends State<_AddBottomSheet> {
  int _selected = 0;

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.tv_outlined,
    Icons.apartment_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_icons.length, (i) {
                final isActive = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryLight
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icons[i],
                      size: 26,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.mediumGray,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Placeholder page
// ─────────────────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final String label;

  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.mediumGray,
          ),
        ),
      ),
    );
  }
}
