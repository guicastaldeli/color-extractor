import 'canvas_image.dart' as canvas;
import 'color_extractor.dart';

void main() {
  final extractor = ColorExtractor();
  canvas.setupEventListeners(extractor);
}
