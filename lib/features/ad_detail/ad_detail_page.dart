import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

class _AdDetailPageState extends State<AdDetailPage> {
  bool _descExpanded = false;

  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();

  List<PropertyModel> get _similar => sampleProperties
      .where(
        (p) =>
            p.id != widget.property.id &&
            p.category == widget.property.category,
      )
      .take(6)
      .toList();

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ───────────────── Background Image ─────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sheetCtrl,
              builder: (context, child) {
                double size = 0.60;

                if (_sheetCtrl.isAttached) {
                  size = _sheetCtrl.size;
                }

                final imageHeight = screenH * (1 - (size - 0.15));

                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: imageHeight.clamp(screenH * 0.42, screenH * 0.75),
                    width: double.infinity,
                    child: _SingleImage(property: p, imageH: imageHeight),
                  ),
                );
              },
            ),
          ),

          // ───────────────── Draggable Sheet ─────────────────
          DraggableScrollableSheet(
            controller: _sheetCtrl,
            initialChildSize: 0.60,
            minChildSize: 0.60,
            maxChildSize: 0.96,
            snap: true,
            snapSizes: const [0.60, 0.96],
            builder: (ctx, scrollCtrl) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(34),
                    topRight: Radius.circular(34),
                  ),

                  // ✨ Shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.32),
                      blurRadius: 65,
                      spreadRadius: 8,
                      offset: const Offset(0, -18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(34),
                    topRight: Radius.circular(34),
                  ),
                  child: CustomScrollView(
                    controller: scrollCtrl,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Drag Handle
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: AppSpacing.md,
                                  bottom: AppSpacing.md,
                                ),
                                width: 44,
                                height: 5,
                                decoration: BoxDecoration(
                                  //  color: const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(100),

                                  color: Colors.grey.shade300,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Main Info
                            _MainInfo(property: p),

                            const SizedBox(height: AppSpacing.xl),
                            const SubtleDivider(),
                            const SizedBox(height: AppSpacing.xl),

                            // Spec Chips
                            _SpecChips(property: p),

                            const SizedBox(height: AppSpacing.xl),
                            const SubtleDivider(),
                          ],
                        ),
                      ),

                      // Description
                      if (p.description != null)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.xl),
                              _DescriptionSection(
                                description: p.description!,
                                expanded: _descExpanded,
                                onToggle: () => setState(
                                  () => _descExpanded = !_descExpanded,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              const SubtleDivider(),
                            ],
                          ),
                        ),

                      // Ad Code
                      if (p.adCode != null)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.xl),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      ' رمز الإعلان  |  ${p.adCode!} ',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: AppColors.mediumGray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              const SubtleDivider(),
                            ],
                          ),
                        ),

                      // Agency
                      if (p.agency != null)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.xl),
                              _AgencySection(agency: p.agency!),
                              const SizedBox(height: AppSpacing.xl),
                              const SubtleDivider(),
                            ],
                          ),
                        ),

                      // Similar
                      if (_similar.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.xl),
                              _SimilarSection(similar: _similar),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 110)),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating buttons
          _FloatingTopBar(),

          // Bottom Bar
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
// Single Image
// ─────────────────────────────────────────────
class _SingleImage extends StatelessWidget {
  final PropertyModel property;
  final double imageH;

  const _SingleImage({required this.property, required this.imageH});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageH,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'property_image_${property.id}',
            child: PropertyImage(
              url: property.images.first,
              width: double.infinity,
              height: imageH,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 140,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Floating Top Bar
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.14),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 17, color: AppColors.black),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Main Info
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
          const SizedBox(height: AppSpacing.md),

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

          Text(property.title, style: AppTextStyles.displayMedium),

          const SizedBox(height: AppSpacing.lg),

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
// Spec chips
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
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
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
          Expanded(
            child: _ActionButton(
              label: 'واتساب',
              icon: FontAwesomeIcons.whatsapp,
              filled: true,
              onTap: () {},
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
