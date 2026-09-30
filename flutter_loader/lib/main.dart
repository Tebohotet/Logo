import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:io'; // for web use 'dart:html' if needed

void main() => runApp(const FlutterLoaderApp());

class FlutterLoaderApp extends StatelessWidget {
  const FlutterLoaderApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FlutterLoader',
        theme: ThemeData.dark(),
        home: const BinaryViewerScreen(),
        debugShowCheckedModeBanner: false,
      );
}

class BinaryViewerScreen extends StatefulWidget {
  const BinaryViewerScreen({super.key});
  @override
  State<BinaryViewerScreen> createState() => _BinaryViewerScreenState();
}

class _BinaryViewerScreenState extends State<BinaryViewerScreen> {
  List<List<String>> gridData = [];
  List<List<Color>> colorData = [];
  bool isProcessing = false;
  bool isColorMode = false;
  bool showGrid = true;
  double contrast = 1.0;

  Future<void> pickAndConvert() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => isProcessing = true);

    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    final data = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();

    const cols = 720;
    const rows = 460;

    List<List<String>> newGrid = List.generate(rows, (_) => List.filled(cols, ' '));
    List<List<Color>> newColors = List.generate(rows, (_) => List.filled(cols, Colors.white));

    final cellW = img.width / cols;
    final cellH = img.height / rows;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        double r = 0, g = 0, b = 0;
        int alphaSum = 0;
        int count = 0;

        final startX = (x * cellW).floor();
        final startY = (y * cellH).floor();

        for (int sy = 0; sy < cellH.ceil() && startY + sy < img.height; sy++) {
          for (int sx = 0; sx < cellW.ceil() && startX + sx < img.width; sx++) {
            final offset = ((startY + sy) * img.width + (startX + sx)) * 4;
            if (offset + 3 >= data.length) continue;
            r += data[offset];
            g += data[offset + 1];
            b += data[offset + 2];
            alphaSum += data[offset + 3];
            count++;
          }
        }

        if (count > 0 && alphaSum / count >= 100) {
          final avgR = (r / count).round();
          final avgG = (g / count).round();
          final avgB = (b / count).round();
          newColors[y][x] = Color.fromRGBO(avgR, avgG, avgB, 1);
          final brightness = avgR * 0.299 + avgG * 0.587 + avgB * 0.114;
          newGrid[y][x] = brightness > 128 * contrast ? '1' : '0';
        }
      }
    }

    setState(() {
      gridData = newGrid;
      colorData = newColors;
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Art Studio'),
        actions: [
          IconButton(icon: const Icon(Icons.image), onPressed: pickAndConvert),
          IconButton(
            icon: Icon(isColorMode ? Icons.color_lens : Icons.format_color_text),
            onPressed: () => setState(() => isColorMode = !isColorMode),
            tooltip: 'Toggle Color Mode',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {/* TODO: Add PNG download logic */},
            tooltip: 'Download PNG',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 200,
            color: Colors.grey[900],
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Controls", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Color Mode"),
                  value: isColorMode,
                  onChanged: (v) => setState(() => isColorMode = v),
                ),
                SwitchListTile(
                  title: const Text("Show Grid"),
                  value: showGrid,
                  onChanged: (v) => setState(() => showGrid = v),
                ),
                const Text("Contrast"),
                Slider(
                  value: contrast,
                  min: 0.5,
                  max: 2.0,
                  onChanged: (v) => setState(() => contrast = v),
                ),
              ],
            ),
          ),

          // Main Viewer
          Expanded(
            child: Container(
              color: Colors.black,
              child: isProcessing
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : gridData.isEmpty
                      ? const Center(child: Text("Upload an image to begin"))
                      : InteractiveViewer(
                          minScale: 0.005,
                          maxScale: 300,
                          child: CustomPaint(
                            size: Size(gridData[0].length * 2.4, gridData.length * 4.2),
                            painter: BinaryGridPainter(
                              gridData,
                              colorData,
                              isColorMode,
                              showGrid,
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

class BinaryGridPainter extends CustomPainter {
  final List<List<String>> grid;
  final List<List<Color>> colors;
  final bool colorMode;
  final bool showGrid;

  BinaryGridPainter(this.grid, this.colors, this.colorMode, this.showGrid);

  @override
  void paint(Canvas canvas, Size size) {
    if (grid.isEmpty) return;

    final cellW = size.width / grid[0].length;
    final cellH = size.height / grid.length;

    if (showGrid) {
      final gridPaint = Paint()..color = Colors.grey.withOpacity(0.03);
      for (int x = 0; x <= grid[0].length; x++) {
        canvas.drawLine(Offset(x * cellW, 0), Offset(x * cellW, size.height), gridPaint);
      }
      for (int y = 0; y <= grid.length; y++) {
        canvas.drawLine(Offset(0, y * cellH), Offset(size.width, y * cellH), gridPaint);
      }
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        final char = grid[y][x];
        if (char == ' ') continue;

        textPainter.text = TextSpan(
          text: char,
          style: TextStyle(
            color: colorMode ? colors[y][x] : Colors.white,
            fontSize: 0.09,           // Extremely small
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
          ),
        );
        textPainter.layout();

        final offset = Offset(
          x * cellW + (cellW - textPainter.width) / 2,
          y * cellH + (cellH - textPainter.height) / 2,
        );
        textPainter.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}