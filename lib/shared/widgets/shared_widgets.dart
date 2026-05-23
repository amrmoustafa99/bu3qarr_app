import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
// Favorite Button
// ─────────────────────────────────────────────
class FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback? onToggle;

  const FavoriteButton({
    super.key,
    this.isFavorited = false,
    this.onToggle,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late bool _isFav;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorited;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isFav = !_isFav);
    _controller.forward().then((_) => _controller.reverse());
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: _isFav ? AppColors.primary : AppColors.black,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Category Chip
// ─────────────────────────────────────────────
class CategoryBadge extends StatelessWidget {
  final String label;

  const CategoryBadge({super.key, required this.label});

  Color get _bgColor {
    switch (label) {
      case 'بيع':
        return const Color(0xFFEEF9F1);
      case 'إيجار':
        return const Color(0xFFEFF5FF);
      case 'بدل':
        return const Color(0xFFFFF7EE);
      default:
        return AppColors.ultraLightGray;
    }
  }

  Color get _textColor {
    switch (label) {
      case 'بيع':
        return const Color(0xFF1A8C40);
      case 'إيجار':
        return const Color(0xFF1A5FAC);
      case 'بدل':
        return const Color(0xFFB86E00);
      default:
        return AppColors.darkGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Spec Chip
// ─────────────────────────────────────────────
class SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const SpecChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.ultraLightGray,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.lightGray, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mediumGray),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Title
// ─────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text(title, style: AppTextStyles.titleLarge),
    );
  }
}

// ─────────────────────────────────────────────
// Subtle Divider
// ─────────────────────────────────────────────
class SubtleDivider extends StatelessWidget {
  final double indent;

  const SubtleDivider({super.key, this.indent = AppSpacing.xl});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: AppColors.lightGray.withOpacity(0.5),
      indent: indent,
      endIndent: indent,
    );
  }
}

// ─────────────────────────────────────────────
// Bu3qar Logo Text
// ─────────────────────────────────────────────
class Bu3qarLogo extends StatelessWidget {
  final double size;

  const Bu3qarLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'بو',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: size,
              color: AppColors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'عقار',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: size,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Network Image with Shimmer
// ─────────────────────────────────────────────
class PropertyImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PropertyImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _ShimmerBox(width: width, height: height),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.ultraLightGray,
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.lightGray,
          size: 36,
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;

  const _ShimmerBox({this.width, this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        color: Color.lerp(
          AppColors.shimmer1,
          AppColors.shimmer2,
          _anim.value,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Detail Row
// ─────────────────────────────────────────────
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.mediumGray),
            const SizedBox(width: AppSpacing.md),
          ],
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
