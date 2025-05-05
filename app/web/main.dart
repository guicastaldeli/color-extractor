import 'package:web/helpers.dart';
import 'package:web/web.dart' as web;
import 'canvas_image.dart' as canvas;
import 'color_extractor.dart';

void main() {
  final extractor = ColorExtractor();
  canvas.setupEventListeners(extractor);
  redirect();
  setFavicon('/assets/icon/favicon.ico');
}

void redirect() {
  final mtxt = web.document.getElementById('-m-txt') as HTMLDivElement;
  mtxt.onClick.listen((e) => web.window.location.assign('/'));
}

void setFavicon(String path) {
  final oldFavicon = web.document.querySelector('link[rel="icon"]');
  if(oldFavicon != null) oldFavicon.remove();

  final favicon = web.HTMLLinkElement()
    ..rel = 'icon'
    ..href = path
    ..type = 'image/x-icon'
  ;

  document.head!.append(favicon);
}