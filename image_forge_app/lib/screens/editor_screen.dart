import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;
import 'package:saver_gallery/saver_gallery.dart';
import '../widgets/tool_panel.dart';
import '../widgets/resize_sheet.dart';
import '../widgets/compress_sheet.dart';
import '../widgets/adjust_sheet.dart';

class EditorScreen extends StatefulWidget {
  final File imageFile;
  const EditorScreen({super.key, required this.imageFile});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late File _currentFile;
  bool _isProcessing = false;
  String _statusMsg = '';
  int _originalSize = 0;
  int _currentSize = 0;
  img.Image? _imgData;

  // History for undo
  final List<File> _history = [];

  @override
  void initState() {
    super.initState();
    _currentFile = widget.imageFile;
    _history.add(_currentFile);
    _loadImageInfo();
  }

  Future<void> _loadImageInfo() async {
    final bytes = await _currentFile.readAsBytes();
    setState(() {
      _originalSize = widget.imageFile.lengthSync();
      _currentSize = bytes.length;
      _imgData = img.decodeImage(bytes);
    });
  }

  void _setProcessing(bool v, [String msg = '']) {
    setState(() { _isProcessing = v; _statusMsg = msg; });
  }

  void _pushHistory(File f) {
    _history.add(f);
    setState(() { _currentFile = f; });
    _loadImageInfo();
  }

  Future<void> _undo() async {
    if (_history.length <= 1) return;
    _history.removeLast();
    setState(() { _currentFile = _history.last; });
    _loadImageInfo();
  }

  // ─── Converting format ─────────────────────────────────────────────────────────────────
  // ─── CONVERT FORMAT ───────────────────────────────────────────────────────
  Future<void> _convertImage(String targetFormat) async {
    _setProcessing(true, 'Converting to $targetFormat...');
    try {
      final bytes = await _currentFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Cannot decode image');

      final tmpDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      late List<int> encoded;
      late String outPath;

      switch (targetFormat.toLowerCase()) {
        case 'jpeg':
        case 'jpg':
          encoded = img.encodeJpg(decoded, quality: 95);
          outPath = '${tmpDir.path}/converted_$timestamp.jpg';
          break;
        case 'png':
          encoded = img.encodePng(decoded);
          outPath = '${tmpDir.path}/converted_$timestamp.png';
          break;
        case 'bmp':
          encoded = img.encodeBmp(decoded);
          outPath = '${tmpDir.path}/converted_$timestamp.bmp';
          break;
        case 'gif':
          encoded = img.encodeGif(decoded);
          outPath = '${tmpDir.path}/converted_$timestamp.gif';
          break;
        case 'tga':
          encoded = img.encodeTga(decoded);
          outPath = '${tmpDir.path}/converted_$timestamp.tga';
          break;
        case 'webp':
          final result = await FlutterImageCompress.compressWithList(
              bytes, format: CompressFormat.webp, quality: 95);
          outPath = '${tmpDir.path}/converted_$timestamp.webp';
          final outFile = File(outPath)..writeAsBytesSync(result);
          _pushHistory(outFile);
          _showSnack('Converted to WEBP ✓');
          return;
        default:
          throw Exception('Unsupported format: $targetFormat');
      }

      final outFile = File(outPath)..writeAsBytesSync(encoded);
      _pushHistory(outFile);
      _showSnack('Converted to ${targetFormat.toUpperCase()} ✓');
    } catch (e) {
      _showSnack('Conversion failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }
  //-------Converting format into other -------------//
  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _currentFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color(0xFF141414),
          toolbarWidgetColor: const Color(0xFFE8FF47),
          backgroundColor: const Color(0xFF0A0A0A),
          activeControlsWidgetColor: const Color(0xFFE8FF47),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );
    if (croppedFile != null) {
      _pushHistory(File(croppedFile.path));
    }
  }
  // ─── RESIZE ───────────────────────────────────────────────────────────────
  Future<void> _resizeImage(int newW, int newH) async {
    _setProcessing(true, 'Resizing image...');
    try {
      final bytes = await _currentFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Cannot decode image');
      final resized = img.copyResize(decoded, width: newW, height: newH,
          interpolation: img.Interpolation.cubic);
      final tmpDir = await getTemporaryDirectory();
      final outPath = '${tmpDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath)..writeAsBytesSync(img.encodeJpg(resized, quality: 95));
      _pushHistory(outFile);
      _showSnack('Resized to ${newW}×${newH}px');
    } catch (e) {
      _showSnack('Resize failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }

  // ─── COMPRESS (DOWNGRADE) ─────────────────────────────────────────────────
  Future<void> _compressImage(int quality) async {
    _setProcessing(true, 'Compressing...');
    try {
      final tmpDir = await getTemporaryDirectory();
      final outPath = '${tmpDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        _currentFile.path,
        outPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (result != null) {
        _pushHistory(File(result.path));
        _showSnack('Compressed to quality $quality%');
      }
    } catch (e) {
      _showSnack('Compression failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }

  // ─── ENHANCE / UPSCALE ────────────────────────────────────────────────────
  Future<void> _enhanceImage(double scaleFactor) async {
    _setProcessing(true, 'Enhancing...');
    try {
      final bytes = await _currentFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Cannot decode image');
      final newW = (decoded.width * scaleFactor).round();
      final newH = (decoded.height * scaleFactor).round();
      final upscaled = img.copyResize(decoded, width: newW, height: newH,
          interpolation: img.Interpolation.cubic);
      // Apply sharpening
      final sharpened = img.convolution(upscaled, filter: [
        0, -0.5, 0,
        -0.5, 3, -0.5,
        0, -0.5, 0,
      ], div: 1, offset: 0);
      final tmpDir = await getTemporaryDirectory();
      final outPath = '${tmpDir.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath)..writeAsBytesSync(img.encodeJpg(sharpened, quality: 98));
      _pushHistory(outFile);
      _showSnack('Enhanced: ${newW}×${newH}px (${scaleFactor}x)');
    } catch (e) {
      _showSnack('Enhancement failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }

  // ─── ROTATE ───────────────────────────────────────────────────────────────
  Future<void> _rotateImage(int degrees) async {
    _setProcessing(true, 'Rotating...');
    try {
      final bytes = await _currentFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Cannot decode image');
      img.Image rotated;
      if (degrees == 90) rotated = img.copyRotate(decoded, angle: 90);
      else if (degrees == -90) rotated = img.copyRotate(decoded, angle: -90);
      else rotated = img.copyRotate(decoded, angle: 180);
      final tmpDir = await getTemporaryDirectory();
      final outPath = '${tmpDir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath)..writeAsBytesSync(img.encodeJpg(rotated, quality: 95));
      _pushHistory(outFile);
      _showSnack('Rotated ${degrees}°');
    } catch (e) {
      _showSnack('Rotate failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }

  // ─── FLIP ─────────────────────────────────────────────────────────────────
  Future<void> _flipImage(bool horizontal) async {
    _setProcessing(true, 'Flipping...');
    try {
      final bytes = await _currentFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Cannot decode image');
      final flipped = horizontal
          ? img.flipHorizontal(decoded)
          : img.flipVertical(decoded);
      final tmpDir = await getTemporaryDirectory();
      final outPath = '${tmpDir.path}/flipped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath)..writeAsBytesSync(img.encodeJpg(flipped, quality: 95));
      _pushHistory(outFile);
      _showSnack('Flipped ${horizontal ? "horizontally" : "vertically"}');
    } catch (e) {
      _showSnack('Flip failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }

  // ─── ADJUST ───────────────────────────────────────────────────────────────
  Future<void> _adjustImage({
    required double brightness,
    required double contrast,
    required double saturation,
  }) async {
    _setProcessing(true, 'Adjusting...');
    try {
      final bytes = await _currentFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Cannot decode image');

      img.Image adjusted = decoded;

      // Brightness
      if (brightness != 0) {
        adjusted = img.adjustColor(adjusted,
            brightness: brightness.clamp(-1.0, 1.0));
      }

      // Contrast
      if (contrast != 1.0) {
        adjusted = img.adjustColor(adjusted, contrast: contrast);
      }

      // Saturation
      if (saturation != 1.0) {
        adjusted = img.adjustColor(adjusted, saturation: saturation);
      }

      final tmpDir = await getTemporaryDirectory();
      final outPath = '${tmpDir.path}/adjusted_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath)..writeAsBytesSync(img.encodeJpg(adjusted, quality: 95));
      _pushHistory(outFile);
      _showSnack('Adjustments applied');
    } catch (e) {
      _showSnack('Adjustment failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }

  // ─── GRAYSCALE ────────────────────────────────────────────────────────────
  Future<void> _grayscaleImage() async {
    _setProcessing(true, 'Converting to grayscale...');
    try {
      final bytes = await _currentFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Cannot decode image');
      final gray = img.grayscale(decoded);
      final tmpDir = await getTemporaryDirectory();
      final outPath = '${tmpDir.path}/gray_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath)..writeAsBytesSync(img.encodeJpg(gray, quality: 95));
      _pushHistory(outFile);
      _showSnack('Grayscale applied');
    } catch (e) {
      _showSnack('Grayscale failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }

  // ─── SAVE / SHARE ─────────────────────────────────────────────────────────
  Future<void> _saveImage() async {
    _setProcessing(true, 'Saving...');
    try {
      final bytes = await _currentFile.readAsBytes();
      await SaverGallery.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        name: 'imageforge_${DateTime.now().millisecondsSinceEpoch}',
        androidRelativePath: 'Pictures/ImageForge',
        androidExistNotSave: false
      );
      _showSnack('Saved to gallery ✓');
    } catch (e) {
      _showSnack('Save failed: $e', error: true);
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _shareImage() async {
    await Share.shareXFiles(
      [XFile(_currentFile.path)],
      text: 'Edited with ImageForge',
    );
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.firaCode(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: error ? const Color(0xFFFF4444) : const Color(0xFF1C2A00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF141414),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ImageForge',
                          style: GoogleFonts.syne(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_imgData != null)
                          Text(
                            '${_imgData!.width}×${_imgData!.height}  •  ${_formatBytes(_currentSize)}',
                            style: GoogleFonts.firaCode(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Undo
                  IconButton(
                    icon: const Icon(Icons.undo_rounded, color: Colors.white54, size: 22),
                    onPressed: _history.length > 1 ? _undo : null,
                    tooltip: 'Undo',
                  ),
                  // Save
                  GestureDetector(
                    onTap: _saveImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8FF47),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SAVE',
                        style: GoogleFonts.syne(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Image Preview ──────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Checkerboard background
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/checker.png'),
                        repeat: ImageRepeat.repeat,
                        scale: 4,
                      ),
                    ),
                  ),
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 5,
                      child: Image.file(
                        _currentFile,
                        fit: BoxFit.contain,
                        key: ValueKey(_currentFile.path),
                      ),
                    ),
                  ),
                  // Processing overlay
                  if (_isProcessing)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 40, height: 40,
                              child: CircularProgressIndicator(
                                color: Color(0xFFE8FF47),
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _statusMsg,
                              style: GoogleFonts.firaCode(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info Bar ──────────────────────────────────────────────────
            if (_imgData != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF141414),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoChip(label: 'W', value: '${_imgData!.width}px'),
                    _InfoChip(label: 'H', value: '${_imgData!.height}px'),
                    _InfoChip(label: 'SIZE', value: _formatBytes(_currentSize)),
                    _InfoChip(
                      label: 'ORIG',
                      value: _formatBytes(_originalSize),
                      dimmed: true,
                    ),
                  ],
                ),
              ),

            // ── Tool Panel ────────────────────────────────────────────────
            ToolPanel(
              onCrop: _cropImage,
              onResize: () => _showResizeSheet(),
              onCompress: () => _showCompressSheet(),
              onEnhance: () => _showEnhanceSheet(),
              onRotateLeft: () => _rotateImage(-90),
              onRotateRight: () => _rotateImage(90),
              onFlipH: () => _flipImage(true),
              onFlipV: () => _flipImage(false),
              onGrayscale: _grayscaleImage,
              onAdjust: () => _showAdjustSheet(),
              onShare: _shareImage,
              onConvert: () => _showConvertSheet(),

            ),
          ],
        ),
      ),
    );
  }

  void _showResizeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResizeSheet(
        currentWidth: _imgData?.width ?? 0,
        currentHeight: _imgData?.height ?? 0,
        onResize: (w, h) {
          Navigator.pop(context);
          _resizeImage(w, h);
        },
      ),
    );
  }

  void _showCompressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompressSheet(
        currentSize: _currentSize,
        onCompress: (quality) {
          Navigator.pop(context);
          _compressImage(quality);
        },
      ),
    );
  }

  void _showEnhanceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ENHANCE / UPSCALE',
                style: GoogleFonts.syne(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            ...[
              ('1.5x Upscale', 1.5),
              ('2x Upscale', 2.0),
              ('2x + Sharpen', 2.0),
            ].map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _enhanceImage(e.$2);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_fix_high_rounded,
                          color: Color(0xFFB47FFF), size: 20),
                      const SizedBox(width: 12),
                      Text(e.$1,
                          style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                    ],
                  ),
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAdjustSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdjustSheet(
        onApply: (brightness, contrast, saturation) {
          Navigator.pop(context);
          _adjustImage(
              brightness: brightness,
              contrast: contrast,
              saturation: saturation);
        },
      ),
    );
  }
  void _showConvertSheet() {
    final formats = [
      ('JPEG', 'jpg', Icons.image_rounded, const Color(0xFFFF6B35)),
      ('PNG', 'png', Icons.image_outlined, const Color(0xFF47C8FF)),
      ('BMP', 'bmp', Icons.crop_original_rounded, const Color(0xFF47FFB4)),
      ('GIF', 'gif', Icons.gif_box_rounded, const Color(0xFFFFD447)),
      ('TGA', 'tga', Icons.layers_rounded, const Color(0xFFB47FFF)),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              Text(
                'CONVERT FORMAT',
                style: GoogleFonts.syne(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Current: ${_currentFile.path.split('.').last.toUpperCase()}',
                style: GoogleFonts.firaCode(color: Colors.white30, fontSize: 11),
              ),
              const SizedBox(height: 20),
              ...formats.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _convertImage(f.$2);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: f.$4.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: f.$4.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(f.$3, color: f.$4, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.$1,
                              style: GoogleFonts.syne(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '.${f.$2} format',
                              style: GoogleFonts.firaCode(
                                color: Colors.white30,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                      ],
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool dimmed;

  const _InfoChip({
    required this.label,
    required this.value,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.firaCode(
                color: Colors.white24, fontSize: 9, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.firaCode(
                color: dimmed ? Colors.white30 : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
