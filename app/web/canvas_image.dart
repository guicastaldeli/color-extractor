import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'color_extractor.dart';

void setupEventListeners(ColorExtractor extractor) {
  //El
    //Canvas
    final canvas = web.document.getElementById('--canvas-img') as web.HTMLCanvasElement?;
    final ctx = canvas?.getContext('2d') as web.CanvasRenderingContext2D?;
    final paletteContainer = web.document.getElementById('-container-palette');

    //Inputs
    final loadBtn = web.document.getElementById('--btn-load-img') as web.HTMLButtonElement?;
    final fileInput = web.document.getElementById('--input-file-img') as web.HTMLInputElement?;

    if(loadBtn == null || fileInput == null || canvas == null || paletteContainer == null) return;
  //

  //Display Colors
  void displayColors(List<Map<String, dynamic>> colors, web.Element paletteContainer) {
    paletteContainer.innerHTML = '';

    for(final color in colors) {
      final colorDiv = web.document.createElement('div') as web.HTMLDivElement;
      colorDiv.id = '_color-div';
      colorDiv.style
        ..width = '50px'
        ..height = '50px'
        ..backgroundColor = 'rgb(${color['r']}, ${color['g']}, ${color['b']})'
        ..display = 'inline-block'
        ..margin = '5px'
      ;

      final hex = color['hex'] as String;
      final rgbString = color['rgbToString'] as String;
      
      //Display RGB and Hex
      colorDiv.text = '$hex\n$rgbString';

      //Append
      paletteContainer.append(colorDiv);
    }
  }

  //Load Btn
  loadBtn.onClick.listen((_) async {
    final file = fileInput.files?.item(0);
    if(file == null) return;

    //Reader
    final reader = web.FileReader();

    reader.onLoadEnd.listen((web.ProgressEvent _) {
      final image = web.document.createElement('img') as web.HTMLImageElement;
      image.src = (reader.result as JSAny).toString();

      image.onLoad.listen((web.Event _) {
        if(ctx == null) return;
        canvas.width = image.width;
        canvas.height = image.height;
        ctx.drawImage(image, 0, 0);

        //Data
        final imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
        final colors = extractor.extractColors(imageData);

        displayColors(colors, paletteContainer);
      });
    });

    reader.readAsDataURL(file);
  });
}