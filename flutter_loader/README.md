

# Flutter Binary Image (Logo / FlutterLoader)

A Flutter application that transforms any photo into a high-density binary artwork made entirely of `0`s and `1`s.

- Zoom **out** → the original image becomes clearly visible  
- Zoom **in** → you only see individual `0`s and `1`s  
- Transparent areas are rendered as empty space  
- Works on Android, iOS, Web, Windows, macOS and Linux

---

## Features

- Convert any image (including PNGs with transparency) into binary art
- Extremely dense grid of `0`s and `1`s
- Interactive zoom & pan (`InteractiveViewer`)
- Optional color mode (characters take the average color of the original pixel region)
- Persistent storage (last converted image is saved and loaded automatically)
- Clean black background with pure white (or colored) characters
- Support for high-resolution conversion

---



---

## Getting Started

### Prerequisites
- Flutter SDK (3.12 or higher recommended)
- A device / emulator or Chrome for web

### Installation

1. Clone the repository
```bash
git clone https://github.com/Tebohotet/Logo.git
cd Logo/flutter_loader
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
# Mobile / Desktop
flutter run

# Web
flutter run -d chrome
```

---

## How to Use

1. Open the app
2. Tap the image icon in the AppBar
3. Select a photo from your gallery
4. Wait a few seconds while the image is processed
5. Zoom and pan freely:
   - Zoom out to see the full picture
   - Zoom in to inspect individual `0`s and `1`s

The converted binary image is automatically saved and will load the next time you open the app.

---

## Technical Details

- **Grid resolution**: High density (hundreds of columns/rows)
- **Sampling**: Average brightness + alpha channel per cell
- **Transparent pixels**: Rendered as spaces
- **Font**: Monospace (`Roboto Mono` / system monospace)
- **Rendering**: `CustomPainter` for maximum performance and control
- **Storage**: `shared_preferences`

### Dependencies
- `image_picker`
- `google_fonts`
- `shared_preferences`
- `path_provider`

---

## Planned / Possible Improvements

- [ ] Export as high-resolution PNG / PDF
- [ ] Color mode toggle (already partially implemented)
- [ ] Contrast & brightness controls
- [ ] Animation modes (Matrix rain, random bit flipping)
- [ ] Use as custom loading screen
- [ ] Save multiple binary artworks

---

## Project Structure

```
flutter_loader/
├── lib/
│   └── main.dart          # Main application code
├── android/ ios/ web/ ... # Platform folders
└── pubspec.yaml
```

---

## License

This project is open source. Feel free to use, modify and distribute.

---

**Made with Flutter**
```

---

You can copy the short description into the GitHub repository settings → "Description", and replace the current `README.md` inside the `flutter_loader` folder (or create one at the root of the repository) with the full documentation above.

Would you like me to also write a shorter version, add badges, or include specific installation instructions for web only?