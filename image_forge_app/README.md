# 🖼 ImageForge — Flutter Image Editor

A professional image editing app with a dark, industrial aesthetic.

## Features

| Tool | Description |
|------|-------------|
| ✂️ **Crop** | Free-form & preset ratios (1:1, 16:9, 4:3, 3:2, 9:16) |
| 📐 **Resize** | Custom dimensions with aspect ratio lock + 6 presets |
| 🗜 **Compress** | JPEG quality control (10–100%), estimated output size |
| ✨ **Enhance** | 1.5x / 2x upscale with optional sharpening |
| 🔄 **Rotate** | 90° left/right, 180° |
| ↔️ **Flip** | Horizontal and vertical |
| 🎨 **Adjust** | Brightness, contrast, saturation sliders |
| ⬛ **Grayscale** | Convert to black & white |
| 💾 **Save** | Save to gallery |
| 📤 **Share** | Share via any app |
| ↩️ **Undo** | Non-destructive editing with full history |

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Run the app
```bash
flutter run
```

### 3. Build for release
```bash
flutter build apk --release
# or
flutter build ios --release
```

## Dependencies

```yaml
image_picker: ^1.0.7        # Camera & gallery access
image: ^4.1.3               # Image processing (resize, rotate, flip, adjust)
image_cropper: ^5.0.1       # Native crop UI (uses uCrop on Android)
flutter_image_compress: ^2.1.0  # JPEG/WebP compression
path_provider: ^2.1.2       # Temp file storage
permission_handler: ^11.3.0 # Runtime permissions
share_plus: ^9.0.0          # Share image
google_fonts: ^6.2.1        # Syne + Fira Code fonts
saver_gallery: ^3.0.6       # Save to gallery
```

## Permissions

### Android (`AndroidManifest.xml`)
- `READ_MEDIA_IMAGES` (Android 13+)
- `READ_EXTERNAL_STORAGE` (Android ≤12)
- `WRITE_EXTERNAL_STORAGE` (Android ≤29)
- `CAMERA`

### iOS (`Info.plist`)
Add these keys:
```xml
<key>NSCameraUsageDescription</key>
<string>To capture photos for editing</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>To pick images for editing</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>To save edited images to your library</string>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point & theme
├── screens/
│   ├── home_screen.dart      # Dashboard with feature cards
│   └── editor_screen.dart    # Main editor with all operations
└── widgets/
    ├── tool_panel.dart       # Scrollable tool buttons bar
    ├── resize_sheet.dart     # Resize bottom sheet
    ├── compress_sheet.dart   # Compress quality sheet
    └── adjust_sheet.dart     # Brightness/Contrast/Saturation sheet
```

## Notes

- All edits are **non-destructive** — the original file is never modified
- Each operation creates a temp file and pushes to history
- Use the **undo button** (↩) in the top bar to step back
- InteractiveViewer lets you **pinch-to-zoom** the preview
