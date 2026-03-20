import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdjustSheet extends StatefulWidget {
  final void Function(double brightness, double contrast, double saturation) onApply;

  const AdjustSheet({super.key, required this.onApply});

  @override
  State<AdjustSheet> createState() => _AdjustSheetState();
}

class _AdjustSheetState extends State<AdjustSheet> {
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('ADJUST',
                  style: GoogleFonts.syne(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _brightness = 0;
                  _contrast = 1;
                  _saturation = 1;
                }),
                child: Text('RESET',
                    style: GoogleFonts.firaCode(
                        color: const Color(0xFFFF6B35),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _AdjustSlider(
            label: 'Brightness',
            value: _brightness,
            min: -1,
            max: 1,
            color: const Color(0xFFFFD447),
            displayValue: '${(_brightness * 100).round()}',
            onChanged: (v) => setState(() => _brightness = v),
          ),
          const SizedBox(height: 16),
          _AdjustSlider(
            label: 'Contrast',
            value: _contrast,
            min: 0.1,
            max: 3.0,
            color: const Color(0xFF47C8FF),
            displayValue: '${(_contrast * 100).round()}%',
            onChanged: (v) => setState(() => _contrast = v),
          ),
          const SizedBox(height: 16),
          _AdjustSlider(
            label: 'Saturation',
            value: _saturation,
            min: 0,
            max: 3.0,
            color: const Color(0xFFFF47A3),
            displayValue: '${(_saturation * 100).round()}%',
            onChanged: (v) => setState(() => _saturation = v),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => widget.onApply(_brightness, _contrast, _saturation),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD447),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'APPLY ADJUSTMENTS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.syne(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
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

class _AdjustSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Color color;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _AdjustSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.syne(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text(displayValue,
                style: GoogleFonts.firaCode(color: color, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: const Color(0xFF333333),
            thumbColor: color,
            overlayColor: color.withOpacity(0.15),
            trackHeight: 3,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
