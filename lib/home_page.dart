import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'features/ad_detail/ad_detail_page.dart';
import 'features/ads_list/ads_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  List<PropertyModel> _getByCategory(String cat) =>
      sampleProperties.where((p) => p.category == cat).take(5).toList();

  List<AgencyModel> get _featuredAgencies => sampleProperties
      .where((p) => p.agency != null)
      .map((p) => p.agency!)
      .fold<List<AgencyModel>>([], (list, agency) {
        if (list.every((a) => a.name != agency.name)) list.add(agency);
        return list;
      });

  @override
  Widget build(BuildContext context) {
    final forSale = _getByCategory('بيع');
    final forRent = _getByCategory('إيجار');
    final forBadal = _getByCategory('بدل');
    final agencies = _featuredAgencies;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _SearchBar()),
          const SliverToBoxAdapter(child: _CategoryAndBanner()),
          SliverToBoxAdapter(
            child: _HomeSection(
              title: 'أحدث عروض البيع',
              category: 'بيع',
              properties: forSale,
              onViewAll: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdsListPage(initialCategory: 0),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _HomeSection(
              title: 'أحدث عروض الإيجار',
              category: 'إيجار',
              properties: forRent,
              onViewAll: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdsListPage(initialCategory: 1),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _HomeSection(
              title: 'أحدث عروض البدل',
              category: 'بدل',
              properties: forBadal,
              onViewAll: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdsListPage(initialCategory: 2),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _FeaturedAgenciesSection(agencies: agencies),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.base,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.base,
      ),
      color: AppColors.white,
      child: Container(
        height: 50,
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
            Text(
              'ابحث عن عقارك...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Category Section — Airbnb style
// ─────────────────────────────────────────────
class _CategoryAndBanner extends StatelessWidget {
  const _CategoryAndBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tagline ──
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.titleLarge.copyWith(height: 1.5),
                children: const [
                  TextSpan(
                    text: 'العقار عالم , اكتشفه مع ',
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                  TextSpan(
                    text: 'بوعقار',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          const SizedBox(height: AppSpacing.lg),

          // ── 3 Category icons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AirbnbCategoryItem(
                imageUrl: 'https://img.icons8.com/color/96/home--v1.png',
                label: 'البيع',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdsListPage(initialCategory: 0),
                  ),
                ),
              ),
              _AirbnbCategoryItem(
                imageUrl: 'https://img.icons8.com/color/96/key.png',
                label: 'الإيجار',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdsListPage(initialCategory: 1),
                  ),
                ),
              ),
              _AirbnbCategoryItem(
                imageUrl: 'https://img.icons8.com/color/96/transaction.png',
                label: 'البدل',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdsListPage(initialCategory: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AirbnbCategoryItem extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;

  const _AirbnbCategoryItem({
    required this.imageUrl,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.ultraLightGray,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: AppColors.lightGray.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.home_outlined,
                  color: AppColors.mediumGray,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home Section — NO category badge in title
// ─────────────────────────────────────────────
class _HomeSection extends StatelessWidget {
  final String title;
  final String category;
  final List<PropertyModel> properties;
  final VoidCallback onViewAll;

  const _HomeSection({
    required this.title,
    required this.category,
    required this.properties,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title only — no category badge here
              Text(title, style: AppTextStyles.titleLarge),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'عرض الكل',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        if (properties.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Text(
              'لا توجد إعلانات حالياً',
              style: AppTextStyles.bodySmall,
            ),
          )
        else
          SizedBox(
            height: 340,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                right: AppSpacing.xl,
                left: AppSpacing.xl,
              ),
              itemCount: properties.length,
              itemBuilder: (ctx, i) => _HorizontalPropertyCard(
                property: properties[i],
                onTap: () {
                  Navigator.of(ctx).push(
                    PageRouteBuilder(
                      pageBuilder: (_, anim, __) => FadeTransition(
                        opacity: anim,
                        child: AdDetailPage(property: properties[i]),
                      ),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Horizontal Property Card
// — CategoryBadge on image (top-right)
// — Price with د.ك beside number
// — Agency icon + name below price
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
        width: 280,
        margin: const EdgeInsets.only(left: AppSpacing.xl),
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
            // ── Image with overlays ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                  child: PropertyImage(
                    url: property.images.first,
                    height: 175,
                    width: 280,
                  ),
                ),
                // Category badge — top RIGHT on image
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: CategoryBadge(label: property.category),
                ),
                // Favorite button — top LEFT on image
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: FavoriteButton(),
                ),
              ],
            ),
            // ── Card info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Location (right) + Time (left)
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
                  // Row 2: Title
                  Text(
                    property.title,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Row 3: Area + property type
                  Row(
                    children: [
                      _MiniPill(
                        Icons.straighten_outlined,
                        '${property.area} م²',
                      ),
                      const SizedBox(width: 10),
                      _MiniPill(Icons.home_outlined, property.propertyType),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Row 4: Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        property.price,
                        style: AppTextStyles.price.copyWith(fontSize: 16),
                      ),
                      if (property.priceUnit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          property.priceUnit,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ── Agency BELOW divider — full name, tight spacing ──
                  if (property.agency != null) ...[
                    const SizedBox(height: 5),
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
                        Expanded(
                          child: Text(
                            property.agency!.name, // full name, no trimming
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.darkGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ] else if (property.isPersonal) ...[
                    const SizedBox(height: 5),
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

// ─────────────────────────────────────────────
// Featured Agencies Section
// — Building / office icon instead of avatar letter
// ─────────────────────────────────────────────
class _FeaturedAgenciesSection extends StatelessWidget {
  final List<AgencyModel> agencies;

  const _FeaturedAgenciesSection({required this.agencies});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('مكاتب مميزة', style: AppTextStyles.titleLarge),
                ],
              ),
              Text(
                'عرض الكل',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: agencies.length,
            itemBuilder: (_, i) => _AgencyCard(agency: agencies[i]),
          ),
        ),
      ],
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final AgencyModel agency;

  const _AgencyCard({required this.agency});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.lightGray.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Professional real-estate office icon ──
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.business_rounded,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            agency.name
                .replaceAll('شركة ', '')
                .replaceAll(' العقارية', '')
                .replaceAll('مؤسسة ', ''),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${agency.listingsCount} إعلان',
                style: AppTextStyles.caption,
              ),
              if (agency.isLicensed) ...[
                const SizedBox(width: 3),
                const Icon(
                  Icons.verified_rounded,
                  size: 11,
                  color: AppColors.verified,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
