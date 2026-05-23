import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/models.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final VoidCallback? onTap;
  final int index;

  const PropertyCard({
    super.key,
    required this.property,
    required this.index,
    this.onTap,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image slider ──
              _ImageSlider(
                images: p.images,
                propertyId: p.id,
                pageCtrl: _pageCtrl,
                currentPage: _currentPage,
                onPageChanged: (i) => setState(() => _currentPage = i),
                category: p.category,
              ),
              // ── Card info ──
              _CardInfo(property: p),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Image Slider
// ─────────────────────────────────────────────
class _ImageSlider extends StatelessWidget {
  final List<String> images;
  final String propertyId;
  final PageController pageCtrl;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final String category;

  const _ImageSlider({
    required this.images,
    required this.propertyId,
    required this.pageCtrl,
    required this.currentPage,
    required this.onPageChanged,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Images
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xxl),
            topRight: Radius.circular(AppRadius.xxl),
          ),
          child: SizedBox(
            height: 240,
            child: Hero(
              tag: 'property_image_$propertyId',
              child: PageView.builder(
                controller: pageCtrl,
                onPageChanged: onPageChanged,
                itemCount: images.length,
                itemBuilder: (_, i) => PropertyImage(
                  url: images[i],
                  height: 240,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
        // Top row: category badge + favorite
        Positioned(
          top: AppSpacing.base,
          right: AppSpacing.base,
          left: AppSpacing.base,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryBadge(label: category),
              FavoriteButton(),
            ],
          ),
        ),
        // Page indicator
        if (images.length > 1)
          Positioned(
            bottom: AppSpacing.md,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageCtrl,
                count: images.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.white,
                  dotColor: AppColors.white.withOpacity(0.5),
                  dotHeight: 5,
                  dotWidth: 5,
                  expansionFactor: 2.5,
                  spacing: 4,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Card Info Section
// ─────────────────────────────────────────────
class _CardInfo extends StatelessWidget {
  final PropertyModel property;

  const _CardInfo({required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.base,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            property.title,
            style: AppTextStyles.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          // Location + time
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppColors.mediumGray,
              ),
              const SizedBox(width: 2),
              Text(property.location, style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Text('·', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Text(property.timeAgo, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Specs row
          Row(
            children: [
              _SpecPill(
                icon: Icons.straighten_outlined,
                value: '${property.area} م²',
              ),
              const SizedBox(width: AppSpacing.sm),
              _SpecPill(
                icon: Icons.home_outlined,
                value: property.propertyType,
              ),
              if (property.floors != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _SpecPill(
                  icon: Icons.layers_outlined,
                  value: property.floors!,
                  small: true,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Divider
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFF0F0F0),
          ),
          const SizedBox(height: AppSpacing.md),
          // Price + agency
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (property.priceUnit.isNotEmpty)
                      Text(
                        property.priceUnit,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mediumGray,
                          height: 1.2,
                        ),
                      ),
                    Text(property.price, style: AppTextStyles.price),
                  ],
                ),
              ),
              // Agency/personal indicator
              if (property.agency != null)
                _AgencyMini(agency: property.agency!)
              else if (property.isPersonal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ultraLightGray,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: AppColors.mediumGray,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'إعلان شخصي',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool small;

  const _SpecPill({
    required this.icon,
    required this.value,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.mediumGray),
        const SizedBox(width: 3),
        Text(
          value,
          style: small
              ? AppTextStyles.caption
              : AppTextStyles.bodySmall.copyWith(color: AppColors.darkGray),
          maxLines: 1,
        ),
      ],
    );
  }
}

class _AgencyMini extends StatelessWidget {
  final AgencyModel agency;

  const _AgencyMini({required this.agency});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: PropertyImage(
            url: agency.logoUrl,
            width: 26,
            height: 26,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            agency.name.replaceAll('شركة ', '').replaceAll(' العقارية', ''),
            style: AppTextStyles.caption.copyWith(color: AppColors.darkGray),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Small horizontal card for similar properties
// ─────────────────────────────────────────────
class SimilarPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  const SimilarPropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
              child: PropertyImage(
                url: property.images.first,
                height: 130,
                width: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    property.location,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        property.price,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        property.priceUnit,
                        style: AppTextStyles.caption,
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
