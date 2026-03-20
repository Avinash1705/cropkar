import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompressSheet extends StatefulWidget {
  final int currentSize;
  final void Function(int quality) onCompress;

  const CompressSheet({
    super.key,
    required this.currentSize,
    required this.onCompress,
  });

  @override
  State<CompressSheet> createState() => _CompressSheetState();
}

class _CompressSheetState extends State<CompressSheet> {
  double _quality = 75;

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  String _estimatedSize() {
    final ratio = _quality / 100;
    final est = (widget.currentSize * ratio * 0.8).round();
    return _formatBytes(est);
  }

  Color get _qualityColor {
    if (_quality >= 80) return const Color(0xFF47FFB4);
    if (_quality >= 50) return const Color(0xFFFFD447);
    return const Color(0xFFFF6B35);
  }

  String get _qualityLabel {
    if (_quality >= 80) return 'HIGH';
    if (_quality >= 60) return 'MEDIUM';
    if (_quality >= 30) return 'LOW';
    return 'VERY LOW';
  }

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
          Text('COMPRESS IMAGE',
              style: GoogleFonts.syne(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),

          // Quality display
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quality',
                        style: GoogleFonts.firaCode(
                            color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_quality.round()}%',
                          style: GoogleFonts.syne(
                            color: _qualityColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _qualityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _qualityLabel,
                              style: GoogleFonts.firaCode(
                                  color: _qualityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Est. Output',
                      style: GoogleFonts.firaCode(
                          color: Colors.white38, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(
                    _estimatedSize(),
                    style: GoogleFonts.syne(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'from ${_formatBytes(widget.currentSize)}',
                    style: GoogleFonts.firaCode(
                        color: Colors.white30, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _qualityColor,
              inactiveTrackColor: const Color(0xFF333333),
              thumbColor: _qualityColor,
              overlayColor: _qualityColor.withOpacity(0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: _quality,
              min: 10,
              max: 100,
              divisions: 90,
              onChanged: (v) => setState(() => _quality = v),
            ),
          ),

          // Quick presets
          const SizedBox(height: 8),
          Row(
            children: [10, 30, 50, 75, 90].map((q) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () => setState(() => _quality = q.toDouble()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _quality.round() == q
                          ? _qualityColor.withOpacity(0.15)
                          : const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _quality.round() == q
                            ? _qualityColor.withOpacity(0.4)
                            : const Color(0xFF333333),
                      ),
                    ),
                    child: Text(
                      '$q%',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.firaCode(
                        color: _quality.round() == q
                            ? _qualityColor
                            : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),

          const SizedBox(height: 20),

          // Apply
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => widget.onCompress(_quality.round()),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF47C8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'COMPRESS',
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
