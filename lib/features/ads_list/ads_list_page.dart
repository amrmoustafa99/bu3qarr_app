import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
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
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  late AnimationController _fadeCtrl;
  final List<AnimationController> _cardCtrls = [];
  final List<Animation<double>> _cardFades = [];
  final List<Animation<Offset>> _cardSlides = [];

  final List<String> _categories = ['بيع', 'إيجار', 'بدل'];

  List<PropertyModel> get _filteredProperties {
    final cat = _categories[_selectedCategory];
    var list = sampleProperties.where((p) => p.category == cat).toList();
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.title.contains(_searchQuery) ||
                p.location.contains(_searchQuery),
          )
          .toList();
    }
    return list;
  }

  String get _maxPrice {
    final props = _filteredProperties;
    if (props.isEmpty) return '—';
    final prices = props
        .map((p) => int.tryParse(p.price.replaceAll(',', '')) ?? 0)
        .where((v) => v > 0)
        .toList();
    if (prices.isEmpty) return '—';
    prices.sort();
    final max = prices.last;
    return max >= 1000000
        ? '${(max / 1000000).toStringAsFixed(1)}م'
        : max >= 1000
        ? '${(max / 1000).toStringAsFixed(0)}ألف'
        : max.toString();
  }

  String get _minPrice {
    final props = _filteredProperties;
    if (props.isEmpty) return '—';
    final prices = props
        .map((p) => int.tryParse(p.price.replaceAll(',', '')) ?? 0)
        .where((v) => v > 0)
        .toList();
    if (prices.isEmpty) return '—';
    prices.sort();
    return prices.first >= 1000
        ? '${(prices.first / 1000).toStringAsFixed(0)}ألف'
        : prices.first.toString();
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
    _searchCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ── Top Bar: back button only ──
          _BackBar(onBack: () => Navigator.of(context).maybePop()),

          // ── Search + Stats header ──
          _StatsHeader(
            searchCtrl: _searchCtrl,
            count: _filteredProperties.length,
            onSearch: (v) => setState(() => _searchQuery = v),
          ),

          // ── Property list ──
          Expanded(
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: 24,
                  ),
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
                          child: _HorizontalPropertyCard(
                            property: p,
                            onTap: () => _navigateToDetail(ctx, p),
                          ),
                        ),
                      );
                    }, childCount: _filteredProperties.length),
                  ),
                ),
              ],
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
// Back Bar: back button only
// ─────────────────────────────────────────────
class _BackBar extends StatelessWidget {
  final VoidCallback onBack;

  const _BackBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        bottom: AppSpacing.sm,
        right: AppSpacing.base,
        left: AppSpacing.base,
      ),
      child: Row(
        children: [
          // ── Back button (left) ──
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ultraLightGray,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.black,
              ),
            ),
          ),

          // ── Title (center) ──
          Expanded(
            child: Text(
              'عقارات الكويت',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
          ),

          // ── Filter button (right) ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.ultraLightGray,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 18,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stats Header: search + count + price stats
// ─────────────────────────────────────────────
class _StatsHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  final int count;
  final ValueChanged<String> onSearch;

  const _StatsHeader({
    required this.searchCtrl,
    required this.count,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──
          Container(
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
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: onSearch,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'ابحث حسب المنطقة...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mediumGray,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.base),

          // ── Count ──
          Text(
            'عدد الإعلانات المعروضة $count',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Price stats ──
          Row(
            children: [
              Expanded(
                child: _PriceStatCard(
                  label: 'أغلى سعر',
                  value: '6,000,000',
                  isHigh: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PriceStatCard(
                  label: 'أرخص سعر',
                  value: '38,000',
                  isHigh: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          Divider(
            height: 1,
            thickness: 0.8,
            color: AppColors.lightGray.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

class _PriceStatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isHigh;

  const _PriceStatCard({
    required this.label,
    required this.value,
    required this.isHigh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.ultraLightGray,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.lightGray.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Arrow icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isHigh ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                ),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Horizontal Property Card — full width
// ─────────────────────────────────────────────
class _HorizontalPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;

  const _HorizontalPropertyCard({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                  child: PropertyImage(
                    url: property.images.first,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: CategoryBadge(label: property.category),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: FavoriteButton(),
                ),
              ],
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(width: 2),
                          Text(property.location, style: AppTextStyles.caption),
                        ],
                      ),
                      Text(property.timeAgo, style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    property.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniPill(
                        Icons.straighten_outlined,
                        '${property.area} م²',
                      ),
                      const SizedBox(width: 10),
                      _MiniPill(Icons.home_outlined, property.propertyType),
                      if (property.floors != null) ...[
                        const SizedBox(width: 10),
                        _MiniPill(Icons.layers_outlined, property.floors!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(property.price, style: AppTextStyles.price),
                          if (property.priceUnit.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              property.priceUnit,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (property.agency != null)
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.apps_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Text(
                                property.agency!.name,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.darkGray,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else if (property.isPersonal)
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.mediumGray,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text('إعلان شخصي', style: AppTextStyles.caption),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniPill(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.mediumGray),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.darkGray),
        ),
      ],
    );
  }
}
