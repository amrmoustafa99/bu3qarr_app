import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/models.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/property_card.dart';
import '../ad_detail/ad_detail_page.dart';

class AdsListPage extends StatefulWidget {
  final int initialCategory;

  const AdsListPage({super.key, this.initialCategory = 0});

  @override
  State<AdsListPage> createState() => _AdsListPageState();
}

class _AdsListPageState extends State<AdsListPage>
    with TickerProviderStateMixin {
  late int _selectedCategory;
  final ScrollController _scrollCtrl = ScrollController();
  bool _searchVisible = true;
  double _lastScrollPos = 0;

  late AnimationController _fadeCtrl;
  final List<AnimationController> _cardCtrls = [];
  final List<Animation<double>> _cardFades = [];
  final List<Animation<Offset>> _cardSlides = [];

  final List<String> _categories = ['بيع', 'إيجار', 'بدل'];

  List<PropertyModel> get _filteredProperties {
    final cat = _categories[_selectedCategory];
    return sampleProperties.where((p) => p.category == cat).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _initCardAnimations();
    _scrollCtrl.addListener(_onScroll);

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeCtrl.forward();
      _playCardAnims();
    });
  }

  void _initCardAnimations() {
    final items = sampleProperties.length;
    for (int i = 0; i < items; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + i * 60),
      );
      _cardCtrls.add(ctrl);
      _cardFades.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut)),
      );
      _cardSlides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)),
      );
    }
  }

  void _playCardAnims() {
    for (int i = 0; i < _cardCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 70), () {
        if (mounted) _cardCtrls[i].forward();
      });
    }
  }

  void _onScroll() {
    final pos = _scrollCtrl.position.pixels;
    final dir = _scrollCtrl.position.userScrollDirection;
    if (dir == ScrollDirection.reverse && pos > _lastScrollPos + 10) {
      if (_searchVisible) setState(() => _searchVisible = false);
    } else if (dir == ScrollDirection.forward) {
      if (!_searchVisible) setState(() => _searchVisible = true);
    }
    _lastScrollPos = pos;
  }

  void _onCategoryChanged(int index) {
    setState(() => _selectedCategory = index);
    for (final c in _cardCtrls) {
      c.reset();
    }
    _playCardAnims();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Property list ──
          CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Space for search header
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
              // Category tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryHeaderDelegate(
                  categories: _categories,
                  selectedIndex: _selectedCategory,
                  onChanged: _onCategoryChanged,
                ),
              ),
              // Cards
              SliverPadding(
                padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final props = _filteredProperties;
                    if (i >= props.length) return null;
                    final p = props[i];
                    final animIdx = sampleProperties.indexOf(p);
                    final fade = animIdx < _cardFades.length
                        ? _cardFades[animIdx]
                        : const AlwaysStoppedAnimation(1.0);
                    final slide = animIdx < _cardSlides.length
                        ? _cardSlides[animIdx]
                        : const AlwaysStoppedAnimation(Offset.zero);

                    return FadeTransition(
                      opacity: fade,
                      child: SlideTransition(
                        position: slide,
                        child: PropertyCard(
                          property: p,
                          index: i,
                          onTap: () => _navigateToDetail(ctx, p),
                        ),
                      ),
                    );
                  }, childCount: _filteredProperties.length),
                ),
              ),
            ],
          ),

          // ── Floating search + back ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _searchVisible ? 0 : -90,
            left: 0,
            right: 0,
            child: _SearchHeader(
              selectedCategory: _categories[_selectedCategory],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext ctx, PropertyModel property) {
    Navigator.of(ctx).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: AdDetailPage(property: property),
        ),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Floating Search Header with back button
// ─────────────────────────────────────────────
class _SearchHeader extends StatelessWidget {
  final String selectedCategory;

  const _SearchHeader({required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        left: AppSpacing.base,
        right: AppSpacing.xl,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ultraLightGray,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Search bar
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.ultraLightGray,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.lightGray.withOpacity(0.6),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.base),
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.mediumGray,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'ابحث في $selectedCategory...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Filter button
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Category header delegate (pinned)
// ─────────────────────────────────────────────
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _CategoryHeaderDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  bool shouldRebuild(_CategoryHeaderDelegate old) =>
      old.selectedIndex != selectedIndex;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 52,
      color: AppColors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) => _CategoryTab(
          label: categories[i],
          isSelected: i == selectedIndex,
          onTap: () => onChanged(i),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.lightGray,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? AppColors.white : AppColors.darkGray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
