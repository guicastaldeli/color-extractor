import 'package:web/helpers.dart';
import 'package:web/web.dart' as web;
import 'canvas_image.dart' as canvas;
import 'color_extractor.dart';

void main() {
  final extractor = ColorExtractor();
  canvas.setupEventListeners(extractor);
  redirect();
}

void redirect() {
  final mtxt = web.document.getElementById('-m-txt') as HTMLDivElement;
  mtxt.onClick.listen((e) => web.window.location.assign('/'));
}
