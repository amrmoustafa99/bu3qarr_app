import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/models.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/property_card.dart';
import '../../shared/widgets/shared_widgets.dart';

const Color _kTextBlack = Color(0xFF1D1D1F);

class AdDetailPage extends StatefulWidget {
  final PropertyModel property;

  const AdDetailPage({super.key, required this.property});

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> {
  bool _descExpanded = false;
  int _currentImagePage = 0;

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
                    child: _ImageSlider(
                      property: p,
                      imageH: imageHeight,
                      onPageChanged: (i) =>
                          setState(() => _currentImagePage = i),
                    ),
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
                                  top: 10,
                                  bottom: 8,
                                ),
                                width: 44,
                                height: 5,
                                decoration: BoxDecoration(
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

                            const SizedBox(height: AppSpacing.md),
                            const SubtleDivider(),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      ),

                      // Description
                      if (p.description != null)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.md),
                              _DescriptionSection(
                                description: p.description!,
                                expanded: _descExpanded,
                                onToggle: () => setState(
                                  () => _descExpanded = !_descExpanded,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _SpecList(property: p),
                              const SizedBox(height: AppSpacing.md),
                              const SubtleDivider(),
                            ],
                          ),
                        ),

                      // Ad Code
                      if (p.adCode != null)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.md),
                              _AdCodeSection(adCode: p.adCode!),
                              const SizedBox(height: AppSpacing.md),
                              const SubtleDivider(),
                            ],
                          ),
                        ),

                      // Agency
                      if (p.agency != null)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.md),
                              _AgencySection(agency: p.agency!),
                              const SizedBox(height: AppSpacing.md),
                              const SubtleDivider(),
                            ],
                          ),
                        ),

                      // Similar
                      if (_similar.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.md),
                              _SimilarSection(similar: _similar),
                              const SizedBox(height: AppSpacing.md),
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

          // ───────────────── Floating Top Bar ─────────────────
          _FloatingTopBar(),
          // ───────────────── Bottom Dots + Counter Indicator ─────────────────
          AnimatedBuilder(
            animation: _sheetCtrl,
            builder: (context, child) {
              final size = _sheetCtrl.isAttached ? _sheetCtrl.size : 0.60;

              // مكان الـ indicator فوق الـ sheet
              final bottomPos = (screenH * size) + 18;

              return Positioned(
                left: 20,
                right: 20,
                bottom: bottomPos,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ───────────────── Dots بالنص ─────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          p.images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImagePage == index ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImagePage == index
                                  ? AppColors.primary
                                  : Colors.white.withOpacity(.45),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ───────────────── Counter شمال ─────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.45),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${_currentImagePage + 1}/${p.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // ───────────────── Bottom Bar ─────────────────
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
// Image Slider
// ─────────────────────────────────────────────
class _ImageSlider extends StatefulWidget {
  final PropertyModel property;
  final double imageH;
  final Function(int) onPageChanged;

  const _ImageSlider({
    required this.property,
    required this.imageH,
    required this.onPageChanged,
  });

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.property.images;
    final imageH = widget.imageH;

    return SizedBox(
      height: imageH,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ───────────────── Images ─────────────────
          Hero(
            tag: 'property_image_${widget.property.id}',
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);

                // مهم جدًا
                widget.onPageChanged(index);
              },
              itemBuilder: (_, index) {
                return PropertyImage(
                  url: images[index],
                  width: double.infinity,
                  height: imageH,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // ───────────────── Gradient ─────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 170,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.38),
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
// Image Counter Indicator  e.g. "1 / 3"
// ─────────────────────────────────────────────
class _ImageIndicator extends StatelessWidget {
  final int imageCount;
  final int currentPage;

  const _ImageIndicator({required this.imageCount, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    if (imageCount <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '${currentPage + 1} / $imageCount',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
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
            icon: Icons.arrow_back_ios_new_rounded,
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
        child: Icon(icon, size: 17, color: _kTextBlack),
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
          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.mediumGray,
              ),
              const SizedBox(width: 3),
              Text(
                property.location,
                style: AppTextStyles.bodyMedium.copyWith(color: _kTextBlack),
              ),
              const Spacer(),
              Text(property.timeAgo, style: AppTextStyles.bodySmall),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            property.title,
            style: AppTextStyles.displayMedium.copyWith(color: _kTextBlack),
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                property.price,
                style: AppTextStyles.priceLarge.copyWith(color: _kTextBlack),
              ),
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
// Spec List
// ─────────────────────────────────────────────
class _SpecList extends StatelessWidget {
  final PropertyModel property;

  const _SpecList({required this.property});

  @override
  Widget build(BuildContext context) {
    final specs = <_SpecItem>[
      _SpecItem(icon: Icons.home_work_outlined, label: 'بيت'),
      _SpecItem(icon: Icons.layers_outlined, label: '${property.area} م2'),
      _SpecItem(icon: Icons.location_on_outlined, label: 'زاوية'),
      _SpecItem(icon: Icons.sell_outlined, label: 'سكني'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          for (int i = 0; i < specs.length; i++) ...[
            _SpecRow(item: specs[i]),
            if (i < specs.length - 1)
              Divider(height: 1, thickness: .6, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;

  const _SpecItem({required this.icon, required this.label});
}

class _SpecRow extends StatelessWidget {
  final _SpecItem item;

  const _SpecRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 18, color: const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
          Text(
            'الوصف',
            style: AppTextStyles.titleLarge.copyWith(color: _kTextBlack),
          ),
          const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expanded ? 'عرض أقل' : 'قراءة المزيد',
                  style: AppTextStyles.label.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: _kTextBlack,
                    color: _kTextBlack,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: _kTextBlack,
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
// Ad Code Section
// ─────────────────────────────────────────────
class _AdCodeSection extends StatelessWidget {
  final String adCode;

  const _AdCodeSection({required this.adCode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF737373),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '$adCode | رمز الإعلان',
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

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
          Text(
            'المكتب العقاري',
            style: AppTextStyles.titleLarge.copyWith(color: _kTextBlack),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
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
                    borderRadius: BorderRadius.circular(AppRadius.xl),
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
                      Text(
                        agency.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: _kTextBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: _kTextBlack,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'مكتب مرخص',
                              style: AppTextStyles.caption.copyWith(
                                color: _kTextBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            'عقارات مشابهة',
            style: AppTextStyles.titleLarge.copyWith(color: _kTextBlack),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
        top: 12,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _IconActionButton(
              icon: Icons.phone_outlined,
              filled: false,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _IconActionButton(
              icon: FontAwesomeIcons.whatsapp,
              filled: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _IconActionButton({
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
          color: filled ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 25,
            color: filled ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
