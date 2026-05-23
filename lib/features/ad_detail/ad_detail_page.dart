import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/models.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/property_card.dart';
import '../../shared/widgets/shared_widgets.dart';

class AdDetailPage extends StatefulWidget {
  final PropertyModel property;

  const AdDetailPage({super.key, required this.property});

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentImage = 0;
  bool _descExpanded = false;

  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
        );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  List<PropertyModel> get _similar => sampleProperties
      .where(
        (p) =>
            p.id != widget.property.id &&
            p.category == widget.property.category,
      )
      .take(6)
      .toList();

  @override
  Widget build(BuildContext context) {
    final p = widget.property;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Main content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── Sliver image header ──
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.black,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: const SizedBox.shrink(),
                flexibleSpace: _ImageHeader(
                  property: p,
                  pageCtrl: _pageCtrl,
                  currentImage: _currentImage,
                  onPageChanged: (i) => setState(() => _currentImage = i),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: _ContentBody(
                      property: p,
                      descExpanded: _descExpanded,
                      onToggleDesc: () =>
                          setState(() => _descExpanded = !_descExpanded),
                      similar: _similar,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ── Floating back + share buttons ──
          _FloatingTopBar(),
          // ── Sticky bottom action bar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActionBar(property: p),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Image Header (SliverAppBar flexible space)
// ─────────────────────────────────────────────
class _ImageHeader extends StatelessWidget {
  final PropertyModel property;
  final PageController pageCtrl;
  final int currentImage;
  final ValueChanged<int> onPageChanged;

  const _ImageHeader({
    required this.property,
    required this.pageCtrl,
    required this.currentImage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      background: Stack(
        fit: StackFit.expand,
        children: [
          // Images
          Hero(
            tag: 'property_image_${property.id}',
            child: PageView.builder(
              controller: pageCtrl,
              onPageChanged: onPageChanged,
              itemCount: property.images.length,
              itemBuilder: (_, i) => PropertyImage(
                url: property.images[i],
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Page indicator
          if (property.images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: pageCtrl,
                  count: property.images.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.white,
                    dotColor: AppColors.white.withOpacity(0.45),
                    dotHeight: 6,
                    dotWidth: 6,
                    expansionFactor: 2.5,
                    spacing: 5,
                  ),
                ),
              ),
            ),
          // Image counter
          Positioned(
            bottom: 14,
            right: AppSpacing.xl,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${currentImage + 1}/${property.images.length}',
                style: AppTextStyles.caption.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Floating top bar (back + share)
// ─────────────────────────────────────────────
class _FloatingTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.sm,
      left: AppSpacing.base,
      right: AppSpacing.base,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          _GlassButton(icon: Icons.ios_share_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: AppColors.black),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Content body
// ─────────────────────────────────────────────
class _ContentBody extends StatelessWidget {
  final PropertyModel property;
  final bool descExpanded;
  final VoidCallback onToggleDesc;
  final List<PropertyModel> similar;

  const _ContentBody({
    required this.property,
    required this.descExpanded,
    required this.onToggleDesc,
    required this.similar,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ──
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacing.md),
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Main info ──
            _MainInfo(property: property),

            const SizedBox(height: AppSpacing.xl),
            const SubtleDivider(),

            const SizedBox(height: AppSpacing.xl),

            // ── Spec chips ──
            _SpecChips(property: property),

            const SizedBox(height: AppSpacing.xl),
            const SubtleDivider(),

            // ── Description ──
            if (property.description != null) ...[
              const SizedBox(height: AppSpacing.xl),

              _DescriptionSection(
                description: property.description!,
                expanded: descExpanded,
                onToggle: onToggleDesc,
              ),

              const SizedBox(height: AppSpacing.xl),
              const SubtleDivider(),
            ],

            // ── Ad code only ──
            if (property.adCode != null) ...[
              const SizedBox(height: AppSpacing.xl),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: DetailRow(
                  label: 'رمز الإعلان',
                  value: property.adCode!,
                  icon: Icons.tag_outlined,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              const SubtleDivider(),
            ],

            // ── Agency section ──
            if (property.agency != null) ...[
              const SizedBox(height: AppSpacing.xl),

              _AgencySection(agency: property.agency!),

              const SizedBox(height: AppSpacing.xl),
              const SubtleDivider(),
            ],

            // ── Similar properties ──
            if (similar.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),

              _SimilarSection(similar: similar),

              const SizedBox(height: AppSpacing.xl),
            ],

            // Space for bottom bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Main info: title, price, location, time
// ─────────────────────────────────────────────
class _MainInfo extends StatelessWidget {
  final PropertyModel property;

  const _MainInfo({required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          const SizedBox(height: AppSpacing.xl),
          // Location (right) + time (left) in same row
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.mediumGray,
              ),
              const SizedBox(width: 3),
              Text(property.location, style: AppTextStyles.bodyMedium),
              const Spacer(),
              Text(property.timeAgo, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Title below
          Text(property.title, style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.lg),
          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(property.price, style: AppTextStyles.priceLarge),
              if (property.priceUnit.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    property.priceUnit,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Spec chips row
// ─────────────────────────────────────────────
class _SpecChips extends StatelessWidget {
  final PropertyModel property;

  const _SpecChips({required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          SpecChip(
            icon: Icons.straighten_outlined,
            label: '${property.area} م²',
          ),
          SpecChip(icon: Icons.home_outlined, label: property.propertyType),
          SpecChip(icon: Icons.sell_outlined, label: property.category),
          if (property.details != null)
            SpecChip(icon: Icons.info_outline, label: property.details!),
          if (property.floors != null)
            SpecChip(icon: Icons.layers_outlined, label: property.floors!),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Description section
// ─────────────────────────────────────────────
class _DescriptionSection extends StatelessWidget {
  final String description;
  final bool expanded;
  final VoidCallback onToggle;

  const _DescriptionSection({
    required this.description,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الوصف', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Text(
              description,
              style: AppTextStyles.bodyLarge,
              maxLines: expanded ? null : 3,
              overflow: expanded ? null : TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expanded ? 'عرض أقل' : 'قراءة المزيد',
                  style: AppTextStyles.label.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.black,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Property details section
// ─────────────────────────────────────────────
class _DetailsSection extends StatelessWidget {
  final PropertyModel property;

  const _DetailsSection({required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تفاصيل العقار', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          DetailRow(
            label: 'نوع العقار',
            value: property.propertyType,
            icon: Icons.home_outlined,
          ),
          const SubtleDivider(indent: 0),
          DetailRow(
            label: 'المساحة',
            value: '${property.area} م²',
            icon: Icons.straighten_outlined,
          ),
          const SubtleDivider(indent: 0),
          DetailRow(
            label: 'التصنيف',
            value: property.category,
            icon: Icons.category_outlined,
          ),
          if (property.details != null) ...[
            const SubtleDivider(indent: 0),
            DetailRow(
              label: 'تفاصيل إضافية',
              value: property.details!,
              icon: Icons.info_outline,
            ),
          ],
          if (property.adCode != null) ...[
            const SubtleDivider(indent: 0),
            DetailRow(
              label: 'رمز الإعلان',
              value: property.adCode!,
              icon: Icons.tag_outlined,
            ),
          ],
          if (property.isPersonal) ...[
            const SubtleDivider(indent: 0),
            DetailRow(
              label: 'نوع المُعلِن',
              value: 'إعلان شخصي',
              icon: Icons.person_outline,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Agency section
// ─────────────────────────────────────────────
class _AgencySection extends StatelessWidget {
  final AgencyModel agency;

  const _AgencySection({required this.agency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المكتب العقاري', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.base),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
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
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: PropertyImage(
                    url: agency.logoUrl,
                    width: 56,
                    height: 56,
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              agency.name,
                              style: AppTextStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (agency.isLicensed) ...[
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: AppColors.verified,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '${agency.listingsCount} إعلان',
                            style: AppTextStyles.bodySmall,
                          ),
                          if (agency.address != null) ...[
                            Text(' · ', style: AppTextStyles.bodySmall),
                            Flexible(
                              child: Text(
                                agency.address!,
                                style: AppTextStyles.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (agency.isLicensed) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF9F1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'مكتب مرخص',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.verified,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Chevron
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: AppColors.mediumGray,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Similar properties horizontal scroll
// ─────────────────────────────────────────────
class _SimilarSection extends StatelessWidget {
  final List<PropertyModel> similar;

  const _SimilarSection({required this.similar});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'عقارات مشابهة'),
        const SizedBox(height: AppSpacing.base),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              right: AppSpacing.xl,
              left: AppSpacing.xl,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: similar.length,
            itemBuilder: (ctx, i) => SimilarPropertyCard(
              property: similar[i],
              onTap: () {
                Navigator.of(ctx).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, anim, __) => FadeTransition(
                      opacity: anim,
                      child: AdDetailPage(property: similar[i]),
                    ),
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Sticky bottom action bar
// ─────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  final PropertyModel property;

  const _BottomActionBar({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.base,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.lightGray.withOpacity(0.6),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // WhatsApp button - filled
          Expanded(
            child: _ActionButton(
              label: 'واتساب',
              icon: Icons.chat_rounded,
              filled: true,
              onTap: () {},
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Call button - outlined
          Expanded(
            child: _ActionButton(
              label: 'اتصال',
              icon: Icons.phone_rounded,
              filled: false,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: filled
              ? null
              : Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? AppColors.white : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: filled ? AppColors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
