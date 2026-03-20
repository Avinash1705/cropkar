import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResizeSheet extends StatefulWidget {
  final int currentWidth;
  final int currentHeight;
  final void Function(int w, int h) onResize;

  const ResizeSheet({
    super.key,
    required this.currentWidth,
    required this.currentHeight,
    required this.onResize,
  });

  @override
  State<ResizeSheet> createState() => _ResizeSheetState();
}

class _ResizeSheetState extends State<ResizeSheet> {
  late TextEditingController _wCtrl;
  late TextEditingController _hCtrl;
  bool _lockRatio = true;
  late double _ratio;

  final List<({String label, int w, int h})> _presets = [
    (label: '1080p', w: 1920, h: 1080),
    (label: '720p', w: 1280, h: 720),
    (label: 'HD Square', w: 1080, h: 1080),
    (label: '4K', w: 3840, h: 2160),
    (label: 'Twitter', w: 1500, h: 500),
    (label: 'Instagram', w: 1080, h: 1350),
  ];

  @override
  void initState() {
    super.initState();
    _wCtrl = TextEditingController(text: widget.currentWidth.toString());
    _hCtrl = TextEditingController(text: widget.currentHeight.toString());
    _ratio = widget.currentHeight > 0
        ? widget.currentWidth / widget.currentHeight
        : 1;
  }

  @override
  void dispose() {
    _wCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  void _onWidthChanged(String val) {
    if (!_lockRatio) return;
    final w = int.tryParse(val);
    if (w != null && w > 0) {
      _hCtrl.text = (w / _ratio).round().toString();
    }
  }

  void _onHeightChanged(String val) {
    if (!_lockRatio) return;
    final h = int.tryParse(val);
    if (h != null && h > 0) {
      _wCtrl.text = (h * _ratio).round().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          Text('RESIZE IMAGE',
              style: GoogleFonts.syne(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // Presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) => GestureDetector(
              onTap: () {
                _wCtrl.text = p.w.toString();
                _hCtrl.text = p.h.toString();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Text(
                  '${p.label} ${p.w}×${p.h}',
                  style: GoogleFonts.firaCode(
                      color: Colors.white54, fontSize: 10),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),

          // Width & Height inputs
          Row(
            children: [
              Expanded(
                child: _DimField(
                  label: 'Width',
                  controller: _wCtrl,
                  onChanged: _onWidthChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _lockRatio = !_lockRatio),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _lockRatio
                          ? const Color(0xFFE8FF47).withOpacity(0.1)
                          : const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _lockRatio
                            ? const Color(0xFFE8FF47).withOpacity(0.4)
                            : const Color(0xFF333333),
                      ),
                    ),
                    child: Icon(
                      _lockRatio ? Icons.lock_rounded : Icons.lock_open_rounded,
                      color: _lockRatio
                          ? const Color(0xFFE8FF47)
                          : Colors.white38,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _DimField(
                  label: 'Height',
                  controller: _hCtrl,
                  onChanged: _onHeightChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                final w = int.tryParse(_wCtrl.text);
                final h = int.tryParse(_hCtrl.text);
                if (w != null && h != null && w > 0 && h > 0) {
                  widget.onResize(w, h);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FF47),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'APPLY RESIZE',
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

class _DimField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String) onChanged;

  const _DimField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.firaCode(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: GoogleFonts.firaCode(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            suffixText: 'px',
            suffixStyle: GoogleFonts.firaCode(
                color: Colors.white30, fontSize: 11),
            filled: true,
            fillColor: const Color(0xFF252525),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFFE8FF47), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
