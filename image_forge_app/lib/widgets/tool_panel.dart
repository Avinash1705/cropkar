import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolPanel extends StatelessWidget {
  final VoidCallback onCrop;
  final VoidCallback onConvert;
  final VoidCallback onResize;
  final VoidCallback onCompress;
  final VoidCallback onEnhance;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onFlipH;
  final VoidCallback onFlipV;
  final VoidCallback onGrayscale;
  final VoidCallback onAdjust;
  final VoidCallback onShare;

  const ToolPanel({
    super.key,
    required this.onCrop,
    required this.onConvert,
    required this.onResize,
    required this.onCompress,
    required this.onEnhance,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onFlipH,
    required this.onFlipV,
    required this.onGrayscale,
    required this.onAdjust,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0F0F),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary tools row
          Container(
            height: 80,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E1E1E))),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: [_ToolBtn(
                icon: Icons.sync_alt_rounded,
                label: 'Convert',
                color: const Color(0xFFFF6B35),
                onTap: onConvert,
              ),
                _ToolBtn(
                  icon: Icons.crop_rounded,
                  label: 'Crop',
                  color: const Color(0xFFE8FF47),
                  onTap: onCrop,
                ),
                _ToolBtn(
                  icon: Icons.photo_size_select_large_rounded,
                  label: 'Resize',
                  color: const Color(0xFFFF6B35),
                  onTap: onResize,
                ),
                _ToolBtn(
                  icon: Icons.compress_rounded,
                  label: 'Compress',
                  color: const Color(0xFF47C8FF),
                  onTap: onCompress,
                ),
                _ToolBtn(
                  icon: Icons.auto_fix_high_rounded,
                  label: 'Enhance',
                  color: const Color(0xFFB47FFF),
                  onTap: onEnhance,
                ),
                _ToolBtn(
                  icon: Icons.rotate_left_rounded,
                  label: 'Rotate L',
                  color: const Color(0xFFFF47A3),
                  onTap: onRotateLeft,
                ),
                _ToolBtn(
                  icon: Icons.rotate_right_rounded,
                  label: 'Rotate R',
                  color: const Color(0xFFFF47A3),
                  onTap: onRotateRight,
                ),
                _ToolBtn(
                  icon: Icons.flip_rounded,
                  label: 'Flip H',
                  color: const Color(0xFF47FFB4),
                  onTap: onFlipH,
                ),
                _ToolBtn(
                  icon: Icons.flip_rounded,
                  label: 'Flip V',
                  color: const Color(0xFF47FFB4),
                  iconRotated: true,
                  onTap: onFlipV,
                ),
                _ToolBtn(
                  icon: Icons.tune_rounded,
                  label: 'Adjust',
                  color: const Color(0xFFFFD447),
                  onTap: onAdjust,
                ),
                _ToolBtn(
                  icon: Icons.filter_b_and_w_rounded,
                  label: 'Grayscale',
                  color: Colors.white54,
                  onTap: onGrayscale,
                ),
                _ToolBtn(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: const Color(0xFFFF6B35),
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool iconRotated;

  const _ToolBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconRotated = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: iconRotated ? 1.5708 : 0,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.firaCode(
                color: color.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
